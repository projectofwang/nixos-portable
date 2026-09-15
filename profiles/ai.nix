{ username, pkgs, ... }:

{
  imports = [
    ../nixos/opencode.nix
  ];

  # Keep local inference tooling in the AI profile.
  home-manager.users.${username}.home.packages = [
    pkgs.llama-cpp-vulkan
  ];

  # Install OpenCode through NixOS; no OpenCode server is configured.
  programs.opencode.enable = true;
}
