{ username, pkgs, ... }:

{
  # Allow only the unfree media package required by this profile.
  nixpkgs.config.allowUnfreePackages = [
    "stremio-linux-shell"
  ];

  # Install the media applications into the selected user's environment.
  home-manager.users.${username}.home.packages = with pkgs; [
    mpv
    mpvpaper
    vlc
    stremio-linux-shell
  ];
}
