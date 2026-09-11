# Add the desktop system stack; for example, this profile is the switch that turns on Umbriel, Noctalia, PipeWire, and the greeter.
{ ... }:

{
  imports = [
    # Import the reusable desktop system implementation.
    ../modules/nixos/desktop
  ];
}
