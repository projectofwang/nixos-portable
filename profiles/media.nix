{ username, pkgs, ... }:

{
  nixpkgs.config.allowUnfreePackages = [
    "stremio-linux-shell"
  ];

  home-manager.users.${username}.home.packages = with pkgs; [
    mpv
    mpvpaper
    vlc
    stremio-linux-shell
  ];
}
