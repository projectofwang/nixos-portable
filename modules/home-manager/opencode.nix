{ pkgs, ... }:

{
  # Install the OpenCode CLI from the selected nixpkgs revision.
  home.packages = [
    pkgs.opencode
  ];
}
