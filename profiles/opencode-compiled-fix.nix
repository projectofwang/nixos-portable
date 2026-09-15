{ pkgs, ... }:

{
  # Nixpkgs 1.18.30 builds OpenCode with Bun 1.4.2 and is affected by the
  # upstream compiled filesystem dependency cycle (anomalyco/opencode#48397).
  # Apply the upstream patch until it lands in the nixpkgs package.
  programs.opencode.package = pkgs.opencode.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      patch -p1 < ${../patches/opencode-compiled-filesystem-cycle.patch}
    '';
  });
}
