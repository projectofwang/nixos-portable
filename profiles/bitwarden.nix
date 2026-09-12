{ username, pkgs, ... }:

{
  # Keep Bitwarden scoped to the selected Home Manager user.
  home-manager.users.${username}.home.packages = [ pkgs.bitwarden-desktop ];
}
