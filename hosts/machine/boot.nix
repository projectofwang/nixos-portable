{ ... }:

{
  # Default for modern UEFI systems.
  # If the target machine uses a different boot setup, change this file only.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
