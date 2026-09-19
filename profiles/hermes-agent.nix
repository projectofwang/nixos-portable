{ username, ... }:

{
  # Install Hermes Agent through the selected Home Manager user.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/hermes-agent.nix
  ];
}
