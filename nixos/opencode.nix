{ config, lib, pkgs, username, ... }:

let
  cfg = config.programs.opencode;
  serverCfg = cfg.server;
in
{
  options.programs.opencode = {
    enable = lib.mkEnableOption "OpenCode";

    package = lib.mkPackageOption pkgs "opencode" { };

    server = {
      enable = lib.mkEnableOption "the OpenCode HTTP server";

      hostname = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Hostname on which the OpenCode server listens.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 4096;
        description = "TCP port on which the OpenCode server listens.";
      };

      cors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional origins allowed by the OpenCode HTTP server.";
      };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          EnvironmentFile for the OpenCode server, for example
          OPENCODE_SERVER_PASSWORD=... .
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.opencode = lib.mkIf serverCfg.enable {
      description = "OpenCode HTTP server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        User = username;
        Group = "users";
        WorkingDirectory = "/home/${username}";
        Environment = [
          "HOME=/home/${username}"
          "XDG_CONFIG_HOME=/home/${username}/.config"
        ];
        ExecStart = lib.concatStringsSep " " (
          [
            (lib.getExe cfg.package)
            "serve"
            "--hostname"
            serverCfg.hostname
            "--port"
            (toString serverCfg.port)
          ]
          ++ lib.concatMap (origin: [ "--cors" origin ]) serverCfg.cors
        );
        Restart = "on-failure";
        RestartSec = 5;
      }
      // lib.optionalAttrs (serverCfg.environmentFile != null) {
        EnvironmentFile = serverCfg.environmentFile;
      };
    };
  };
}
