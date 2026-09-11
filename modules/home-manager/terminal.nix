{ pkgs, ... }:

{
  programs = {
    wezterm = {
      enable = true;
      extraConfig = ''
        return {
          default_prog = { "${pkgs.zellij}/bin/zellij" },
          window_background_opacity = 0.88,
          text_background_opacity = 1.0,
        }
      '';
    };

    zellij = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        pane_frames = false;
        mouse_mode = true;
        copy_on_select = true;
        scrollback_editor = "nvim";
      };
    };
  };

  home.packages = with pkgs; [
    btop
    cava
    fastfetch
    jq
    tree
    yazi
  ];
}
