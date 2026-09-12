# Compose reusable feature groups from profiles; for example, `workstation` enables the complete desktop profile set.
{ lib, profiles }:

let
  roleDefinitions = {
    # Keep the workstation role declarative so a host can select a role without copying profile lists.
    workstation = profiles.available;

    # CI exercises the same complete profile surface without depending on physical hardware.
    ci = profiles.available;
  };

  available = builtins.attrNames roleDefinitions;

  validate = selected:
    let
      unknown = lib.filter (role: !(builtins.elem role available)) selected;
    in
    assert lib.assertMsg (unknown == [ ])
      "Unknown role(s): ${lib.concatStringsSep ", " unknown}. Available roles: ${lib.concatStringsSep ", " available}";
    selected;

  expand = selected:
    let
      validated = validate selected;
    in
    lib.unique (lib.concatMap (role: roleDefinitions.${role}) validated);
in
{
  inherit available roleDefinitions validate expand;
}
