{ username, pkgs, ... }:

{
  # Keep download tooling scoped to the selected Home Manager user.
  home-manager.users.${username}.home.packages = [ ];
}
