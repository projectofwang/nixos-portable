{ ... }:

{
  # Keep the CI host independent of physical disks, firmware, and GPUs.
  boot.isContainer = true;

  # Use a tmpfs root so CI has no machine-specific storage dependency.
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };
}
