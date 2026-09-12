{ ... }:

{
  # Keep physical-machine modules isolated from reusable profiles.
  imports = [
    # Keep hardware facts generated for this machine with the host.
    ./hardware-configuration.nix
    # Keep bootloader settings specific to the physical machine.
    ./boot.nix
    # Keep local network policy specific to the physical machine.
    ./networking.nix
    # Select the reusable GPU implementation for this machine.
    ./gpu.nix
  ];
}
