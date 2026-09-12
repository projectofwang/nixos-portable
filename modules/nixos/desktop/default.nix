{
  inputs,
  username,
  pkgs,
  ...
}:

{
  # Load the desktop modules provided by the compositor and session inputs.
  imports = [
    inputs.umbriel.nixosModules.default
    inputs.noctalia.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  # Enable the system-side Umbriel compositor integration.
  programs.umbriel.enable = true;

  # Enable Noctalia and its supporting services.
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  # Install desktop utilities that are shared by all desktop sessions.
  environment.systemPackages = [
    pkgs.flatpak
    pkgs.gpu-screen-recorder
    pkgs.krusader
  ];

  # Enable the system Flatpak service.
  services.flatpak.enable = true;

  # Provide PipeWire audio with real-time scheduling and 32-bit ALSA support.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Use GTK as the default desktop portal implementation.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  # Start the graphical session with the configured default user.
  programs.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "Umbriel";
      user.default = username;
    };
  };

  # Load the matching user-level desktop configuration.
  home-manager.users.${username}.imports = [
    ../../home-manager/desktop
  ];
}
