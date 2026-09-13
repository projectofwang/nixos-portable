{ profiles }:

{
  # The completed role always follows the full discovered profile set.
  # Add/remove a profile by creating/removing profiles/<name>.nix.
  profiles = profiles.available;
}
