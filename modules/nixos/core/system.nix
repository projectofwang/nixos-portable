# Map machine identity into system defaults; for example, the production hostname and timezone come from `identity.nix`.
{
  lib,
  hostname,
  timeZone,
  ...
}:

{
  # Set the host name without overriding a more specific machine module.
  networking.hostName = lib.mkDefault hostname;
  # Set the system timezone from machine identity; example: `Asia/Ho_Chi_Minh` for the current host.
  time.timeZone = lib.mkDefault timeZone;
}
