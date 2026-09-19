{
  description = "Portable NixOS configuration framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fcitx5-lotus = {
      url = "github:projectofwang/fcitx5-lotus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:projectofwang/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-greeter = {
      url = "github:projectofwang/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xdg-desktop-portal-umbriel = {
      url = "github:projectofwang/xdg-desktop-portal-umbriel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    umbriel = {
      url = "github:projectofwang/umbriel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:projectofwang/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;
      framework = import ./lib {
        inherit inputs lib home-manager;
      };

      hostConfigurations = lib.mapAttrs' (
        name: definition: lib.nameValuePair name (framework.mkHost definition)
      ) framework.hosts.definitions;

      hostnameAliases = lib.mapAttrs' (
        _name: definition: lib.nameValuePair definition.machine.hostname (framework.mkHost definition)
      ) framework.hosts.definitions;

      allConfigurations = hostConfigurations // hostnameAliases;
      ci = hostConfigurations.ci;
      ciDefinition = framework.hosts.definitions.ci;
      ciSystem = ciDefinition.machine.system;
      productionMachine = framework.hosts.definitions.${framework.hosts.default}.machine;

      ciEvaluationMatrix = lib.concatMap (
        hostName:
        let
          definition = framework.hosts.definitions.${hostName};
          selectedProfiles = lib.unique (
            definition.machine.profiles ++ framework.roles.expand (definition.machine.roles or [ ])
          );
          architectures = definition.machine.architectures or [ definition.machine.system ];
        in
        lib.concatMap (
          architecture:
          map
            (profile: {
              host = hostName;
              inherit architecture profile;
            })
            (
              lib.filter (
                profile: builtins.elem architecture (framework.profiles.architecturesFor profile)
              ) selectedProfiles
            )
        ) architectures
      ) framework.hosts.available;

      ciMatrix = lib.filter (item: item.host == "ci") ciEvaluationMatrix;

      matrixChecks = lib.foldl' (
        checks: item:
        let
          definition = framework.hosts.definitions.${item.host};
          configuration = framework.mkProfileHost {
            inherit (definition) machine hostModule;
            inherit (item) profile;
            system = item.architecture;
          };
        in
        lib.recursiveUpdate checks (
          lib.setAttrByPath [
            item.architecture
            "${item.host}-${item.profile}"
          ] configuration.config.system.build.toplevel
        )
      ) { } ciMatrix;

      frameworkTests = import ./tests/framework.nix { inherit lib; };

      productionConfig = allConfigurations.${framework.hosts.default}.config;
      productionHome = productionConfig.home-manager.users.${productionMachine.username};

      integrationAssertions =
        assert lib.assertMsg (
          productionConfig.security.polkit.enable == false
        ) "production policy must keep polkit disabled";
        assert lib.assertMsg productionConfig.services.pipewire.enable
          "production desktop must enable PipeWire";
        assert lib.assertMsg productionConfig.services.flatpak.enable
          "production desktop must enable Flatpak";
        assert lib.assertMsg productionConfig.xdg.portal.enable
          "production desktop must enable XDG desktop portals";
        assert lib.assertMsg (builtins.elem "gtk" productionConfig.xdg.portal.config.common.default)
          "production desktop portal default must include GTK";
        assert lib.assertMsg productionConfig.services.displayManager.noctalia-greeter.enable
          "production desktop must enable the Noctalia greeter";
        assert lib.assertMsg (
          productionConfig.networking.hostName == productionMachine.hostname
        ) "production hostname must match host identity";
        assert lib.assertMsg (productionConfig.users.users.${productionMachine.username}.isNormalUser
        ) "production primary user must be a normal user";
        assert lib.assertMsg (
          productionConfig.nixpkgs.hostPlatform.system == productionMachine.system
        ) "production architecture must match host identity";
        assert lib.assertMsg (
          productionConfig.services.dnscrypt-proxy.settings.server_names == [ "sdns" ]
        ) "production DNS policy must use the configured self-hosted resolver";
        assert lib.assertMsg (
          productionHome.home.stateVersion == productionMachine.homeStateVersion
        ) "Home Manager state version must match host identity";
        assert lib.assertMsg productionConfig.home-manager.useGlobalPkgs
          "Home Manager must use the system package set";
        assert lib.assertMsg productionConfig.home-manager.useUserPackages
          "Home Manager must install user packages through NixOS";
        true;

      checks = lib.recursiveUpdate matrixChecks {
        ${ciSystem} = {
          ci = ci.config.system.build.toplevel;
          production-machine = allConfigurations.${framework.hosts.default}.config.system.build.toplevel;
          framework-tests =
            assert frameworkTests;
            nixpkgs.legacyPackages.${ciSystem}.runCommand "nixos-portable-framework-tests" { } "touch $out";
          integration-tests =
            assert integrationAssertions;
            nixpkgs.legacyPackages.${ciSystem}.runCommand "nixos-portable-integration-tests" { } "touch $out";
        };
      };

      cliPackages = lib.genAttrs framework.architectures.supported (
        system:
        import ./lib/cli.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );
    in
    {
      nixosConfigurations = allConfigurations;

      checks = checks;
      lib = {
        inherit ciMatrix ciEvaluationMatrix;
      };

      formatter = lib.genAttrs framework.architectures.supported (
        system: nixpkgs.legacyPackages.${system}.nixfmt
      );

      packages = lib.mapAttrs (_system: cli: {
        nixos-portable = cli;
      }) cliPackages;

      devShells.${productionMachine.system}.default = import ./lib/devshell.nix {
        inherit inputs;
        machine = productionMachine;
      };

      apps = lib.mapAttrs (_system: cli: {
        nixos-portable = {
          type = "app";
          program = "${cli}/bin/nixos-portable";
          meta = {
            description = "nixos-portable command-line interface";
          };
        };
      }) cliPackages;
    };
}
