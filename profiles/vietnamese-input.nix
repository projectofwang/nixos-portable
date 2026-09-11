{ inputs, pkgs, username, ... }:

{
  imports = [
    inputs.fcitx5-lotus.nixosModules.fcitx5-lotus
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = [
        inputs.fcitx5-lotus.packages.${pkgs.stdenv.hostPlatform.system}.fcitx5-lotus
        pkgs.fcitx5-gtk
      ];
    };
  };

  services.fcitx5-lotus = {
    enable = true;
    package = inputs.fcitx5-lotus.packages.${pkgs.stdenv.hostPlatform.system}.fcitx5-lotus;
    users = [ username ];
  };
}
