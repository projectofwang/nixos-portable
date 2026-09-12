{ pkgs, ... }:

{
  # Keep diagnostic and version-control tools available on every host.
  environment.systemPackages = with pkgs; [
    git
    wget
    iperf3
    vulkan-tools
    libva-utils
  ];
}
