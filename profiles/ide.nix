{ username, ... }:

{
  home-manager.users.${username}.imports = [
    ../modules/home-manager/ide.nix
  ];
}
