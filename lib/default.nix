# Build the reusable host framework; for example, `mkHost` consumes validated profiles and host definitions.
{
  inputs,
  lib,
  home-manager,
}:

let
  # Discover and validate profile names before host composition.
  profiles = import ./profiles.nix { inherit lib; };

  # Discover every host directory that contains an identity definition.
  hosts = import ./hosts.nix { inherit lib; };

  # Construct a NixOS system from machine identity, modules, and selected profiles.
  host = import ./mk-host.nix {
    inherit
      inputs
      lib
      home-manager
      profiles
      ;
  };
in
{
  # Export registries and the host builder to the flake composition root.
  inherit profiles hosts;
  inherit (host) mkHost;
}
