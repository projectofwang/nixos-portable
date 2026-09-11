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
  inherit available;

  validate =
    selected:
    let
      unknown = lib.filter (profile: !(builtins.elem profile available)) selected;
      unique = lib.unique selected;
      duplicates = lib.filter (
        profile: builtins.length (lib.filter (p: p == profile) selected) > 1
      ) unique;
    in
    assert lib.assertMsg (unknown == [ ])
      "Unknown profile(s): ${lib.concatStringsSep ", " unknown}. Available profiles: ${lib.concatStringsSep ", " available}";
    assert lib.assertMsg (duplicates == [ ])
      "Duplicate profile(s): ${lib.concatStringsSep ", " duplicates}";
    selected;
}
