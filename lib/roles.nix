# Discover reusable role definitions from `roles/*.nix` and expand them into profile names.
{ lib, profiles }:

let
  rolesDir = ../roles;
  entries = builtins.readDir rolesDir;
  roleNames = map (name: lib.removeSuffix ".nix" name) (
    lib.filter (
      name:
      entries.${name} == "regular" && lib.hasSuffix ".nix" name
    ) (builtins.attrNames entries)
  );

  roleDefinitions = lib.genAttrs roleNames (
    name: (import (rolesDir + "/${name}.nix") { inherit profiles; }).profiles
  );

  validate = selected:
    let
      unknown = lib.filter (role: !(builtins.elem role roleNames)) selected;
    in
    assert lib.assertMsg (unknown == [ ])
      "Unknown role(s): ${lib.concatStringsSep ", " unknown}. Available roles: ${lib.concatStringsSep ", " roleNames}";
    selected;

  expand = selected:
    let
      validated = validate selected;
    in
    lib.unique (lib.concatMap (role: roleDefinitions.${role}) validated);
in
{
  available = roleNames;
  inherit roleDefinitions validate expand;
}
