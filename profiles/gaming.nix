# Enable Steam and GameMode; for example, this profile can be removed without changing the machine GPU configuration.
{ ... }:

{
  # Scope the required unfree Steam packages to gaming instead of enabling unfree software globally.
  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
  ];

  # Enable gaming runtime services while consuming graphics capability from the machine layer.
  programs.gamemode.enable = true;
  programs.steam.enable = true;
}
