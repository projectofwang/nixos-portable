# Configure graphics capability for the current AMD Polaris card; example: RADV Vulkan and radeonsi VA-API come from the Mesa graphics stack.
{ ... }:

{
  hardware.graphics = {
    # Enable Mesa userspace for OpenGL and Vulkan; example: applications can use RADV without declaring a separate Vulkan driver package.
    enable = true;

    # Keep 32-bit graphics for Steam and other 32-bit workloads; example: legacy game binaries can load the 32-bit Mesa stack.
    enable32Bit = true;
  };

  # Do not add ROCm here: the current ROCm compatibility matrix does not list RX 580/Polaris as a supported Radeon target.
  # Example for a future supported compute GPU: add its ROCm runtime here only when an actual workload requires it.
}
