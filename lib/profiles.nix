# Discover profile files automatically; for example, `profiles/terminal.nix` becomes the selectable profile `terminal`.
{ lib }:

let
  profileFiles = builtins.readDir ../profiles;
  available = map (name: lib.removeSuffix ".nix" name) (
    lib.filter (name: profileFiles.${name} == "regular" && lib.hasSuffix ".nix" name) (
      builtins.attrNames profileFiles
    )
  );
in
{
  # Expose the discovered profile names for validation and diagnostics.
  inherit available;

  # Reject typos before NixOS composition; for example, `terminal-idee` fails with the available profile list.
  validate =
    selected:
    let
      unknown = lib.filter (profile: !(builtins.elem profile available)) selected;
    in
    assert lib.assertMsg (unknown == [ ])
      "Unknown profile(s): ${lib.concatStringsSep ", " unknown}. Available profiles: ${lib.concatStringsSep ", " available}";
    selected;
}
