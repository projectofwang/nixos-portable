# Reusable graphics module for AMD Polaris-class GPUs such as the RX 580 2048SP.
{ ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
