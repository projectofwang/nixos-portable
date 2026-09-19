{ username, pkgs, ... }:

{
  # Keep qBittorrent scoped to the selected Home Manager user.
  home-manager.users.${username}.home.packages = [ pkgs.qbittorrent ];
}
