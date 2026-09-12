# Define the architectures supported by the framework; for example, both common Linux NixOS targets are first-class.
{ lib }:

let
  supported = [
    "x86_64-linux"
    "aarch64-linux"
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
