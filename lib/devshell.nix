# Provide a development shell with the repository's authoritative formatter, linter, diagnostics, and CLI.
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
    nil
    nixfmt
    statix
    pre-commit
    nixos-portable
  ];
}
