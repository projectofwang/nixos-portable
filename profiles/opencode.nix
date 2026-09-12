{ username, ... }:

{
  # Install OpenCode through the selected Home Manager user.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/opencode.nix
  ];
}
