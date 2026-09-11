{ username, ... }:

{
  imports = [
    ./terminal.nix
  ];

  home-manager.users.${username}.imports = [
    ../modules/home-manager/lazyvim.nix
  ];
}
