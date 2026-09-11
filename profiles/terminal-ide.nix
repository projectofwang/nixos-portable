# Extend the terminal profile with LazyVim; for example, selecting `terminal-ide` automatically includes `terminal` first.
{ username, ... }:

{
  # Reuse the terminal profile rather than duplicating its package set.
  imports = [
    ./terminal.nix
  ];

  # Add the complete Neovim/LazyVim implementation for this user.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/lazyvim.nix
  ];
}
