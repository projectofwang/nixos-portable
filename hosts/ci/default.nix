{ ... }:

{
  # CI is a containerized evaluation target; machine identity is supplied by flake.nix.
  boot.isContainer = true;
}
