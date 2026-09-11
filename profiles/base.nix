{ ... }:

{
  imports = [
    ../modules/nixos/core/nix.nix
    ../modules/nixos/core/system.nix
    ../modules/nixos/core/users.nix
    ../modules/nixos/core/security.nix
    ../modules/nixos/core/tools.nix
  ];
}
