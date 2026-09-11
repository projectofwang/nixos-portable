{ pkgs, ... }:

{
  # Shared Wayland/browser integration. Browser selection lives in the
  # individual browser profiles so enabling one never installs another.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = [
    pkgs.libva-utils
    pkgs.vulkan-tools
  ];
}
