{ ... }:

{
  # CI is a containerized evaluation target; machine identity is supplied by flake.nix.
  boot.isContainer = true;

  # NixOS still requires an explicit root filesystem for evaluation.
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };
}
