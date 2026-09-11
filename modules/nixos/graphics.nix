{ ... }:

{
  # Shared graphics capability for profiles that need accelerated Wayland,
  # Vulkan, video decode, or 32-bit graphics runtimes.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
