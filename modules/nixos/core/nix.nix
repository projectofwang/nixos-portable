{ ... }:

{
  # Disable the legacy channel workflow for this flake-based system.
  nix.channel.enable = false;

  # Enable flakes and the modern Nix command interface.
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "root" ];
  };

  # Deduplicate identical store paths automatically.
  nix.optimise.automatic = true;

  # Run weekly garbage collection and remove generations older than 30 days.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
