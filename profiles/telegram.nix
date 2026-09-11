# Install Telegram Desktop only when requested; for example, selecting `telegram` adds the native client.
{ username, pkgs, ... }:

{
  # Keep Telegram Desktop user-scoped through Home Manager.
  home-manager.users.${username}.home.packages = [ pkgs.telegram-desktop ];
}
