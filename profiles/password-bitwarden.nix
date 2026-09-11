# Install Bitwarden Desktop only when requested; for example, password tooling remains independent from the browser profiles.
{ username, pkgs, ... }:

{
  # Keep the password manager user-scoped through Home Manager.
  home-manager.users.${username}.home.packages = [ pkgs.bitwarden-desktop ];
}
