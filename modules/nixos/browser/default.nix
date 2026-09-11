# Provide browser-specific Wayland integration and diagnostics; for example, Firefox and Chromium-family browsers use the Wayland/Ozone environment.
{ pkgs, ... }:

{
  # Prefer native Wayland backends for browser rendering.
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  # Keep GPU diagnostic tools with the browser capability layer; for example, `vulkaninfo` and `vainfo` verify runtime acceleration.
  environment.systemPackages = [
    pkgs.libva-utils
    pkgs.vulkan-tools
  ];
}
