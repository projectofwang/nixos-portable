{ inputs, lib, home-manager }:

{
  profiles = import ./profiles.nix { inherit lib; };
  inherit (import ./mk-host.nix { inherit inputs lib home-manager profiles; }) mkHost;
}
