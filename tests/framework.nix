{ lib }:

let
  architectures = import ../lib/architectures.nix { inherit lib; };
  profiles = import ../lib/profiles.nix { inherit lib; };
  roles = import ../lib/roles.nix { inherit lib profiles; };
  hosts = import ../lib/hosts.nix { inherit lib architectures; };

  expectedRoles = [
    "ci"
    "completed"
  ];
in
assert lib.assertMsg (builtins.tryEval (architectures.validate "x86_64-linux")).success
  "x86_64-linux must be a supported architecture";
assert lib.assertMsg (builtins.tryEval (architectures.validate "aarch64-linux")).success
  "aarch64-linux must be a supported architecture";
assert lib.assertMsg (
  !(builtins.tryEval (architectures.validate "riscv64-linux")).success
) "unsupported architectures must be rejected";

# Profiles are discovered from profiles/*.nix. The framework must accept the
# complete discovered inventory without maintaining a second hard-coded list.
assert lib.assertMsg (
  profiles.validate profiles.available == profiles.available
) "all discovered profiles must validate";
assert lib.assertMsg (
  !(builtins.tryEval (profiles.validate [ "does-not-exist" ])).success
) "unknown profiles must be rejected";

assert lib.assertMsg (
  lib.sort builtins.lessThan roles.available == lib.sort builtins.lessThan expectedRoles
) "discovered roles must exactly match the expected inventory";
assert lib.assertMsg (
  roles.validate expectedRoles == expectedRoles
) "all expected roles must validate";
assert lib.assertMsg (
  !(builtins.tryEval (roles.validate [ "does-not-exist" ])).success
) "unknown roles must be rejected";

# `completed` is the full-install role: adding a profile automatically adds it
# to every host using this role. Removing a profile removes it from the role.
assert lib.assertMsg (
  roles.roleDefinitions.completed == profiles.available
) "completed role must always cover every discovered profile";

# CI intentionally follows the same dynamic profile surface. Its host remains
# hardware-independent, so it can evaluate each discovered profile safely.
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
