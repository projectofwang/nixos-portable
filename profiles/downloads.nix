{ username, pkgs, ... }:

{
  # Optional GUI download manager; no background daemon is enabled.
  home-manager.users.${username}.home.packages = [ pkgs.qbittorrent ];
}
