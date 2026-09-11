# Enable Steam, GameMode, and MangoHud for gaming performance monitoring; example: Steam games can show FPS and frametime directly in-game.
{ pkgs, ... }:

{
  # Scope the required unfree Steam packages to gaming instead of enabling unfree software globally.
  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
  ];

  # Enable gaming runtime services while consuming graphics capability from the machine layer.
  programs.gamemode.enable = true;

  # Make MangoHud available as a command; example: `mangohud %command%` enables the overlay for a Steam game.
  environment.systemPackages = [
    pkgs.mangohud
  ];

  # Inject MangoHud into Steam's game runtime without enabling it for unrelated desktop applications; example: Steam games start with the performance overlay enabled.
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv = {
        MANGOHUD = true;
      };
      extraPkgs = pkgs': [
        pkgs'.mangohud
      ];
    };
  };
}
