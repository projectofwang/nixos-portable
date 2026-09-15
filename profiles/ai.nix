{ username, pkgs, ... }:

{
  imports = [
    ../nixos/opencode.nix
  ];

  # Keep local inference tooling in the AI profile.
  home-manager.users.${username}.home.packages = [
    pkgs.llama-cpp-vulkan
  ];

  # OpenCode is managed by NixOS, not Home Manager.
  programs.opencode = {
    enable = true;
    server.enable = true;
  };
}
