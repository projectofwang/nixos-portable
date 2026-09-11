{ lib, pkgs, ... }:

{
  programs.neovim = {
    extraPackages = with pkgs; [
      lua-language-server
      stylua
      nil
      nixfmt
    ];

    # Keep the LazyVim bootstrap reproducible from nixpkgs while allowing
    # LazyVim to manage its own plugin graph. This avoids a second flake input.
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
