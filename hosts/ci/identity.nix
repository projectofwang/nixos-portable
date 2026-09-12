{
  hostname = "nixos-portable-ci";
  username = "ci";
  system = "x86_64-linux";
  timeZone = "UTC";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  profiles = [
    "ai"
    "base"
    "bitwarden"
    "desktop"
    "downloads"
    "firefox"
    "gaming"
    "helium"
    "hermes-agent"
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
