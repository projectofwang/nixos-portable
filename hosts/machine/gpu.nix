{ ... }:

{
  # Select the reusable GPU implementation for this host.
  imports = [
    ../../hardware/gpu/amd/rx580-2048sp.nix
  ];
}
