{ ... }:

{
  # Keep the baseline Home Manager import limited to the shared shell layer.
  imports = [
    ./shell.nix
  ];
}
