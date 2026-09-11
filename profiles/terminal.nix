# Add the terminal user environment; for example, this profile installs WezTerm, Zellij, and terminal utilities.
{ username, ... }:

{
  # Attach the terminal implementation to the selected Home Manager user.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/terminal.nix
  ];
}
