# Discover host definitions from `hosts/*/identity.nix` and validate their framework contract.
{
  lib,
  architectures,
}:

let
  hostsDir = ../hosts;
  entries = builtins.readDir hostsDir;
  directories = lib.filterAttrs (_: type: type == "directory") entries;
  names = builtins.attrNames directories;
  hostNames = lib.filter (name: builtins.pathExists (hostsDir + "/${name}/identity.nix")) names;

  requiredFields = [
    "hostname"
    "username"
    "system"
    "timeZone"
    "nixosStateVersion"
    "homeStateVersion"
    "roles"
    "profiles"
  ];

  stringFields = [
    "hostname"
    "username"
    "system"
    "timeZone"
    "nixosStateVersion"
    "homeStateVersion"
  ];

  definitions = lib.genAttrs hostNames (
    name:
    let
      machine = import (hostsDir + "/${name}/identity.nix");
      missingFields = lib.filter (field: !(builtins.hasAttr field machine)) requiredFields;
      invalidStringFields = lib.filter (
        field: builtins.hasAttr field machine && !builtins.isString machine.${field}
      ) stringFields;
      invalidListFields = lib.filter (
        field: builtins.hasAttr field machine && !builtins.isList machine.${field}
      ) [ "roles" "profiles" ];
      emptyFields = lib.filter (
        field: builtins.hasAttr field machine && builtins.isString machine.${field} && machine.${field} == ""
      ) [ "hostname" "username" ];
      rawArchitectures = machine.architectures or [ machine.system ];
      validArchitectureList = builtins.isList rawArchitectures;
      declaredArchitectures = if validArchitectureList then rawArchitectures else [ ];
      invalidArchitectures = lib.filter (
        system: !(builtins.elem system architectures.supported)
      ) declaredArchitectures;
      hostModule = hostsDir + "/${name}";
    in
    assert lib.assertMsg (missingFields == [ ])
      "Host '${name}' is missing required identity field(s): ${lib.concatStringsSep ", " missingFields}";
    assert lib.assertMsg (invalidStringFields == [ ])
      "Host '${name}' has non-string identity field(s): ${lib.concatStringsSep ", " invalidStringFields}";
    assert lib.assertMsg (invalidListFields == [ ])
      "Host '${name}' has non-list identity field(s): ${lib.concatStringsSep ", " invalidListFields}";
    assert lib.assertMsg (emptyFields == [ ])
      "Host '${name}' has empty identity field(s): ${lib.concatStringsSep ", " emptyFields}";
    assert lib.assertMsg validArchitectureList
      "Host '${name}' must declare architectures as a list";
    assert lib.assertMsg (declaredArchitectures != [ ])
      "Host '${name}' must declare at least one architecture";
    assert lib.assertMsg (invalidArchitectures == [ ])
      "Host '${name}' has unsupported architecture(s): ${lib.concatStringsSep ", " invalidArchitectures}. Supported architectures: ${lib.concatStringsSep ", " architectures.supported}";
    assert lib.assertMsg (lib.unique declaredArchitectures == declaredArchitectures)
      "Host '${name}' must not declare duplicate architectures";
    assert lib.assertMsg (builtins.elem machine.system declaredArchitectures)
      "Host '${name}' must include its primary system '${machine.system}' in architectures";
    assert lib.assertMsg (builtins.pathExists (hostModule + "/default.nix"))
      "Host '${name}' must provide hosts/${name}/default.nix";
    {
      inherit machine hostModule;
    }
  );

  hostPairs = map (
    name: {
      host = name;
      hostname = definitions.${name}.machine.hostname;
    }
  ) hostNames;
  hostnames = map (pair: pair.hostname) hostPairs;
  duplicateHostnames = lib.unique (
    lib.filter (
      hostname: builtins.length (lib.filter (candidate: candidate == hostname) hostnames) > 1
    ) hostnames
  );
  aliasCollisions = lib.filter (
    pair: builtins.elem pair.hostname hostNames && pair.hostname != pair.host
  ) hostPairs;
in
assert lib.assertMsg (duplicateHostnames == [ ])
  "Duplicate host hostname(s): ${lib.concatStringsSep ", " duplicateHostnames}";
assert lib.assertMsg (aliasCollisions == [ ])
  "Hostname alias collides with host directory name(s): ${lib.concatStringsSep ", " (map (pair: "${pair.host} -> ${pair.hostname}") aliasCollisions)}";
assert lib.assertMsg (builtins.elem "machine" hostNames)
  "The production host 'machine' must exist under hosts/machine/";
{
  # Keep host discovery deterministic and make the available host names inspectable.
  available = hostNames;

  # The production host is explicit rather than inferred from an arbitrary definition.
  default = "machine";

  inherit definitions;
}
