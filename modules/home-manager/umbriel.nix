# Enable Umbriel's user configuration; for example, the compositor reads its declarative settings from `umbriel/config.toml`.
{ inputs, ... }:

{
  # Import the user-side Umbriel module from the pinned flake input.
  imports = [
    inputs.umbriel.homeModules.default
  ];

  # Point Umbriel at the repository-owned runtime configuration instead of mutable user state.
  programs.umbriel = {
    enable = true;
    settings = ./umbriel/config.toml;
  };
}
