{
  lib,
  pkgs,
  ...
}:

{
  # Provide the complete Neovim and LazyVim user environment.
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Keep the compiler and language tooling available to the editor.
    extraPackages = with pkgs; [
      gcc
      lua-language-server
      stylua
      nil
      nixfmt
    ];

    # Use the packaged LazyVim bootstrap plugin.
    plugins = with pkgs.vimPlugins; [ lazy-nvim ];

    # Resolve LazyVim plugins from immutable nixpkgs paths instead of downloading them at runtime.
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
