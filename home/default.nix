# Define the Home Manager identity; for example, `username = "alice"` maps to `/home/alice`.
{ username, homeStateVersion, ... }:

{
  # Set the user's account name and home path from machine identity.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Keep Home Manager state compatibility explicit; for example, a migration can change this deliberately.
  home.stateVersion = homeStateVersion;
}
