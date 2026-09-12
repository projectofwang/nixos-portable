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
  # Keep development tooling aligned with the repository checks and CLI.
  packages = with pkgs; [
    nil
    nixfmt
    statix
    pre-commit
    nixos-portable
  ];
}
