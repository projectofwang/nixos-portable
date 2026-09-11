# Identify the physical machine; for example, optional software is selected outside this machine identity.
{
  hostname = "nixos";
  username = "chicoarun";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  # Keep the machine profile set minimal; for example, optional features are not enabled by the hardware identity.
  profiles = [
    "base"
  ];
}
