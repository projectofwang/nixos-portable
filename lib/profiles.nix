{ lib }:

let
  profileFiles = builtins.readDir ../profiles;
  available = map (name: lib.removeSuffix ".nix" name) (
    lib.filter (name: profileFiles.${name} == "regular" && lib.hasSuffix ".nix" name) (
      builtins.attrNames profileFiles
    )
  );

  architecturesFor = _profile: [ "x86_64-linux" ];

  validate =
    selected:
    let
      unknown = lib.filter (profile: !(builtins.elem profile available)) selected;
    in
    assert lib.assertMsg (unknown == [ ])
      "Unknown profile(s): ${lib.concatStringsSep ", " unknown}. Available profiles: ${lib.concatStringsSep ", " available}";
    assert lib.assertMsg (lib.all builtins.isString selected) "Profile selections must be strings";
    selected;
in
{
  # Profiles are dynamically discovered; the framework currently has one
  # supported system, so every discovered profile targets x86_64-linux.
  inherit available architecturesFor;

  inherit validate;
}
