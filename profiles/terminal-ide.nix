{ username, ... }:

{
  # Reuse the terminal profile before adding the IDE layer.
  imports = [
    ./terminal.nix
  ];

  # Load the shared LazyVim Home Manager configuration.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/lazyvim.nix
  ];
}
