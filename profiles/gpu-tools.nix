# Provide optional GPU diagnostics without coupling them to the machine hardware module; example: `vulkaninfo --summary` inspects the active Vulkan stack.
{ pkgs, ... }:

{
  # Install GPU inspection tools for interactive troubleshooting; example: `vulkaninfo --summary` reports the Vulkan device and driver.
  environment.systemPackages = [
    pkgs.vulkan-tools
  ];
}
