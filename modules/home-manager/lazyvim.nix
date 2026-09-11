# Own the complete Neovim/LazyVim stack here; for example, the `terminal-ide` profile imports only this editor module.
{
  lib,
  pkgs,
  ...
}:

{
  # Enable Neovim as the default editor and expose both traditional command aliases.
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Keep language tooling next to the editor; for example, `nil` and `nixfmt` support Nix development.
    extraPackages = with pkgs; [
      lua-language-server
      stylua
      nil
      nixfmt
    ];

    # Install the LazyVim bootstrap plugin from nixpkgs.
    plugins = with pkgs.vimPlugins; [ lazy-nvim ];

    # Point LazyVim at immutable nixpkgs plugin paths instead of downloading plugins at runtime.
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
