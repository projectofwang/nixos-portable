{ ... }:

{
  # Reuse the shared browser integration for Firefox.
  imports = [
    ../modules/nixos/browser
  ];

  # Enable Firefox for hosts using this profile.
  programs.firefox.enable = true;
}
