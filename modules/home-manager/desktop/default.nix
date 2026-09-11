{ inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    settings = {
      plugins.enabled = [
        "noctalia/screen_recorder"
      ];
    };
  };
}
