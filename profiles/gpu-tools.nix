# Provide optional GPU diagnostics without coupling them to machine hardware; for example, this profile supplies Vulkan and VA-API inspection tools.
{ pkgs, ... }:

{
  # Install GPU inspection tools for interactive troubleshooting; example: `vulkaninfo --summary` and `vainfo` report active graphics/video drivers.
  environment.systemPackages = with pkgs; [
    libva-utils
    vulkan-tools
  ];
}
