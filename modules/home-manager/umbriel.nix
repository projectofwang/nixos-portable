{ inputs, ... }:

{
  imports = [
    inputs.umbriel.homeModules.default
  ];

  programs.umbriel = {
    enable = true;
    settings = ./umbriel/config.toml;
  };
}
