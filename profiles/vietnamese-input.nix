{ ... }:

{
  imports = [
    ../modules/nixos/input-method
  ];

  services.fcitx5-lotus = {
    enable = true;
  };
}
