{
  lib,
  username,
  homeStateVersion ? "26.05",
  ...
}:

{
  # Derive the Home Manager account and home path from host identity.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Keep the Home Manager compatibility version explicit and overridable.
  home.stateVersion = lib.mkDefault homeStateVersion;
}
