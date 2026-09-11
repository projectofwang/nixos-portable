{ inputs, ... }:

{
  imports = [
    ../modules/nixos/browser
    inputs.helium.nixosModules.default
  ];

  programs.helium = {
    enable = true;
    flags = [
      "--ozone-platform=wayland"
      "--enable-features=WaylandWindowDecorations,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL"
    ];
  };
}
