{ inputs, username, pkgs, ... }:

let
  hostSystem = pkgs.stdenv.hostPlatform.system;
  umbrielPortal = inputs.xdg-desktop-portal-umbriel.packages.${hostSystem}.default;
  noctaliaPackage = inputs.noctalia.packages.${hostSystem}.default;
in
{
  imports = [
    inputs.umbriel.nixosModules.default
    inputs.noctalia.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  programs.umbriel.enable = true;

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  # Noctalia's screen-recorder plugin uses gpu-screen-recorder.
  # Umbriel's portal backend provides the ScreenCast and Screenshot interfaces
  # required by portal-based capture and screen sharing.
  environment.systemPackages = [
    pkgs.gpu-screen-recorder
    pkgs.xdg-desktop-portal
    pkgs.xdg-desktop-portal-gtk
    umbrielPortal
  ];

  # Audio capture/recording and PipeWire-based desktop capture plumbing.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Noctalia's recommended services cover NetworkManager, Bluetooth, UPower,
  # and power-profiles-daemon.
  services.power-profiles-daemon.enable = true;

  # Install the Umbriel portal backend and select it specifically for the
  # ScreenCast/Screenshot interfaces. Keep GTK as the general-purpose portal
  # backend for file chooser, OpenURI, and other desktop portals.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      umbrielPortal
    ];
    config.common.default = [ "gtk" ];
    config.Umbriel = {
      default = [ "umbriel" "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "umbriel" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "umbriel" ];
    };
  };

  # Noctalia discovers the official source itself, but plugins are disabled
  # until explicitly enabled. Enable the official Screen Recorder once the
  # Noctalia IPC endpoint is available. The state is intentionally kept in
  # Noctalia's writable state directory, not the Nix-managed config tree.
  systemd.user.services.noctalia-screen-recorder-plugin = {
    description = "Enable Noctalia Screen Recorder plugin";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "enable-noctalia-screen-recorder" ''
        set -eu
        for attempt in $(seq 1 30); do
          if ${noctaliaPackage}/bin/noctalia msg plugins enable noctalia/screen_recorder; then
            exit 0
          fi
          sleep 2
        done
        echo "Noctalia screen recorder plugin could not be enabled" >&2
        exit 1
      '';
    };
  };

  programs.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "Umbriel";
      user.default = username;
    };
  };

  home-manager.users.${username}.imports = [
    ../../home-manager/desktop
  ];
}
