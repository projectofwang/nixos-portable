{ ... }:

{
  # Select native Wayland backends for supported browsers.
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
