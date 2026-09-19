{ pkgs, ... }:

{
  # Load the modules that define the shared system baseline.
  imports = [
    # Configure Nix and flake support.
    ../modules/nixos/core/nix.nix
    # Apply hostname, timezone, and system identity settings.
    ../modules/nixos/core/system.nix
    # Create the primary user and login shell.
    ../modules/nixos/core/users.nix
    # Apply the default security policy.
    ../modules/nixos/core/security.nix
    # Install the base command-line toolset.
    ../modules/nixos/core/tools.nix
  ];

  # Temporary: keep Node.js available system-wide while investigating
  # llama.cpp's build-time Web UI dependency on Node/npm.
  environment.systemPackages = [
    pkgs.nodejs
  ];
}
