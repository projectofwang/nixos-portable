{ ... }:

{
  # Manage OpenCode through NixOS without enabling its server.
  imports = [
    ../nixos/opencode.nix
  ];

  programs.opencode.enable = true;
}
