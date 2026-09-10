{ username, ... }:

{
  # Optional graphical terminal stack. User-level configuration stays in Home Manager.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/terminal.nix
  ];
}
