{ username, ... }:

{
  # Optional profile: enable Umbriel for the Home Manager user.
  # Add "umbriel" to hosts/machine/identity.nix when you want this profile.
  home-manager.users.${username}.imports = [
    ../modules/home-manager/umbriel.nix
  ];
}
