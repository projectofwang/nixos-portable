{ inputs, pkgs, ... }:

{
  imports = [
    inputs.helium.nixosModules.default
  ];

  # Browser session integration for a Wayland-native Umbriel desktop.
  # Keep browser-specific configuration here rather than coupling it to the
  # desktop profile so the browser profile remains independently reusable.
  programs.firefox.enable = true;

  programs.helium = {
    enable = true;
    flags = [
      "--ozone-platform=wayland"
      "--enable-features=WaylandWindowDecorations,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL"
    ];
  };

  # Enable the generic Linux graphics stack without selecting a vendor-specific
  # VA-API driver. This keeps the profile portable across Intel, AMD and NVIDIA.
  # The actual VA-API backend is supplied by the active GPU driver/Mesa stack.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Native Wayland browser rendering. NIXOS_OZONE_WL covers Chromium/Electron-
  # family applications that honor the NixOS convention; Helium additionally
  # receives an explicit ozone-platform flag above.
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  # Diagnostics only: do not force LIBVA_DRIVER_NAME or NVIDIA-specific VA-API
  # flags globally. Intel/AMD VA-API is generally usable with their native
  # drivers; NVIDIA's Chromium VA-API path remains hardware/driver/version
  # sensitive and forcing it can produce blank video or decode regressions.
  environment.systemPackages = [
    pkgs.libva-utils
    pkgs.vulkan-tools
  ];
}
