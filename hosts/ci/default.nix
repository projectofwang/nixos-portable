{ ... }:

{
  boot.isContainer = true;

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };
}
