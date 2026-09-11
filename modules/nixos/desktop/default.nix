# Assemble the desktop system layer; for example, this module is imported only by the `desktop` profile.
{
  inputs,
  username,
  pkgs,
  ...
}:

{
  # Import desktop system modules supplied by the Umbriel and Noctalia inputs.
  imports = [
    inputs.umbriel.nixosModules.default
    inputs.noctalia.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  # Enable the system-side Umbriel compositor integration.
  programs.umbriel.enable = true;

  # Enable Noctalia and its recommended supporting services for the desktop session.
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  # Install desktop utilities that are intentionally system-wide; for example, GPU Screen Recorder and Krusader are launched by the desktop.
  environment.systemPackages = [
    pkgs.gpu-screen-recorder
    pkgs.krusader
  ];

  # Provide PipeWire audio with real-time scheduling and 32-bit ALSA compatibility.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Use the GTK portal as the default desktop portal; for example, file dialogs and browser sandbox APIs can use it.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  # Start the graphical session through the Noctalia greeter with the machine's default user.
  programs.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "Umbriel";
      user.default = username;
    };
  };

  # Add user-level desktop configuration without mixing it into the system module.
  home-manager.users.${username}.imports = [
    ../../home-manager/desktop
  ];
}
