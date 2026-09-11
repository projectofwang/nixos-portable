# Install Thunderbird only for mail workflows; for example, it is absent unless this profile is selected.
{ username, pkgs, ... }:

{
  # Keep the mail client user-scoped through Home Manager.
  home-manager.users.${username}.home.packages = [ pkgs.thunderbird ];
}
