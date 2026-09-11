# Configure the Nix daemon baseline; for example, this enables `nix flake` and automatic store maintenance.
{ ... }:

{
  # Disable the legacy nix-channel mechanism because this repository is flake-based.
  nix.channel.enable = false;

  # Enable modern Nix commands and flakes while keeping trust limited to root.
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "root" ];
  };

  # Deduplicate store paths automatically; for example, identical dependencies share one store object.
  nix.optimise.automatic = true;

  # Reclaim old generations weekly; for example, paths older than 30 days are eligible for collection.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
