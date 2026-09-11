# Add Helium with the same browser integration; for example, Wayland and accelerated Chromium video flags are kept with the browser profile.
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
