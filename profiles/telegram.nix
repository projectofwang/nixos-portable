{ username, pkgs, ... }:

{
  # Install Telegram Desktop for the selected Home Manager user.
  home-manager.users.${username}.home.packages = [ pkgs.telegram-desktop ];
}
