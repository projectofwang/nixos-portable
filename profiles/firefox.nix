# Add Firefox and the shared browser integration; for example, Firefox uses the native Wayland environment from the browser module.
{ ... }:

{
  # Reuse browser-specific system integration.
  imports = [
    ../modules/nixos/browser
  ];

  # Enable Firefox for this profile.
  programs.firefox.enable = true;
}
