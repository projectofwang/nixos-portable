{ username, pkgs, ... }:

{
  # Keep KeePassXC scoped to the selected Home Manager user.
  home-manager.users.${username}.home.packages = [ pkgs.keepassxc ];
}
