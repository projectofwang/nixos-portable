# Install Hermes Agent without configuring providers, models, or agent behavior.
{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.hermes-agent.packages.${pkgs.system}.default
  ];
}
