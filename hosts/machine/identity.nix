# Identify the physical machine and select its optional capabilities; for example, moving to another GPU changes this machine layer.
{
  hostname = "nixos";
  username = "chicoarun";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  # Keep the production feature set in one place; for example, remove `gaming` to build without Steam.
  profiles = [
    "base"
    "desktop"
    "terminal"
    "terminal-ide"
    "gaming"
    "ai"
    "ide"
    "umbriel"
    "vietnamese-input"
  ];
}
