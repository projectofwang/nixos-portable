{ lib, ... }:

{
  # AMD gaming stack: Mesa/RADV plus 32-bit graphics for Steam/Proton.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Steam and its runtime are unfree; keep the exception scoped to the profile.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];

  programs.gamemode.enable = true;
  programs.steam.enable = true;
}
