{ inputs, ... }:

{
  # Load the Noctalia Home Manager module from the pinned input.
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Enable the screen recorder plugin only for desktop users.
  programs.noctalia = {
    enable = true;
    settings = {
      plugins.enabled = [
        "noctalia/screen_recorder"
      ];
    };
  };
}
