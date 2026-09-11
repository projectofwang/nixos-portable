# Add Helium with the shared browser integration; for example, Wayland and accelerated Chromium video flags are configured here.
{ inputs, ... }:

{
  # Import generic browser support plus the Helium NixOS module.
  imports = [
    ../modules/nixos/browser
    inputs.helium.nixosModules.default
  ];

  # Enable native Wayland and Chromium accelerated video paths for Helium.
  programs.helium = {
    enable = true;
    flags = [
      "--ozone-platform=wayland"
      "--enable-features=WaylandWindowDecorations,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL"
    ];
  };
}
