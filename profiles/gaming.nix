# Enable Steam, GameMode, and an always-available MangoHud overlay for game performance monitoring; example: FPS and frametime can be shown in-game.
{ pkgs, ... }:

{
  # Scope the required unfree Steam packages to gaming instead of enabling unfree software globally.
  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
  ];

  # Enable gaming runtime services while consuming graphics capability from the machine layer.
  programs.gamemode.enable = true;
  programs.steam.enable = true;

  # Install MangoHud as the gaming performance overlay; example: `mangohud %command%` can be used in any Steam game's launch options.
  environment.systemPackages = [
    pkgs.mangohud
  ];

  # Configure MangoHud to report the metrics most useful for gaming; example: the overlay shows FPS, frame time, GPU/CPU load, temperatures, RAM, VRAM, and the Vulkan driver.
  home-manager.users.${config.my.username} = {
    programs.mangohud = {
      enable = true;
      settings = {
        fps = true;
        frametime = true;
        gpu_stats = true;
        gpu_temp = true;
        gpu_load_value = true;
        cpu_stats = true;
        cpu_temp = true;
        ram = true;
        vram = true;
        vulkan_driver = true;
      };
    };
  };
}
