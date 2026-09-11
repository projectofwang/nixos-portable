# Provide browser-specific Wayland integration; for example, Firefox and Chromium-family browsers use the Wayland/Ozone environment.
{ ... }:

{
  # Prefer native Wayland backends for browser rendering.
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
