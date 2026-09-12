{ username, pkgs, ... }:

{
  # Install the local inference tools without selecting a model or server.
  home-manager.users.${username}.home.packages = [
    pkgs.llama-cpp-vulkan
  ];
}
