# Discover host definitions from `hosts/*/identity.nix` so the framework can scale to multiple machines.
{ lib }:

let
  hostsDir = ../hosts;
  entries = builtins.readDir hostsDir;
  directories = lib.filterAttrs (_: type: type == "directory") entries;
  names = builtins.attrNames directories;
  hostNames = lib.filter (
    name: builtins.pathExists (hostsDir + "/${name}/identity.nix")
  ) names;
in
{
  # Keep host discovery deterministic and make the available host names inspectable.
  available = hostNames;

  # Each host supplies only identity and its machine module directory. Hardware and
  # software composition remain inside that host and the shared framework.
  definitions = lib.genAttrs hostNames (
    name: {
      machine = import (hostsDir + "/${name}/identity.nix");
      hostModule = hostsDir + "/${name}";
    }
  );
}
