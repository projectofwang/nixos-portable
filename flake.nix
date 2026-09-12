# Define the repository inputs; for example, `nixpkgs` pins the NixOS package set.
{
  description = "Portable NixOS configuration framework for multiple machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent = {
      url = "github:NousResearch/hermes-agent/v2026.9.7";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
      inputs.xdg-desktop-portal-umbriel.follows = "xdg-desktop-portal-umbriel";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      framework = import ./lib { inherit inputs lib home-manager; };

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

      ciMatrix = lib.concatMap (
        hostName:
        let
          definition = framework.hosts.definitions.${hostName};
          selectedProfiles = lib.unique (
            definition.machine.profiles ++ framework.roles.expand (definition.machine.roles or [ ])
          );
        in
        map (profile: {
          host = hostName;
          architecture = definition.machine.system;
          inherit profile;
        }) selectedProfiles
      ) framework.hosts.available;

      matrixChecks = lib.foldl' (
        checks: item:
        let
          definition = framework.hosts.definitions.${item.host};
          configuration = framework.mkProfileHost {
            inherit (definition) machine hostModule;
            inherit (item) profile;
          };
        in
        lib.recursiveUpdate checks (
          lib.setAttrByPath [
            item.architecture
            "${item.host}-${item.profile}"
          ] configuration.config.system.build.toplevel
        )
      ) { } ciMatrix;

      checks = lib.recursiveUpdate matrixChecks {
        ${ciSystem}.ci = ci.config.system.build.toplevel;
      };

      cliPackages = lib.genAttrs framework.architectures.supported (
        system:
        import ./lib/cli.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          flake = ".";
        }
      );
    in
    {
      nixosConfigurations = allConfigurations;

      inherit ciMatrix checks;

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
        };
      }) cliPackages;
    };
}
