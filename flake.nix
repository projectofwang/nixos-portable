{
  description = "Portable NixOS configuration with Home Manager and optional feature profiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
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

      profileFiles = builtins.readDir ./profiles;
      availableProfiles = map (name: lib.removeSuffix ".nix" name) (
        lib.filter (name: profileFiles.${name} == "regular" && lib.hasSuffix ".nix" name) (
          builtins.attrNames profileFiles
        )
      );

      validateProfiles =
        selected:
        let
          unknown = lib.filter (profile: !(builtins.elem profile availableProfiles)) selected;
        in
        assert lib.assertMsg (unknown == [ ])
          "Unknown profile(s): ${lib.concatStringsSep ", " unknown}. Available profiles: ${lib.concatStringsSep ", " availableProfiles}";
        selected;

      mkHome =
        { username, homeStateVersion }:
        {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-bak";
          extraSpecialArgs = {
            inherit inputs homeStateVersion username;
          };
          users.${username} = {
            imports = [
              ./modules/home-manager
              ./home/default.nix
            ];
            home.stateVersion = homeStateVersion;
          };
        };

      machine = import ./hosts/machine/identity.nix;
      inherit (machine)
        hostname
        username
        system
        timeZone
        nixosStateVersion
        homeStateVersion
        ;
      profiles = validateProfiles machine.profiles;

      nixosConfiguration = lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit
            inputs
            machine
            hostname
            username
            timeZone
            nixosStateVersion
            homeStateVersion
            ;
        };

        modules = [
          ./hosts/machine
          home-manager.nixosModules.home-manager
        ]
        ++ map (profile: ./profiles/${profile}.nix) profiles
        ++ [
          {
            system.stateVersion = nixosStateVersion;
            home-manager = mkHome { inherit username homeStateVersion; };
          }
        ];
      };

      ciSystem = "x86_64-linux";
      ciUsername = "ci";
      ciStateVersion = "26.05";
      ciHostname = "nixos-portable-ci";
      ciProfiles = validateProfiles [
        "base"
        "desktop"
        "terminal"
        "browser"
        "gaming"
        "ai"
        "ide"
        "umbriel"
        "vietnamese-input"
      ];

      ciMachine = {
        hostname = ciHostname;
        username = ciUsername;
        system = ciSystem;
        timeZone = "UTC";
        nixosStateVersion = ciStateVersion;
        homeStateVersion = ciStateVersion;
        profiles = ciProfiles;
      };

      ciConfiguration = lib.nixosSystem {
        system = ciSystem;

        specialArgs = {
          inherit inputs;
          machine = ciMachine;
          hostname = ciMachine.hostname;
          username = ciMachine.username;
          timeZone = ciMachine.timeZone;
          nixosStateVersion = ciMachine.nixosStateVersion;
          homeStateVersion = ciMachine.homeStateVersion;
        };

        modules = [
          ./hosts/ci
          home-manager.nixosModules.home-manager
        ]
        ++ map (profile: ./profiles/${profile}.nix) ciProfiles
        ++ [
          {
            system.stateVersion = ciStateVersion;
            home-manager = mkHome {
              username = ciUsername;
              homeStateVersion = ciStateVersion;
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        ${hostname} = nixosConfiguration;
        ci = ciConfiguration;
      };

      checks.${ciSystem}.ci = ciConfiguration.config.system.build.toplevel;

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
    };
}
