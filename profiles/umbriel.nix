{ username, ... }:

{
  home-manager.users.${username}.imports = [
    ../modules/home-manager/umbriel.nix
  ];
}
