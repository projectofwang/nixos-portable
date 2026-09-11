# Install Signal Desktop only when requested; for example, selecting `signal` adds the native client.
{ username, pkgs, ... }:

{
  # Keep Signal Desktop user-scoped through Home Manager.
  home-manager.users.${username}.home.packages = [ pkgs.signal-desktop ];
}
