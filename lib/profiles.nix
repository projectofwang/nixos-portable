{ lib }:

let
  profileFiles = builtins.readDir ../profiles;
  available = map (name: lib.removeSuffix ".nix" name) (
    lib.filter (name: profileFiles.${name} == "regular" && lib.hasSuffix ".nix" name) (
      builtins.attrNames profileFiles
    )
  );

  # Override the default architecture set only for profiles with narrower support.
  architectureOverrides = {
    gaming = [ "x86_64-linux" ];
  };

  architecturesFor =
    profile:
    architectureOverrides.${profile} or [
      "x86_64-linux"
      "aarch64-linux"
    ];

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
  # Export the discovered profiles and their architecture compatibility rules.
  inherit available architecturesFor;

  # Validate profile selections before host composition starts.
  inherit validate;
}
