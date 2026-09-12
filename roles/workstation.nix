{ profiles }:

{
  # Expand the workstation role to every currently available profile.
  profiles = profiles.available;
}
