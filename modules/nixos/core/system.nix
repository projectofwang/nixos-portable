{ lib, hostname, timeZone, ... }:

{
  networking.hostName = lib.mkDefault hostname;
  time.timeZone = lib.mkDefault timeZone;
}
