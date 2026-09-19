{ username, pkgs, ... }:

{
  # Install Signal Desktop for the selected Home Manager user.
  home-manager.users.${username}.home.packages = [ pkgs.signal-desktop ];
}
