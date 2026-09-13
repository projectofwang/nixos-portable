# nixos-portable

NixOS flake for managing reusable hosts, profiles, roles, hardware, Home Manager, multi-architecture checks, and a small deployment CLI.

## Quick start

```bash
git clone https://github.com/projectofwang/nixos-portable.git
cd nixos-portable
nix develop
nixos-portable check
nixos-portable build machine
```

Apply the local machine configuration:

```bash
nixos-portable switch machine
```

Deploy the same host definition to another machine:

```bash
nixos-portable deploy machine root@server
```

The CLI can also be run directly from the flake:

```bash
nix run .#nixos-portable -- check
nix run .#nixos-portable -- build machine
```

## Repository layout

```text
.
├── flake.nix
├── flake.lock
├── hardware/                  reusable hardware modules
├── home/                      base Home Manager configuration
├── hosts/                     host identity and machine-specific modules
├── lib/                       framework, validation, host builder, CLI
├── modules/                   reusable NixOS and Home Manager modules
├── profiles/                  optional capabilities
├── roles/                     profile bundles
└── tests/                     framework checks
```

## Hosts

Each host needs:

```text
hosts/<name>/
├── default.nix
└── identity.nix
```

A physical machine normally also has:

```text
hosts/<name>/
└── hardware-configuration.nix
```

Example identity:

```nix
{
  hostname = "nixos";
  username = "chicoarun";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";
  roles = [ "completed" ];
  profiles = [ ];
}
```

Optional `architectures` declares every architecture that the host is allowed to evaluate. It must include the primary `system`.

Host directories are the stable flake targets:

```bash
nixos-portable build machine
nixos-portable switch machine
```

The hostname is also exposed as a flake alias for compatibility.

## Roles and profiles

A **profile** adds one capability. A **role** expands to a reusable profile set.

Current roles:

| Role | Profiles |
|---|---|
| `completed` | **all discovered profiles** |
| `ci` | **all discovered profiles**, evaluated on the hardware-independent CI host |

### `completed` role

`completed` is the full-install role for the main machine. It intentionally follows `profiles.available`:

```nix
{ profiles }:

{
  profiles = profiles.available;
}
```

Therefore the rule is simple:

- **Add** `profiles/foo.nix` → `foo` is automatically included by `completed`.
- **Remove** `profiles/foo.nix` → `foo` is automatically removed from `completed`.
- No second list needs to be maintained in `roles/completed.nix`.

The production machine normally uses:

```nix
roles = [ "completed" ];
profiles = [ ];
```

### Opt out of `completed`

If a machine should install only a selected subset, do not use `completed`. Set roles to an empty list and select profiles explicitly:

```nix
roles = [ ];
profiles = [
  "base"
  "desktop"
  "terminal-ide"
  "hermes-agent"
  "opencode"
];
```

This is the intended mechanism for adding or removing individual capabilities for a specific host. The role provides the default "install everything" behavior; explicit `profiles` provide the override.

### Adding a new profile

For the normal full machine:

1. Create `profiles/<name>.nix`.
2. Add architecture restrictions in `lib/profiles.nix` only if needed.
3. Keep the machine on `roles = [ "completed" ]`.
4. The new profile is automatically selected on the next evaluation.

For a selective host, add the profile name to that host's `profiles` list instead.

Current profiles:

