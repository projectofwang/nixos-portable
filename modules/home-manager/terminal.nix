{ pkgs, ... }:

{
  # Terminal stack:
  # Umbriel -> WezTerm -> Zellij -> Zsh / Neovim / CLI tools
  programs = {
    wezterm = {
      enable = true;
      extraConfig = ''
        return {
          default_prog = { "${pkgs.zellij}/bin/zellij" },
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

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  # Tools not already provided by the shell module.
  home.packages = with pkgs; [
    btop
    cava
    fastfetch
    jq
    tree
    yazi
  ];
}
