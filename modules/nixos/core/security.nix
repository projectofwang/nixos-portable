{ lib, ... }:

{
  security.polkit.enable = lib.mkDefault false;
  security.sudo.enable = true;
}
