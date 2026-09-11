{ ... }:

{
  imports = [
    ../modules/nixos/browser
  ];

  programs.firefox.enable = true;
}
