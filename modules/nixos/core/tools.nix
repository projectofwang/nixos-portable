# Install common command-line and diagnostic tools; for example, Git, wget, iperf3, vulkaninfo, and vainfo are available on every host.
{ pkgs, ... }:

{
  # Keep universally useful tools in the base layer; feature-specific applications remain in profiles.
  environment.systemPackages = with pkgs; [
    git
    wget
    iperf3
    vulkan-tools
    libva-utils
  ];
}
