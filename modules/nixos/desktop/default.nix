{
  inputs,
  username,
  pkgs,
  ...
}:

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
  # Umbriel's portal module supplies the compositor-specific portal backend.
  environment.systemPackages = [
    pkgs.gpu-screen-recorder
    pkgs.krusader
  ];

  # Audio capture/recording and PipeWire-based desktop capture plumbing.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Umbriel's NixOS module registers its own portal backend. GTK remains the
  # general-purpose backend for file chooser, OpenURI, and similar interfaces.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
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
