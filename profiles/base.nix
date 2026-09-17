{ ... }:

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
    # Enable Fail2ban with its NixOS defaults.
    ../modules/nixos/core/fail2ban.nix
    # Install the base command-line toolset.
    ../modules/nixos/core/tools.nix
  ];
}
