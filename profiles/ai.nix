# Install llama.cpp tools without choosing a model or configuring a server.
{ username, pkgs, ... }:

{
  home-manager.users.${username}.home.packages = [
    pkgs.llama-cpp-vulkan
  ];
}
