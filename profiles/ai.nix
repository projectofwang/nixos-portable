{ username, pkgs, ... }:

{
  # Keep local inference tooling in the AI profile.
  home-manager.users.${username}.home.packages = [
    pkgs.llama-cpp-vulkan
  ];
}
