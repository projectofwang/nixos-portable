{ username, ... }:

{
  # Load the shared terminal Home Manager configuration.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/terminal.nix
  ];
}
