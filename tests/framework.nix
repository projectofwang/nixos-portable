{ lib }:

let
  architectures = import ../lib/architectures.nix { inherit lib; };
  profiles = import ../lib/profiles.nix { inherit lib; };
  roles = import ../lib/roles.nix { inherit lib profiles; };
  hosts = import ../lib/hosts.nix { inherit lib architectures; };

  succeeds = expression: (builtins.tryEval expression).success;
  fails = expression: !(builtins.tryEval expression).success;

  expectedProfiles = [
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

  expectedRoles = [
    "ci"
    "completed"
  ];

  expectedCompletedProfiles = expectedProfiles;
in
assert lib.assertMsg (succeeds (
  architectures.validate "x86_64-linux"
)) "x86_64-linux must be a supported architecture";
assert lib.assertMsg (succeeds (
  architectures.validate "aarch64-linux"
)) "aarch64-linux must be a supported architecture";
assert lib.assertMsg (fails (
  architectures.validate "riscv64-linux"
)) "unsupported architectures must be rejected";

# Keep the discovered profile inventory explicit so new files cannot silently
# change the framework contract without updating this test.
assert lib.assertMsg (
  lib.sort builtins.lessThan profiles.available == lib.sort builtins.lessThan expectedProfiles
) "discovered profiles must exactly match the expected inventory";
assert lib.assertMsg (succeeds (
  profiles.validate expectedProfiles
)) "all expected profiles must validate";
assert lib.assertMsg (fails (
  profiles.validate [ "does-not-exist" ]
)) "unknown profiles must be rejected";

assert lib.assertMsg (
  lib.sort builtins.lessThan roles.available == lib.sort builtins.lessThan expectedRoles
) "discovered roles must exactly match the expected inventory";
assert lib.assertMsg (succeeds (roles.validate expectedRoles)) "all expected roles must validate";
assert lib.assertMsg (fails (roles.validate [ "does-not-exist" ])) "unknown roles must be rejected";
assert lib.assertMsg (
  roles.roleDefinitions.completed == expectedCompletedProfiles
) "completed role must remain a curated copy of the expected production profiles";
assert lib.assertMsg (
  roles.roleDefinitions.ci == profiles.available
) "ci role must cover every discovered profile";

assert lib.assertMsg (builtins.elem "machine" hosts.available)
  "machine must be discovered as a host";
assert lib.assertMsg (builtins.elem "ci" hosts.available) "ci must be discovered as a host";
assert lib.assertMsg (
  hosts.default == "machine"
) "machine must remain the explicit production host";
assert lib.assertMsg (
  hosts.definitions.ci.machine.architectures == [
    "x86_64-linux"
    "aarch64-linux"
  ]
) "ci must cover both supported architectures";
true
