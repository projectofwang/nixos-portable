{
  inputs,
  lib,
  home-manager,
}:

let
  profiles = import ./profiles.nix { inherit lib; };
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
  inherit profiles;
  inherit (host) mkHost;
}
