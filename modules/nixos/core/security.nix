{ lib, ... }:

{
  # Keep this a default so desktop/networking modules may enable polkit when needed.
  security.polkit.enable = lib.mkDefault false;

  security.sudo.enable = true;
}
