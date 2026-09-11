# Install only system-wide base tools; for example, Git is available before any optional profile is enabled.
{ pkgs, ... }:

{
  # Keep the base system minimal and place feature-specific applications in profiles.
  environment.systemPackages = with pkgs; [
    git
  ];
}
