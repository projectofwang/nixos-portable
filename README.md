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
| `completed` | curated production profile set listed below |
| `ci` | every discovered profile, evaluated on the hardware-independent CI host |

The `completed` role is intentionally **curated**. Adding a new file under `profiles/` does not automatically install that profile on the production machine; add it to `roles/completed.nix` deliberately when it is ready.

The `ci` role remains dynamic and follows `profiles.available`, so framework checks cover newly discovered profiles.

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

### Select profiles directly

For a host that should not use the full completed role:

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

## Hermes Agent and OpenCode

The completed role currently includes both `hermes-agent` and `opencode`.

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

Run the same checks locally:

```bash
nixos-portable check
nix flake check --no-write-lock-file
```

Framework-specific tests:

```bash
nix build .#checks.x86_64-linux.framework-tests --no-link --no-write-lock-file
```

The framework tests intentionally enforce the profile and role inventories. If a profile is added or removed, update `tests/framework.nix` and, when appropriate, the curated `completed` role in the same change.

## Add a machine

1. Create the host directory.
2. Add `identity.nix`.
3. Add `default.nix`.
4. Generate hardware facts on the target machine.
5. Select roles or profiles.
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
