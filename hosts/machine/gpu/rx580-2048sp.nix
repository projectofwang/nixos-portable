# Configure graphics capability for the current AMD Polaris card; example: RADV Vulkan and radeonsi VA-API come from the Mesa graphics stack.
{ pkgs, ... }:

{
  hardware.graphics = {
    # Enable Mesa userspace for OpenGL and Vulkan; example: `vulkaninfo` should see the RADV ICD.
    enable = true;

    # Keep 32-bit graphics for Steam and other 32-bit workloads; example: legacy game binaries can load the 32-bit Mesa stack.
    enable32Bit = true;
  };

  # Install Vulkan diagnostics with the machine GPU capability; example: `vulkaninfo --summary` reports the active RADV device and Vulkan API.
  environment.systemPackages = [
    pkgs.vulkan-tools
  ];

  # Do not add ROCm here: the current ROCm compatibility matrix does not list RX 580/Polaris as a supported Radeon target.
  # Example for a future supported compute GPU: add its ROCm runtime here only when an actual workload requires it.
}
