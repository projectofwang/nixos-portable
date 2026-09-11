# Install Vesktop only when requested; for example, selecting `vesktop` adds the Discord client.
{ username, pkgs, ... }:

{
  # Keep Vesktop user-scoped through Home Manager.
  home-manager.users.${username}.home.packages = [ pkgs.vesktop ];
}
