# Define the Home Manager identity; for example, `username = "alice"` maps to `/home/alice`.
{
  lib,
  username,
  homeStateVersion ? "26.05",
  ...
}:

{
  # Set the user's account name and home path from machine identity.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Keep Home Manager state compatibility explicit; for example, a migration can change this deliberately.
  home.stateVersion = lib.mkDefault homeStateVersion;
}
