# Provide a development shell with formatting, diagnostics, and the repository CLI.
{ inputs, machine, ... }:

let
  pkgs = import inputs.nixpkgs {
    system = machine.system;
  };
  nixos-portable = import ./cli.nix {
    inherit pkgs;
  };
in
pkgs.mkShell {
  packages = with pkgs; [
    alejandra
    nil
    nixfmt-rfc-style
    statix
    nixos-portable
  ];
}
