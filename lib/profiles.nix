# Discover profile files automatically and define their architecture compatibility.
{ lib }:

let
  profileFiles = builtins.readDir ../profiles;
  available = map (name: lib.removeSuffix ".nix" name) (
    lib.filter (name: profileFiles.${name} == "regular" && lib.hasSuffix ".nix" name) (
      builtins.attrNames profileFiles
    )
  );

  # Most profiles are architecture-neutral. Profiles that consume software with a
  # narrower platform contract are explicitly limited here instead of making the
  # whole CI matrix fail on unsupported targets.
  architectureOverrides = {
    gaming = [ "x86_64-linux" ];
    helium = [ "x86_64-linux" ];
  };

  architecturesFor = profile: architectureOverrides.${profile} or [ "x86_64-linux" "aarch64-linux" ];

  validate =
    selected:
    let
      unknown = lib.filter (profile: !(builtins.elem profile available)) selected;
    in
    assert lib.assertMsg (unknown == [ ])
      "Unknown profile(s): ${lib.concatStringsSep ", " unknown}. Available profiles: ${lib.concatStringsSep ", " available}";
    assert lib.assertMsg (lib.all builtins.isString selected)
      "Profile selections must be strings";
    selected;
in
{
  # Expose the discovered profile names for validation and diagnostics.
  inherit available architecturesFor;

  # Reject typos before NixOS composition; for example, `terminal-idee` fails with the available profile list.
  inherit validate;
}
