# Provide a development shell with Nix tooling; for example, `nix develop` gives nixfmt, alejandra, nil, and statix.
{ inputs, machine, ... }:

let
  pkgs = import inputs.nixpkgs {
    system = machine.system;
  };
in
pkgs.mkShell {
  packages = with pkgs; [
    alejandra
    nil
    nixfmt-rfc-style
    statix
  ];
}
