{
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      lua-language-server
      stylua
      nil
      nixfmt
    ];

    plugins = with pkgs.vimPlugins; [ lazy-nvim ];

    initLua =
      let
        plugins = with pkgs.vimPlugins; [
          lazy-nvim
          LazyVim
        ];
        lazyPath = pkgs.linkFarm "lazyvim-plugins" (
          map (plugin: {
            name = lib.getName plugin;
            path = plugin;
          }) plugins
        );
      in
      ''
        require("lazy").setup({
          dev = {
            path = "${lazyPath}";
            patterns = { "" };
            fallback = true;
          };
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          };
          checker = { enabled = false };
          change_detection = { enabled = false };
        })
      '';
  };
}
