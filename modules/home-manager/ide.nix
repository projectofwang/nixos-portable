{ pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;
    mutableUserSettings = false;
    extensions = [
      "nix"
      "toml"
      "rust"
    ];
    userSettings = {
      format_on_save = true;
      hour_format = "hour24";
      terminal = {
        working_directory = "current_project_directory";
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      curl
      ripgrep
    ];
    plugins = [
      pkgs.vimPlugins.plenary-nvim
    ];
  };
}
