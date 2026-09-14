{ profiles }:

let
  # The CI system itself must be buildable on every declared CI architecture.
  # Architecture-specific profiles are exercised separately by the profile matrix.
  universallySupported = profile:
    lib.all (system: builtins.elem system (profiles.architecturesFor profile)) [
      "x86_64-linux"
      "aarch64-linux"
    ];
in
{
  # Expand to the full profile surface shared by both CI architectures.
  profiles = lib.filter universallySupported profiles.available;
}
