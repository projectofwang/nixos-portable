# Install qBittorrent only for download workflows; for example, removing this profile leaves the base system unchanged.
{ username, pkgs, ... }:

{
  # Keep the GUI application user-scoped through Home Manager.
  home-manager.users.${username}.home.packages = [ pkgs.qbittorrent ];
}
