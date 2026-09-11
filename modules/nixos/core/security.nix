# Keep privileged system interfaces explicit; for example, sudo is enabled while polkit remains disabled unless a desktop component requires it.
{ lib, ... }:

{
  # Avoid enabling polkit globally unless a module explicitly needs it.
  security.polkit.enable = lib.mkDefault false;
  # Provide sudo for administrative commands and keep its enablement explicit.
  security.sudo.enable = true;
}
