# Compose only physical-machine concerns; for example, a new machine can replace these imports without changing profiles.
{ ... }:

{
  imports = [
    # Generated hardware facts belong here; example: filesystem and device declarations from nixos-generate-config.
    ./hardware-configuration.nix
    # Boot policy is machine-specific; example: systemd-boot and EFI variable access.
    ./boot.nix
    # Network policy is machine-specific; example: NetworkManager and local DNS resolver.
    ./networking.nix
    # GPU capability is selected separately; example: `gpu/rx580-2048sp.nix` for the current card.
    ./gpu.nix
  ];
}
