# Add the user-side Umbriel configuration; for example, this profile is independent from the system desktop implementation.
{ username, ... }:

{
  # Attach Umbriel's Home Manager module to the selected user.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/umbriel.nix
  ];
}
