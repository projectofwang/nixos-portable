# Install Bitwarden Desktop only when requested; for example, it remains independent from browser profiles.
{ username, pkgs, ... }:

{
  # Keep the password manager user-scoped through Home Manager.
  home-manager.users.${username}.home.packages = [ pkgs.bitwarden-desktop ];
}
