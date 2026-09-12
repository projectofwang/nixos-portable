# Identify the physical machine; role selection stays separate from the machine implementation.
{
  hostname = "nixos";
  username = "chicoarun";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  roles = [
    "workstation"
  ];

  profiles = [ ];
}