| Profile | Purpose | Architectures |
|---|---|---|
| `ai` | llama.cpp Vulkan tools | x86_64, aarch64 |
| `base` | core NixOS system | x86_64, aarch64 |
| `bitwarden` | Bitwarden Desktop | x86_64, aarch64 |
| `desktop` | Umbriel, Noctalia, PipeWire, Flatpak | x86_64, aarch64 |
| `downloads` | qBittorrent | x86_64, aarch64 |
| `firefox` | Firefox and browser Wayland integration | x86_64, aarch64 |
| `gaming` | Steam, GameMode, MangoHud | x86_64 |
| `helium` | Helium browser integration | x86_64 |
| `hermes-agent` | Hermes Agent | x86_64, aarch64 |
| `keepassxc` | KeePassXC | x86_64, aarch64 |
| `media` | mpv, mpvpaper, VLC, Stremio | x86_64, aarch64 |
| `opencode` | OpenCode coding agent | x86_64, aarch64 |
| `signal` | Signal Desktop | x86_64, aarch64 |
| `telegram` | Telegram Desktop | x86_64, aarch64 |
| `terminal` | WezTerm, Zellij, terminal tools | x86_64, aarch64 |
| `terminal-ide` | terminal + LazyVim | x86_64, aarch64 |
| `thunderbird` | Thunderbird | x86_64, aarch64 |
| `umbriel` | Umbriel desktop environment integration | x86_64, aarch64 |
| `vesktop` | Vesktop | x86_64, aarch64 |
| `vietnamese-input` | Vietnamese input support | x86_64, aarch64 |

Profiles are discovered automatically from `profiles/*.nix`. Architecture compatibility is declared centrally in `lib/profiles.nix`.

## Hermes Agent and OpenCode

The `completed` role includes `hermes-agent` and `opencode` automatically because they are profiles in the discovered set.

Verify them after switching:

```bash
hermes --version
opencode --version
```

Start Hermes:

```bash
hermes
```

Initial Hermes provider/model setup:

```bash
hermes model
```

Start OpenCode in a repository:

```bash
cd /path/to/project
opencode
```

These profiles install the agents but do not impose provider, model, API-key, or agent-behavior configuration.

## Hardware

Machine-specific hardware belongs under `hosts/<name>/`. Reusable hardware implementations belong under `hardware/`.

Example:

```text
hardware/gpu/amd/rx580-2048sp.nix
hosts/machine/gpu.nix
```

The host selects the reusable implementation; profiles should not contain physical-device assumptions.

## Supported architectures

- `x86_64-linux`
- `aarch64-linux`

`gaming` and `helium` are currently restricted to `x86_64-linux`.

## CI

The framework generates a matrix from:

```text
host × architecture × compatible profile
```

GitHub Actions evaluates the framework, validates the flake, checks formatting, validates the CLI, and evaluates every compatible matrix entry as a dry-run build plan.

The `ci` role also follows `profiles.available`, so a newly added profile automatically becomes part of the CI profile surface.

Run the same checks locally:

```bash
nixos-portable check
nix flake check --no-write-lock-file
```

Framework-specific tests:

```bash
nix build .#checks.x86_64-linux.framework-tests --no-link --no-write-lock-file
```

## Add a machine

1. Create the host directory.
2. Add `identity.nix`.
3. Add `default.nix`.
4. Generate hardware facts on the target machine.
5. Use `roles = [ "completed" ]` for the full profile set, or `roles = [ ];` plus explicit `profiles` for a selective machine.
6. Validate before switching.

Example:

```bash
mkdir -p hosts/laptop
sudo nixos-generate-config --show-hardware-config > hosts/laptop/hardware-configuration.nix
```

Then create `hosts/laptop/identity.nix` and `hosts/laptop/default.nix`.

Validate:

```bash
nixos-portable check
nixos-portable build laptop
```

Apply locally:

```bash
nixos-portable switch laptop
```

## Development

Enter the repository development shell:

```bash
nix develop
```

Available tools include `nil`, `nixfmt`, `statix`, `pre-commit`, and `nixos-portable`.

Run formatting checks:

```bash
nix fmt --no-write-lock-file -- --check $(git ls-files '*.nix')
```

Run pre-commit:

```bash
pre-commit run --all-files
```

Build the CLI package:

```bash
nix build .#nixos-portable
./result/bin/nixos-portable --help
```

## Updating inputs

Review changes before updating the lockfile:

```bash
nix flake update
nix flake check
```

Commit `flake.lock` together with intentional input updates.
