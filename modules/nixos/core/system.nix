{
  lib,
  hostname,
  timeZone,
  ...
}:

{
  # Use host identity as the default hostname.
  networking.hostName = lib.mkDefault hostname;

  # Use host identity as the default system timezone.
  time.timeZone = lib.mkDefault timeZone;
}
