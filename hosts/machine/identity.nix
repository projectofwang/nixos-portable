{
  # This is the only file you need to edit when moving the configuration
  # to a new machine.
  hostname = "nixos"; # Change this on a new machine if you want a different hostname.
  username = "chicoarun"; # Change this on a new machine if you want a different username.
  system = "x86_64-linux"; # Change this if the architecture differs.
  timeZone = "Asia/Ho_Chi_Minh";

  # Keep these at the release used when the machine was first configured.
  # Do not bump them just because nixpkgs is updated.
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  # Add or remove optional feature profiles here.
  profiles = [
    "base"
    "desktop"
    "terminal"
    "gaming"
    "ai"
    "ide"
    "umbriel"
    "vietnamese-input"
  ];
}
