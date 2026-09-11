# Select exactly one machine GPU implementation; for example, switch this import to `./gpu/nvidia-rtx-3060.nix` on a future machine.
{ ... }:

{
  imports = [
    ./gpu/rx580-2048sp.nix
  ];
}
