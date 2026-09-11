# Add Firefox and the shared browser/graphics integration; for example, Firefox receives Wayland and VA-API diagnostics from the browser module.
{ ... }:

{
  # Reuse browser-specific system integration.
  imports = [
    ../modules/nixos/browser
  ];

  # Install Firefox as the browser implementation for this profile.
  programs.firefox.enable = true;
}
