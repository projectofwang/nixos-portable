# Keep the CI host hardware-independent; for example, the GitHub runner can evaluate a tmpfs-backed NixOS container.
{ ... }:

{
  # Avoid depending on physical disks, firmware, or GPU devices in CI.
  boot.isContainer = true;

  # Use an in-memory root filesystem so the CI system has no machine-specific storage assumptions.
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };
}
