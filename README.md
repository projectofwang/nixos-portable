# nixos-portable

Portable NixOS configuration built from machine hardware, reusable modules, and optional profiles.

## Architecture

```text
flake.nix
├── hosts/          # Machine and CI definitions
├── lib/            # Host and profile composition
├── modules/        # Reusable NixOS and Home Manager modules
├── profiles/       # Optional user-facing features
└── home/           # Shared Home Manager configuration
```

Machine-specific hardware stays under `hosts/machine/`. Optional software stays in profiles and is not part of machine identity.

## Profiles

| Profile | Purpose |
|---|---|
| `base` | Nix, system identity, user, security, Git |
| `desktop` | Umbriel, Noctalia, greeter, PipeWire, portals |
| `terminal` | WezTerm, Zellij, terminal tools |
| `terminal-ide` | Terminal + LazyVim/Neovim |
| `firefox` | Firefox + browser integration |
| `helium` | Helium + browser integration |
| `gaming` | Steam, GameMode, MangoHud |
| `gpu-tools` | Vulkan and VA-API diagnostics |
| `hermes-agent` | Hermes Agent CLI installation |
| `media` | Media applications |
| `downloads` | qBittorrent |
| `thunderbird` | Thunderbird |
| `bitwarden` | Bitwarden Desktop |
| `keepassxc` | KeePassXC |
| `umbriel` | Umbriel user configuration |
| `vietnamese-input` | Fcitx5 + Lotus |

Production machine identity intentionally selects only `base` and the explicitly enabled optional profiles. Add profiles when building a specific machine configuration.

## Usage

### 1. Clone the repository

```bash
git clone https://github.com/projectofwang/nixos-portable.git
cd nixos-portable
```

### 2. Check the available flake outputs

```bash
nix flake show
```

### 3. Build the NixOS configuration

```bash
nixos-rebuild build --flake .#nixos
```

Replace `nixos` with the desired host defined by the flake when using another machine configuration.

### 4. Apply the configuration

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### 5. Update flake inputs

```bash
nix flake update
```

Review the resulting `flake.lock` changes before committing them.

### Profiles

Profiles are enabled through the host configuration. Optional software should be added as a profile rather than directly to machine hardware definitions.

For example, the `hermes-agent` profile installs Hermes Agent as a Home Manager package without adding provider, model, or API configuration.

## Validation

```bash
nix fmt -- --check $(git ls-files '*.nix')
nix flake show
nixos-rebuild build --flake .#nixos
```

CI evaluates the hardware-independent `ci` host and checks formatting, evaluation, build planning, and flake outputs.
