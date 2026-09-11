# Install media applications only when requested; for example, `media` provides mpv, mpvpaper, VLC, and Stremio.
{ username, pkgs, ... }:

{
  # Scope the Stremio package's unfree requirement to this optional profile.
  nixpkgs.config.allowUnfreePackages = [
    "stremio-linux-shell"
  ];

  # Install media applications into the user's Home Manager environment.
  home-manager.users.${username}.home.packages = with pkgs; [
    mpv
    mpvpaper
    vlc
    stremio-linux-shell
  ];
}
