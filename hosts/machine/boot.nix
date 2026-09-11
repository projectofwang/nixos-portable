# Keep the bootloader machine-specific; for example, systemd-boot is used by the current UEFI machine.
{ ... }:

{
  # Install systemd-boot into the EFI system partition.
  boot.loader.systemd-boot.enable = true;
  # Allow NixOS to update EFI boot variables during activation.
  boot.loader.efi.canTouchEfiVariables = true;
}
