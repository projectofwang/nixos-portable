{ inputs, ... }:

{
  # Load the user-side Umbriel module from the pinned input.
  imports = [
    inputs.umbriel.homeModules.default
  ];

  # Use the repository-owned Umbriel configuration as the declarative source.
  programs.umbriel = {
    enable = true;
    settings = ./umbriel/config.toml;
  };
}
