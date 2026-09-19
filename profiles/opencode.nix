{ pkgs, ... }:

{
  # Manage OpenCode through NixOS without enabling its server.
  imports = [
    ../nixos/opencode.nix
  ];

  programs.opencode.enable = true;

  # Nixpkgs 1.18.30 builds OpenCode with Bun 1.4.2 and is affected by the
  # upstream compiled filesystem dependency cycle (anomalyco/opencode#48397).
  # Apply the upstream patch until it lands in the nixpkgs package.
  # Re-check on every `nix flake update`: if upstream fixed it, drop this override.
  programs.opencode.package = pkgs.opencode.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      patch -p1 < ${../patches/opencode-compiled-filesystem-cycle.patch}
    '';
  });
}
