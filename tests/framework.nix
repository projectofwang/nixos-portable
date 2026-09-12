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
    "signal"
    "telegram"
    "terminal"
    "terminal-ide"
  ];

  expectedRoles = [
    "ci"
    "workstation"
  ];
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
assert lib.assertMsg (lib.all (
  profile: builtins.elem profile profiles.available
) expectedProfiles) "all expected profiles must be auto-discovered";
assert lib.assertMsg (succeeds (
  profiles.validate expectedProfiles
)) "all expected profiles must validate";
assert lib.assertMsg (fails (
  profiles.validate [ "does-not-exist" ]
)) "unknown profiles must be rejected";
assert lib.assertMsg (lib.all (
  role: builtins.elem role roles.available
) expectedRoles) "all expected roles must be auto-discovered";
assert lib.assertMsg (succeeds (roles.validate expectedRoles)) "all expected roles must validate";
assert lib.assertMsg (fails (roles.validate [ "does-not-exist" ])) "unknown roles must be rejected";
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
