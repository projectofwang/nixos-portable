{ pkgs, ... }:

{
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = [
    pkgs.libva-utils
    pkgs.vulkan-tools
  ];
}
