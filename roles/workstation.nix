# Define the workstation role as the complete reusable workstation profile set.
{ profiles }:

{
  inherit (profiles) available;
  profiles = profiles.available;
}
