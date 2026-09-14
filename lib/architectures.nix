{ lib }:

let
  # Keep the framework architecture contract in one registry.
  supported = [
    "x86_64-linux"
  ];
in
{
  inherit supported;

  validate =
    system:
    assert lib.assertMsg (builtins.elem system supported)
      "Unsupported system '${system}'. Supported systems: ${lib.concatStringsSep ", " supported}";
    system;
}
