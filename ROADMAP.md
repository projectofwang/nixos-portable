# NixOS Portable Hardening Roadmap

Canonical project plan: GitHub issue #3, covering `nixos-portable` and `helium-nix`.

## Workstreams

1. **Architecture & Nix framework** — host/profile/role/architecture contracts.
2. **Helium packaging** — binary provenance, architecture support, ELF/runtime dependencies.
3. **Module API** — NixOS/Home Manager package, flags, and policy semantics.
4. **CI / supply chain** — least privilege, pinned actions, deterministic checks.
5. **QA / integration** — x86_64 + aarch64 evaluation/build and runtime smoke tests.
6. **Documentation** — implementation and operational contract stay synchronized.

## Roadmap

### Phase 1 — Framework hardening

- Remove unnecessary GitHub Actions permissions.
- Keep `gaming` x86_64-only.
- Allow the `helium` profile on both supported architectures.
- Add regression tests for profile architecture contracts.

### Phase 2 — Helium packaging

- Preserve fixed source hashes and binary provenance.
- Add package checks for x86_64-linux and aarch64-linux.
- Add a sandboxed `helium --version` smoke test.
- Review runtime dependencies conservatively; do not remove libraries without evidence.

### Phase 3 — Module API

- Make `programs.helium.package` independent of package-specific `flags` overrides.
- Validate policies as JSON-compatible Nix values.
- Keep NixOS and Home Manager policy behavior explicit.
- Correct default-package documentation for standalone module consumption.

### Phase 4 — Integration / CI

- Test both NixOS and Home Manager modules.
- Keep actions pinned and permissions minimal.
- Add Nix-specific static checks only when deterministic and useful.
- Verify the parent flake consumes the Helium package/module cleanly.

### Phase 5 — Final audit

- Re-audit every changed file.
- Search for deprecated `stdenv.isLinux` / `stdenv.isDarwin` usage.
- Remove stale documentation references.
- Mark every roadmap item complete or explicitly deferred.

## Definition of done

- Framework tests pass.
- Both declared architectures evaluate/build where supported.
- NixOS and Home Manager modules evaluate.
- `helium --version` passes the smoke test.
- CI is least-privilege and actions remain pinned.
- Fixed-source integrity is preserved.
- Documentation matches the implementation.
