{ pkgs, ... }:

{
  # Allow only the unfree packages required by the gaming stack.
  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
  ];

  # Enable the GameMode service for games that use it.
  programs.gamemode.enable = true;

  # Provide MangoHud as a standalone command.
  environment.systemPackages = [
    pkgs.mangohud
  ];

  # Start Steam games with MangoHud available in the game runtime.
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
