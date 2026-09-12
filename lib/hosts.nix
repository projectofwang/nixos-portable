# Discover host definitions from `hosts/*/identity.nix` so the framework can scale to multiple machines.
{ lib }:

let
  hostsDir = ../hosts;
  entries = builtins.readDir hostsDir;
  directories = lib.filterAttrs (_: type: type == "directory") entries;
  names = builtins.attrNames directories;
  hostNames = lib.filter (
    name:
    builtins.pathExists (hostsDir + "/${name}/identity.nix")
  ) names;

  requiredFields = [
    "hostname"
    "username"
    "system"
    "timeZone"
    "nixosStateVersion"
    "homeStateVersion"
    "profiles"
  ];

  definitions = lib.genAttrs hostNames (
    name:
    let
      machine = import (hostsDir + "/${name}/identity.nix");
      missingFields = lib.filter (field: !(builtins.hasAttr field machine)) requiredFields;
      hostModule = hostsDir + "/${name}";
    in
    assert lib.assertMsg (missingFields == [ ])
      "Host '${name}' is missing required identity field(s): ${lib.concatStringsSep ", " missingFields}";
    assert lib.assertMsg (builtins.pathExists (hostModule + "/default.nix"))
      "Host '${name}' must provide hosts/${name}/default.nix";
    {
      inherit machine hostModule;
    }
  );

  hostnames = map (name: definitions.${name}.machine.hostname) hostNames;
  duplicateHostnames = lib.unique (
    lib.filter (
      hostname:
      builtins.length (lib.filter (candidate: candidate == hostname) hostnames) > 1
    ) hostnames
  );
in
assert lib.assertMsg (duplicateHostnames == [ ])
  "Duplicate host hostname(s): ${lib.concatStringsSep ", " duplicateHostnames}";
assert lib.assertMsg (builtins.elem "machine" hostNames)
  "The production host 'machine' must exist under hosts/machine/";
{
  # Keep host discovery deterministic and make the available host names inspectable.
  available = hostNames;

  # The production host is explicit rather than inferred from an arbitrary definition.
  default = "machine";

  # Each host supplies identity and its machine module directory. Hardware and software
  # composition remain inside that host and the shared framework.
  inherit definitions;
}
