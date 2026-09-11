{
  hostname = "nixos";
  username = "chicoarun";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";
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
