{ inputs, pkgs, ... }:

{
  # Install the pinned Hermes Agent package without changing its provider settings.
  home.packages = [
    inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
