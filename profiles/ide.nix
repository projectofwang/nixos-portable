# Add Zed as an independent editor profile; for example, this profile does not pull in Neovim or LazyVim.
{ username, ... }:

{
  # Attach only the Zed Home Manager implementation to the selected user.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/ide.nix
  ];
}
