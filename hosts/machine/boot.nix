{ ... }:

{
  # Install systemd-boot into the EFI system partition.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 15;
  # Allow activation to update EFI boot variables.
  boot.loader.efi.canTouchEfiVariables = true;
}
