# Select the reusable hardware implementation required by this host.
{ ... }:

{
  imports = [
    ../../hardware/gpu/amd/rx580-2048sp.nix
  ];
}
