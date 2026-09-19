# Roadmap

This roadmap tracks stabilization and validation work for `nixos-portable` and `helium-nix`.

Current direction: **stabilization, verification, and operational maturity**, not a framework redesign.

## Current baseline

- Supported architecture: `x86_64-linux`.
- `machine` is the production host; `ci` is the hardware-independent CI host.
- Profiles, roles, and hosts are dynamically discovered and validated.
- CI builds the complete profile matrix.
- DNS intentionally uses a self-hosted resolver without a public fallback.
- No secrets-management framework is installed until an actual requirement exists.
- `architecturesFor` remains a policy abstraction; do not create a redundant per-profile mapping until another architecture is supported.

## Phase 0 — Baseline correctness

### P0.1 — Synchronize `helium-nix`

**Repository:** `nixos-portable`

Update the locked `helium-nix` input to the current stable revision, then verify:

- `nix flake check`
- framework evaluation
- complete profile matrix
- production `machine` build
- resulting Helium package

**Reason:** the lockfile currently lags behind the current `helium-nix` revision.

### P0.2 — Resolve and assert the final polkit policy

**Repository:** `nixos-portable`

Determine the intended desktop behavior explicitly.

Current core policy:

```nix
security.polkit.enable = lib.mkDefault false;
```

The desktop composition does not currently enable polkit explicitly.

Do not rely on comments alone. Establish the intended final evaluated value and add an integration assertion so future module/input changes cannot silently alter it.

### P0.3 — Add a repository license

**Repository:** `nixos-portable`

Choose the license deliberately before adding the file. Do not infer it from `helium-nix`; the repositories may have different licensing terms.

## Phase 1 — Test quality and invariants

### P1.1 — Make the Helium NixOS package test identify the package explicitly

**Repository:** `helium-nix`

Replace positional selection such as `builtins.head environment.systemPackages` with a test that locates the intended package by a stable name/attribute.

**Reason:** adding another system package must not cause the test to validate the wrong derivation.

### P1.2 — Make the Helium Home Manager test execute the package

**Repository:** `helium-nix`

The current Home Manager test checks activation output for a flag string. Replace it with a runtime-oriented test:

1. activate the Home Manager configuration;
2. locate the installed custom package/wrapper;
3. execute it with the test flag;
4. verify successful behavior.

**Reason:** text presence does not prove that the generated wrapper actually works.

### P1.3 — Add final-configuration integration assertions

**Repository:** `nixos-portable`

Keep framework tests separate from integration tests.

Candidate invariants:

- final polkit state;
- PipeWire enabled;
- Flatpak enabled;
- desktop portal configured;
- Noctalia greeter enabled;
- expected hostname;
- expected primary user;
- expected architecture;
- DNS policy;
- Home Manager integration.

Only assert intentional project policy.

## Phase 2 — Operational validation

### P2.1 — Validate the multi-host design with a second host/VM

**Repository:** `nixos-portable`

Add a temporary or VM-based second host when practical.

The goal is to exercise:

```
hosts → roles → profiles → architecture validation → nixosSystem
```

outside the existing production host and CI host.

This validates the framework; it does not require a permanent second machine.

### P2.2 — Add manual version selection to the Helium updater

**Repository:** `helium-nix`

Extend `.github/workflows/update-helium.yml` so `workflow_dispatch` can optionally accept an explicit Helium version.

Desired behavior:

- no version → latest release;
- explicit version → package exactly that release.

### P2.3 — Define a disaster-recovery/backup strategy

**Repository:** primarily `nixos-portable`

Document the distinction between declarative system recovery and user-data recovery.

At minimum document the reinstall/recovery sequence. Introduce restic, Borg, or another backup system only when there is a concrete operational requirement.

### P2.4 — Document the DNS availability/privacy trade-off

**Repository:** `nixos-portable`

Keep the current single-resolver design unless the privacy model changes.

Do not add a public fallback merely for availability. If redundancy becomes necessary, prefer multiple trusted/self-hosted resolvers.

## Phase 3 — Deferred improvements

### P3.1 — Separate role policy from framework tests

Keep generic role validation independent from the current policy:

```
completed = all discovered profiles
ci        = all discovered profiles
```

Do this when a genuinely different role is introduced. No immediate refactor is required.

### P3.2 — Revisit CI scaling

The current full profile matrix provides useful regression coverage.

Do not optimize by changed-file detection while the profile count remains modest. Reassess when matrix size or CI cost becomes material.

### P3.3 — Add secrets management when secrets actually appear

Do not add agenix or sops-nix preemptively.

When a real secret requirement appears:

1. select a secrets-management approach;
2. migrate the secret out of plaintext configuration;
3. add CI checks against accidental plaintext secrets;
4. document recovery.

### P3.4 — Revisit `architecturesFor`

Current implementation:

```nix
architecturesFor = _profile: [ "x86_64-linux" ];
```

This is a valid policy abstraction even though all current profiles have the same architecture set.

Do **not** create a large redundant mapping solely to make the function look more sophisticated.

Revisit when a second architecture is supported or profile-specific architecture constraints become real.

### P3.5 — Independent Helium binary provenance

Optional supply-chain improvement.

If upstream provides independently verifiable checksums or signatures for release artifacts, evaluate whether they should be checked in addition to Nix's fixed-output hash.

This is not a blocker for the current packaging model.

## Recommended execution order

```
1. Sync helium-nix
2. Resolve final polkit policy
3. Add polkit integration assertion
4. Add LICENSE after choosing the license
5. Fix Helium NixOS package test
6. Fix Helium Home Manager runtime test
7. Add nixos-portable integration assertions
8. Verify CI and production build
9. Validate a second host/VM
10. Add updater version input
11. Document/implement backup strategy as required
12. Handle deferred framework and supply-chain improvements
```

## Definition of done

The roadmap is substantially complete when:

- the locked Helium dependency is intentionally current;
- final polkit behavior is explicit and tested;
- both Helium module tests exercise actual package behavior;
- nixos-portable has integration-level assertions for important final configuration invariants;
- a second host/evaluation target has validated the composition model;
- the updater supports controlled version selection;
- recovery and backup expectations are documented;
- deferred items are either implemented when justified or explicitly kept deferred.

## Non-goals

This roadmap does **not** currently call for:

- redesigning the discovery framework;
- adding ARM support without an actual requirement;
- adding public DNS fallbacks;
- adding agenix/sops-nix before secrets are needed;
- optimizing CI around changed files prematurely;
- adding broad hardening unrelated to an identified requirement.
