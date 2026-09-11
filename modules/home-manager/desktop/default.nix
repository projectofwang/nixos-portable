# Enable Noctalia's user-side screen recorder plugin; for example, the plugin exposes its own IPC service to the desktop.
{ inputs, ... }:

{
  # Import the Noctalia Home Manager module from the pinned flake input.
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Keep the screen recorder declarative and available only with the desktop profile.
  programs.noctalia = {
    enable = true;
    settings = {
      plugins.enabled = [
        "noctalia/screen_recorder"
      ];
    };
  };
}
