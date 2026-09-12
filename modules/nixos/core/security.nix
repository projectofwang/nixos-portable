{ lib, ... }:

{
  # Keep polkit disabled unless a desktop component explicitly enables it.
  security.polkit.enable = lib.mkDefault false;

  # Require authentication for sudo access through the wheel group.
  security.sudo.enable = true;
}
