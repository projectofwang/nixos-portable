# nixos-portable

Portable NixOS configuration managed with **Nix flakes** and **Home Manager**.

The design keeps machine identity and hardware local, while shared system and user configuration is composed from reusable profiles and modules.

## Requirements

- NixOS
- Git
- Nix flakes enabled
- Internet access for the initial flake evaluation

## Installation

### 1. Clone

```bash
git clone https://github.com/projectofwang/nixos-portable.git
cd nixos-portable
```

### 2. Generate hardware configuration

On the target machine, generate its own hardware configuration:

```bash
sudo nixos-generate-config --show-hardware-config \
  > hosts/machine/hardware-configuration.nix
```

Do not reuse another machine's `hardware-configuration.nix`.

### 3. Configure machine identity

Edit:

```text
hosts/machine/identity.nix
```

Set the machine-specific values:

```nix
{
  hostname = "nixos";
  username = "chicoarun";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";

  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  profiles = [
    "base"
    "desktop"
    "terminal"
    "browser"
    "gaming"
    "ai"
    "ide"
    "umbriel"
  ];
}
```

Change only the values required by the target machine. Keep state versions at the versions originally selected for that machine.

### 4. Validate

```bash
nix fmt -- --check
nix flake check
```

### 5. Build before switching

```bash
sudo nixos-rebuild build --flake .#nixos
```

### 6. Test, then activate

```bash
sudo nixos-rebuild test --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos
```

Rollback if necessary:

```bash
sudo nixos-rebuild switch --rollback
```

## Adding or removing applications

Applications are added through the appropriate profile or module. Do not install configuration-managed applications with ad-hoc commands such as `nix-env`.

### Existing profile

Add or remove a profile in `hosts/machine/identity.nix`:

```nix
profiles = [
  "base"
  "desktop"
  "terminal"
  "browser"
  "ide"
];
```

Available profiles:

| Profile | Purpose |
|---|---|
| `base` | Core NixOS and Home Manager foundation |
| `desktop` | Desktop session and desktop integration |
| `terminal` | Terminal applications and shell tooling |
| `browser` | Firefox |
| `gaming` | Steam, GameMode, and gaming support |
| `ai` | Ollama and local AI tooling |
| `ide` | Zed, Neovim, and development tooling |
| `umbriel` | Umbriel user/session configuration |

Then validate and rebuild:

```bash
nix flake check
sudo nixos-rebuild build --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos
```

### New application

Choose the correct layer:

1. **System service, driver, daemon, or system package** → NixOS module/profile.
2. **CLI tool or user application** → Home Manager module/profile.
3. **Machine-specific setting** → `hosts/machine/`.
4. **Reusable feature** → create or extend a profile/module.

Example Home Manager package:

```nix
home.packages = with pkgs; [
  ripgrep
  fd
];
```

Example NixOS package:

```nix
environment.systemPackages = with pkgs; [
  pciutils
];
```

Prefer adding applications to an existing appropriate module instead of creating a new module for every package.

After changes:

```bash
nix fmt
nix flake check
sudo nixos-rebuild build --flake .#nixos
```

Commit the configuration only after validation succeeds.

## Updating dependencies

Update deliberately:

```bash
nix flake update
nix flake check
sudo nixos-rebuild build --flake .#nixos
```

Review the resulting `flake.lock` diff before committing.

## Structure

```text
.
├── flake.nix
├── flake.lock
├── .editorconfig
│
├── hosts/
│   ├── machine/
│   │   ├── identity.nix
│   │   ├── hardware-configuration.nix
│   │   ├── boot.nix
│   │   └── networking.nix
│   └── ci/
│       └── default.nix
│
├── profiles/
│   ├── base.nix
│   ├── desktop.nix
│   ├── terminal.nix
│   ├── browser.nix
│   ├── gaming.nix
│   ├── ai.nix
│   ├── ide.nix
│   └── umbriel.nix
│
├── modules/
│   ├── nixos/
│   │   ├── core/
│   │   └── desktop/
│   └── home-manager/
│       ├── default.nix
│       ├── shell.nix
│       ├── terminal.nix
│       ├── ide.nix
│       ├── umbriel.nix
│       └── desktop/
│
├── home/
│   └── default.nix
│
└── .github/
    └── workflows/
        └── check.yml
```

## Architecture

```text
                    flake.nix
                        │
                        ▼
              hosts/machine/identity.nix
                        │
                        ▼
                    profiles
                   ┌────┴────┐
                   ▼         ▼
                NixOS   Home Manager
                   │         │
                   └────┬────┘
                        ▼
                  NixOS system
```

### Responsibilities

| Layer | Responsibility |
|---|---|
| `flake.nix` | Inputs, outputs, composition, validation |
| `hosts/machine/identity.nix` | Hostname, user, system, timezone, state versions, profiles |
| `hosts/machine/hardware-configuration.nix` | Target-machine hardware |
| `hosts/machine/boot.nix` | Target-machine boot configuration |
| `hosts/machine/networking.nix` | Target-machine networking |
| `profiles/` | Feature selection |
| `modules/nixos/` | System-level configuration |
| `modules/home-manager/` | User-level configuration |
| `home/` | Shared Home Manager user configuration |
| `.github/workflows/` | Automated validation |

Machine-specific data stays in `hosts/machine/`. Reusable configuration belongs in profiles/modules. Application runtime data, caches, models, and other mutable state stay outside the Git-managed configuration unless explicitly required.

## CI

GitHub Actions validates the flake and evaluates both the portable machine configuration and the CI configuration using synthetic hardware.

Run the same checks locally:

```bash
nix fmt -- --check
nix flake check
nix flake show
sudo nixos-rebuild build --flake .#nixos
```

## Common workflow

```text
Edit identity/profile/module
        ↓
     nix fmt
        ↓
  nix flake check
        ↓
 nixos-rebuild build
        ↓
 nixos-rebuild test
        ↓
 nixos-rebuild switch
```
