# Build the reusable host framework; for example, `mkHost` consumes validated identity, roles, profiles, and architectures.
{
  inputs,
  lib,
  home-manager,
}:

let
  profiles = import ./profiles.nix { inherit lib; };
  roles = import ./roles.nix { inherit lib profiles; };
  architectures = import ./architectures.nix { inherit lib; };
  hosts = import ./hosts.nix { inherit lib; };

  host = import ./mk-host.nix {
    inherit
      inputs
      lib
      home-manager
      profiles
      roles
      architectures
      ;
  };
in
{
  inherit
    profiles
    roles
    architectures
    hosts
    ;
  inherit (host) mkHost mkProfileHost;
}
