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

  environment.systemPackages = [
    pkgs.gpu-screen-recorder
    pkgs.krusader
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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
