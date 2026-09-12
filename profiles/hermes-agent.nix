# Install Hermes Agent through Home Manager while leaving all AI configuration to the user.
{ username, ... }:

{
  home-manager.users.${username}.imports = [
    ../modules/home-manager/hermes-agent.nix
  ];
}
