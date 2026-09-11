{ ... }:

{
  imports = [
    ../modules/nixos/graphics.nix
  ];

  # Steam and its runtime are unfree; keep the exception scoped to the profile.
  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
  ];

  programs.gamemode.enable = true;
  programs.steam.enable = true;
}
