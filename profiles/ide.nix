# Provide VS Code through the existing `ide` profile.
{ username, ... }:

{
  # Attach only the VS Code Home Manager implementation to the selected user.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/ide.nix
  ];
}
