{ lib, ... }:

{
  # Baseline user environment. Feature-specific GUI/IDE/AI modules are
  # imported by their opt-in profiles.
  options.my.ai.enable = lib.mkEnableOption "local AI integration";

  imports = [
    ./shell.nix
  ];
}
