{ ... }:

{
  # Baseline user environment. Feature-specific GUI/IDE/AI modules are
  # imported by their opt-in profiles.
  imports = [
    ./shell.nix
  ];
}
