# Define the hardware-independent CI host and let its role exercise the full profile surface.
{
  hostname = "nixos-portable-ci";
  username = "ci";
  system = "x86_64-linux";
  architectures = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  timeZone = "UTC";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  roles = [
    "ci"
  ];

  profiles = [ ];
}
