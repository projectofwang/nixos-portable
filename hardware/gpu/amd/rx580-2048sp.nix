{ ... }:

{
  # Enable graphics acceleration and 32-bit userspace support for this AMD GPU.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
