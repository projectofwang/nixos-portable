{ config
, lib
, pkgs
, username
, ...
}:

let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    dbus-python
    pyqt6
    qtpy
  ]);

  fcitx5-lotus = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "fcitx5-lotus";
    version = "3.5.9";

    src = pkgs.fetchFromGitHub {
      owner = "LotusInputMethod";
      repo = "fcitx5-lotus";
      tag = "v${finalAttrs.version}";
      hash = "sha256-kOIs8nLSF93xDIU7v8Wldyw+Zs5NEMJqZA/42TN4oYM=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [
      pkgs.cmake
      pkgs.gettext
      pkgs.go
      pkgs.hicolor-icon-theme
      pkgs.kdePackages.extra-cmake-modules
      pkgs.librsvg
      pkgs.pkg-config
      pkgs.qt6.wrapQtAppsHook
    ];

    buildInputs = [
      pkgs.acl
      pkgs.fcitx5
      pkgs.kdePackages.extra-cmake-modules
      pkgs.libinput
      pkgs.libx11
      pythonEnv
      pkgs.qt6.qtbase
      pkgs.qt6.qtsvg
      pkgs.udev
    ];

    vendorDir = (pkgs.buildGoModule {
      pname = "fcitx5-lotus-go-modules";
      inherit (finalAttrs) version src;
      modRoot = "bamboo";
      vendorHash = "sha256-CNDYjxDfqh9nGs5vlpb/7qXZeNtkvegC5nPvBOZcDrc=";
    }).goModules;

    preConfigure = ''
      export GOCACHE=$TMPDIR/go-cache
      export GOPATH=$TMPDIR/go
      rm -rf bamboo/vendor
      cp -r $vendorDir bamboo/vendor
    '';

    postPatch = ''
      substituteInPlace src/lotus-monitor.cpp \
        --replace-fail 'strcmp(exe_path, "/usr/bin/fcitx5-lotus-server") == 0' \
                       '(strncmp(exe_path, "/nix/store/", 11) == 0 && strlen(exe_path) >= 24 && strcmp(exe_path + strlen(exe_path) - 24, "/bin/fcitx5-lotus-server") == 0)'

      substituteInPlace server/lotus-server.cpp \
        --replace-fail 'strcmp(exe_path, "/usr/bin/fcitx5") == 0' \
                       '(strncmp(exe_path, "/nix/store/", 11) == 0 && strlen(exe_path) >= 11 && strcmp(exe_path + strlen(exe_path) - 11, "/bin/fcitx5") == 0)'

      substituteInPlace src/lotus-engine.cpp \
        --replace-fail '/usr/share/icons/hicolor' '/run/current-system/sw/share/icons/hicolor'

      substituteInPlace settings-gui/i18n.py \
        --replace-fail 'localedir = "/usr/share/locale"' 'localedir = "$out/share/locale"'

      substituteInPlace settings-gui/ui/pages/dict_editor.py \
        --replace-fail '"/usr/share/fcitx5/lotus/vietnamese.cm.dict"' '"$out/share/fcitx5/lotus/vietnamese.cm.dict"'
    '';

    postInstall = ''
      substituteInPlace $out/lib/udev/rules.d/99-lotus.rules \
        --replace-fail "/usr/bin/setfacl" "${pkgs.acl}/bin/setfacl"

      substituteInPlace $out/lib/systemd/system/fcitx5-lotus-server@.service \
        --replace-fail "/usr/bin/setfacl" "${pkgs.acl}/bin/setfacl" \
        --replace-fail "/usr/bin/fcitx5-lotus-server" "$out/bin/fcitx5-lotus-server"
    '';

    postFixup = ''
      patchShebangs $out/share/fcitx5-lotus/settings-gui
      wrapQtApp $out/bin/fcitx5-lotus-settings \
        --prefix XDG_DATA_DIRS : "${pkgs.hicolor-icon-theme}/share"
    '';

    meta = {
      description = "Fcitx5 Lotus input method for Vietnamese typing";
      homepage = "https://github.com/LotusInputMethod/fcitx5-lotus";
      license = lib.licenses.gpl3;
      platforms = lib.platforms.linux;
    };
  });

  cfg = config.services.fcitx5-lotus;
in
{
  options.services.fcitx5-lotus = {
    enable = lib.mkEnableOption "Fcitx5 Lotus integration";

    package = lib.mkOption {
      type = lib.types.package;
      default = fcitx5-lotus;
      description = "Fcitx5 Lotus package to install.";
    };

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ username ];
      description = "Linux users for which the Lotus server is started.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.users != [ ];
        message = "services.fcitx5-lotus.users must contain at least one user.";
      }
      {
        assertion = lib.all (user: builtins.hasAttr user config.users.users) cfg.users;
        message = "services.fcitx5-lotus.users must contain users declared in users.users.";
      }
    ];

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = [
          cfg.package
          pkgs.fcitx5-gtk
        ];
      };
    };

    users.users.uinput_proxy = {
      isSystemUser = true;
      group = "input";
    };

    services.udev.packages = [ cfg.package ];
    systemd.packages = [ cfg.package ];
    systemd.targets.multi-user.wants = map (user: "fcitx5-lotus-server@${user}.service") cfg.users;
  };
}
