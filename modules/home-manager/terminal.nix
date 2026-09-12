{ pkgs, ... }:

{
  # Configure the terminal applications owned by this profile.
  programs = {
    # Start WezTerm directly with Zellij.
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

    # Enable Zellij and use Neovim as its scrollback editor.
    zellij = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        pane_frames = false;
        mouse_mode = true;
        copy_on_select = true;
        scrollback_editor = "nvim";
        show_startup_tips = false;
      };
    };
  };

  # Install terminal utilities without owning the Neovim configuration.
  home.packages = with pkgs; [
    btop
    cava
    fastfetch
    jq
    tree
    yazi
  ];
}
