{ username, pkgs, ... }:

{
  # Thunderbird is kept optional so a mail client never becomes a desktop dependency.
  home-manager.users.${username}.home.packages = [ pkgs.thunderbird ];
}
