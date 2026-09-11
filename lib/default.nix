# Build the reusable host framework; for example, `mkHost` consumes the validated profile set created here.
{
  inputs,
  lib,
  home-manager,
}:

let
  # Discover and validate profile names before host composition.
  profiles = import ./profiles.nix { inherit lib; };

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
  # Export the profile registry and host builder to the flake composition root.
  inherit profiles;
  inherit (host) mkHost;
}
