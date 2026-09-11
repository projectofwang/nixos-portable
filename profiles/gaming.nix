{ ... }:

{
  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
  ];

  programs.gamemode.enable = true;
  programs.steam.enable = true;
}
