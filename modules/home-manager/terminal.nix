# Configure terminal applications only; for example, WezTerm starts directly into Zellij while CLI tools remain user-scoped.
{ pkgs, ... }:

{
  # Keep terminal applications declarative and separate from the shell implementation.
  programs = {
    # Start each terminal window with Zellij as the default program.
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

    # Provide terminal multiplexing and make Neovim the scrollback editor when the IDE profile is enabled.
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

  # Install terminal utilities without owning the Neovim package itself; for example, `btop` and `yazi` remain optional with this profile.
  home.packages = with pkgs; [
    btop
    cava
    fastfetch
    jq
    tree
    yazi
  ];
}
