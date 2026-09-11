# Keep the Home Manager baseline small; for example, every user gets the shell environment while IDE and desktop features stay opt-in.
{ ... }:

{
  # Import only the shared shell layer at the baseline.
  imports = [
    ./shell.nix
  ];
}
