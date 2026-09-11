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
      framework = import ./lib { inherit inputs lib home-manager; };

      machine = import ./hosts/machine/identity.nix;
      production = framework.mkHost {
        inherit machine;
        hostModule = ./hosts/machine;
      };

      ciMachine = {
        hostname = "nixos-portable-ci";
        username = "ci";
        system = "x86_64-linux";
        timeZone = "UTC";
        nixosStateVersion = "26.05";
        homeStateVersion = "26.05";
        profiles = [
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
      };

      ci = framework.mkHost {
        machine = ciMachine;
        hostModule = ./hosts/ci;
      };
    in
    {
      nixosConfigurations = {
        ${machine.hostname} = production;
        ci = ci;
      };

      checks.x86_64-linux.ci = ci.config.system.build.toplevel;

      formatter.${machine.system} = nixpkgs.legacyPackages.${machine.system}.nixfmt;
    };
}
