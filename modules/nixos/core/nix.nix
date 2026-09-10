{ ... }:

{
  # The flake is the source of truth; do not use NixOS channels.
  nix.channel.enable = false;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Keep the trust boundary small. sudo/root is sufficient for rebuilds.
    trusted-users = [ "root" ];
  };

  nix.optimise.automatic = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
