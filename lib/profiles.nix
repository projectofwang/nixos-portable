{ lib }:

let
  profileFiles = builtins.readDir ../profiles;
in
{
  available = map (name: lib.removeSuffix ".nix" name) (
    lib.filter (name: profileFiles.${name} == "regular" && lib.hasSuffix ".nix" name) (
      builtins.attrNames profileFiles
    )
  );

  validate =
    selected:
    let
      unknown = lib.filter (profile: !(builtins.elem profile available)) selected;
    in
    assert lib.assertMsg (unknown == [ ])
      "Unknown profile(s): ${lib.concatStringsSep ", " unknown}. Available profiles: ${lib.concatStringsSep ", " available}";
    selected;
}
