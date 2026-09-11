{ username, lib, pkgs, ... }:

{
  # Optional entertainment stack. It is intentionally not part of desktop.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "stremio-linux-shell"
  ];

  home-manager.users.${username}.home.packages = with pkgs; [
    mpv
    mpvpaper
    vlc
    stremio-linux-shell
  ];
}
