# Define the repository inputs; for example, `nixpkgs` pins the NixOS package set.
{
  description = "Portable NixOS configuration framework for multiple machines";

  # Keep all external dependencies in one place; for example, Home Manager follows this flake's nixpkgs.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Reuse the same nixpkgs revision for Home Manager to avoid package-set drift.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent = {
      url = "github:NousResearch/hermes-agent/v2026.9.7";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Pin the Vietnamese input method and desktop dependencies as flake inputs.
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

  # Discover every host from hosts/*/identity.nix and build the same framework for each one.
  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      framework = import ./lib { inherit inputs lib home-manager; };

      hostConfigurations = lib.mapAttrs' (
        _name: definition:
        lib.nameValuePair definition.machine.hostname (framework.mkHost definition)
      ) framework.hosts.definitions;

      ciHostname = framework.hosts.definitions.ci.machine.hostname;
      ci = hostConfigurations.${ciHostname};

      productionMachine = framework.hosts.definitions.${framework.hosts.default}.machine;
    in
    {
      # Every discovered host becomes a first-class flake target.
      nixosConfigurations = hostConfigurations // {
        # Preserve the existing CI target so workflows and local commands remain compatible.
        ci = ci;
      };

      # Keep CI explicit while host discovery remains generic for production and future machines.
      checks.x86_64-linux.ci = ci.config.system.build.toplevel;

      # Use nixfmt for the machine's native system; for example, `nix fmt` formats all tracked Nix files.
      formatter.${productionMachine.system} = nixpkgs.legacyPackages.${productionMachine.system}.nixfmt;

      # Provide a development shell with Nix tooling; for example, `nix develop` gives nixfmt, alejandra, nil, and statix.
      devShells.${productionMachine.system}.default = import ./lib/devshell.nix {
        inherit inputs;
        machine = productionMachine;
      };
    };
}
