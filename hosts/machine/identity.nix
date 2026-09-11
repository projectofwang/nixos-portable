# Identify the physical machine; for example, the hostname and user are defined once and all optional profiles are enabled below.
{
  hostname = "nixos";
  username = "chicoarun";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  # Enable every available profile in alphabetical order; for example, rebuilding this host activates the complete workstation feature set.
  profiles = [
    "ai"
    "base"
    "bitwarden"
    "desktop"
    "downloads"
    "firefox"
    "gaming"
    "helium"
    "ide"
    "keepassxc"
    "media"
    "signal"
    "telegram"
    "terminal"
    "terminal-ide"
    "thunderbird"
    "umbriel"
    "vesktop"
    "vietnamese-input"
  ];
}
