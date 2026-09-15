{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.opencode;
in
{
  options.programs.opencode = {
    enable = lib.mkEnableOption "OpenCode";

    package = lib.mkPackageOption pkgs "opencode" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
