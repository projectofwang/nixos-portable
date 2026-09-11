# Install KeePassXC only when requested; for example, it can coexist with Bitwarden without changing the base profile.
{ username, pkgs, ... }:

{
  # Keep the password manager user-scoped through Home Manager.
  home-manager.users.${username}.home.packages = [ pkgs.keepassxc ];
}
