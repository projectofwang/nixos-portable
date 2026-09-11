# Define the repository inputs; for example, `nixpkgs` pins the NixOS package set.
{
  description = "Portable NixOS configuration with Home Manager and optional feature profiles";

  # Keep all external dependencies in one place; for example, Home Manager follows this flake's nixpkgs.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Reuse the same nixpkgs revision for Home Manager to avoid package-set drift.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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

  # Compose production and CI systems; for example, `.#nixos` targets the machine identity.
  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      framework = import ./lib { inherit inputs lib home-manager; };

      # Production reads all machine-specific identity from one file.
      machine = import ./hosts/machine/identity.nix;
      production = framework.mkHost {
        inherit machine;
        hostModule = ./hosts/machine;
      };

      # CI uses a hardware-independent machine definition so GitHub runners can evaluate it safely.
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
          "terminal-ide"
          "browser-firefox"
          "browser-helium"
          "gaming"
          "ai"
          "ide"
          "media"
          "downloads"
          "mail-thunderbird"
          "password-bitwarden"
          "password-keepassxc"
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
      # Export named systems; for example, `nixos-rebuild build --flake .#nixos` selects production.
      nixosConfigurations = {
        ${machine.hostname} = production;
        ci = ci;
      };

      # Expose a dry-run CI build target without requiring production hardware.
      checks.x86_64-linux.ci = ci.config.system.build.toplevel;

      # Use nixfmt for the machine's native system; for example, `nix fmt` formats all tracked Nix files.
      formatter.${machine.system} = nixpkgs.legacyPackages.${machine.system}.nixfmt;
    };
}
