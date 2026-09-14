# nixos-portable

Personal NixOS configuration framework for managing my machines, hosts, profiles, roles, hardware, Home Manager, multi-architecture checks, and a small deployment CLI.

This repository is intentionally maintained for **personal use**. It is not a general-purpose NixOS framework, distribution, or supported configuration for other users or machines. The structure and interfaces may change whenever needed for my own setup.

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

When the target architecture cannot be built efficiently on the current machine, provide a remote build host explicitly:

```bash
nixos-portable deploy machine root@server root@builder
```

The CLI can also be run directly from the flake:

```bash
nix run .#nixos-portable -- check
nix run .#nixos-portable -- build machine
```

## Personal-use design

The repository is organized around my own machines and workflows:

```text
nixos-portable
├── hosts/       machine identity and host-specific configuration
├── hardware/    reusable hardware modules
├── profiles/    optional capabilities
├── roles/       profile bundles
├── home/        base Home Manager configuration
├── modules/     reusable NixOS/Home Manager modules
├── lib/         framework and CLI implementation
└── tests/       framework checks
```

There is deliberately no compatibility promise for configurations outside this repository. Changes may be opinionated and may require corresponding changes to existing hosts.

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

`completed` is the full-install role for my main machine. It intentionally follows `profiles.available`:

```nix
{ profiles }:

{
  profiles = profiles.available;
}
```

Therefore:

- add `profiles/foo.nix` → `foo` is automatically included by `completed`;
- remove `profiles/foo.nix` → `foo` is automatically removed from `completed`.

The main machine normally uses:

```nix
roles = [ "completed" ];
profiles = [ ];
```

### Selective machines

If one of my machines should install only selected capabilities, use:

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

The role provides the default full-install behavior; explicit profiles provide the per-machine override.

## Current profiles

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

## Helium

Helium is kept as a separate personal flake so that browser packaging does not have to live inside this framework:

```text
nixos-portable
      │
      └── helium-nix
             └── upstream Helium binary
```

The input is pinned through `flake.lock` and follows this repository's `nixpkgs` input:

```nix
helium = {
  url = "github:projectofwang/helium-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

The `helium` profile imports the dedicated NixOS module. Machine-specific flags and policies stay in `nixos-portable`; packaging details stay in `helium-nix`.

`helium` is currently restricted to `x86_64-linux` in this framework even though the separate package repository also contains an `aarch64-linux` package. This reflects the architecture of my current machine configuration, not a claim that the package cannot run on ARM64.

## Hardware

Machine-specific hardware belongs under `hosts/<name>/`. Reusable hardware implementations belong under `hardware/`.

The host selects reusable hardware implementations; profiles should not contain physical-device assumptions.

## DNS

The machine host sends normal DNS queries only to the local `dnscrypt-proxy` listeners on `127.0.0.1:53` and `[::1]:53`. The configured encrypted upstream is the self-hosted `sdns.taiyuanwangjie.dpdns.org` server.

A bootstrap resolver is used only to resolve the encrypted server hostname. It is not advertised as a normal system nameserver, so applications do not have a direct `1.1.1.1` fallback path through the host resolver configuration.

## Supported architectures

The framework currently targets:

- `x86_64-linux`
- `aarch64-linux`

Individual profiles may intentionally support fewer architectures. For example, `gaming` and the current `helium` profile are x86_64-only in this personal configuration.

## CI

The framework generates a matrix from:

```text
host × architecture × compatible profile
```

GitHub Actions validates formatting, framework semantics, flake structure, CLI availability, and compatible matrix entries. Matrix entries perform real NixOS system builds where configured.

The `ci` role follows `profiles.available`, so a newly added compatible profile becomes part of the CI surface automatically.

Run the same checks locally:

```bash
nixos-portable check
nix flake check --no-write-lock-file
```

Framework tests:

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

This section describes the workflow used for maintaining my configuration, not a supported development environment for third parties.

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

## Personal-use notice

This project is a private configuration in the practical sense: it is public on GitHub for convenience and version control, but its design target is my own machines.

There is no expectation of backward compatibility, issue response, release management, or support for other users. Fork or adapt it if useful, but treat the current repository state as personal infrastructure rather than a stable public framework.
