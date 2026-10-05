{ ... }:

{
  imports = [
    ../modules/nixos/opencode.nix
  ];

  programs.opencode.enable = true;
}
