# Compose the reusable system baseline; for example, `base` provides Nix, identity, users, security, and Git.
{ ... }:

{
  imports = [
    # Enable the Nix daemon and flake tooling.
    ../modules/nixos/core/nix.nix
    # Map machine identity into hostname and timezone.
    ../modules/nixos/core/system.nix
    # Create the primary user and shell.
    ../modules/nixos/core/users.nix
    # Apply the system security baseline.
    ../modules/nixos/core/security.nix
    # Install minimal system-wide tools such as Git.
    ../modules/nixos/core/tools.nix
  ];
}
