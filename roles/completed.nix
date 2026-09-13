{ profiles }:

{
  # Keep the production role curated so new profiles do not become installed by accident.
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
    "opencode"
    "signal"
    "telegram"
    "terminal"
    "terminal-ide"
    "thunderbird"
    "umbriel"
    "vesktop"
    "vietnamese-input"
  ];

  # Fail evaluation immediately if the curated list references a removed profile.
  _module.args = {
    inherit profiles;
  };
}
