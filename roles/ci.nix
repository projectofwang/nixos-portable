{ profiles }:

{
  # Expand the CI role to the full discovered profile surface.
  profiles = profiles.available;
}
