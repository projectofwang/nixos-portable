{ inputs, ... }:

{
  # Load shared browser support and the Helium NixOS module.
  imports = [
    ../modules/nixos/browser
    inputs.helium.nixosModules.default
  ];

  # Enable Wayland and accelerated Chromium video paths for Helium.
  programs.helium = {
    enable = true;
    flags = [
      "--ozone-platform=wayland"
      "--enable-features=WaylandWindowDecorations,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL"
    ];
  };
}
