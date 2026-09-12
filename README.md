# nixos-portable

Portable NixOS configuration built from machine hardware, machine identity, reusable modules, and optional profiles.

## Architecture

```text
flake.nix
├── hosts/
│   ├── machine/          # Physical-machine identity, hardware, boot, network, GPU
│   └── ci/               # Hardware-independent CI host
├── lib/                  # Host and profile composition
├── modules/              # Reusable NixOS and Home Manager modules
├── profiles/             # Optional user-facing features
└── home/                 # Shared Home Manager configuration
```

The important boundary is:

- `hosts/machine/` describes the physical computer and its machine-specific state.
- `profiles/` describes optional software and user-facing features.
- `modules/` contains reusable implementation details.
- `identity.nix` is the source of the production hostname, username, architecture, state versions, and enabled profiles.

When moving this configuration to another computer, do not copy the existing machine-specific files blindly. Regenerate hardware data and review every file under `hosts/machine/`.

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
| `hermes-agent` | Hermes Agent CLI installation |
| `helium` | Helium browser + integration |
| `keepassxc` | KeePassXC password manager |
| `media` | Media applications (mpv, VLC, Stremio) |
| `downloads` | qBittorrent |
| `signal` | Signal Desktop |
| `telegram` | Telegram Desktop |
| `thunderbird` | Thunderbird mail client |
| `umbriel` | Umbriel compositor user config |
| `vesktop` | Vesktop (Discord) |
| `vietnamese-input` | Fcitx5 + Lotus input method |

Profiles are selected in `hosts/machine/identity.nix`. Only select profiles that should exist on that machine. Profiles are not a replacement for hardware configuration.

## Usage

### 1. Clone the repository

```bash
git clone https://github.com/projectofwang/nixos-portable.git
cd nixos-portable
```

### 2. Inspect the host before changing anything

The production host is assembled from `hosts/machine/` and the profile list in `hosts/machine/identity.nix`.

```bash
ls hosts/machine
cat hosts/machine/identity.nix
cat hosts/machine/hardware-configuration.nix
cat hosts/machine/boot.nix
cat hosts/machine/networking.nix
cat hosts/machine/gpu.nix
```

For a new computer, treat all files under `hosts/machine/` as candidates for review. In particular, filesystem UUIDs, swap, CPU/kernel modules, bootloader settings, network/DNS policy, and GPU selection may differ from the old machine.

### 3. Generate hardware configuration for the new machine

On the new NixOS installation, generate the hardware facts from the actual machine:

```bash
sudo nixos-generate-config --show-hardware-config > hosts/machine/hardware-configuration.nix
```

Then review the generated file manually. Pay attention to:

- `fileSystems."/"` and its filesystem UUID
- `fileSystems."/boot"` and its EFI partition UUID
- additional mounts such as `/mnt/windows`
- `swapDevices`
- `boot.initrd.availableKernelModules`
- `boot.kernelModules`
- `nixpkgs.hostPlatform`
- CPU-specific settings

Do not retain filesystem UUIDs or device-specific entries from the previous computer unless they are intentionally the same.

### 4. Update machine identity

Edit `hosts/machine/identity.nix` for the new computer:

```nix
{
  hostname = "your-hostname";
  username = "your-user";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  profiles = [
    "base"
    # Add only the profiles required by this machine.
  ];
}
```

The `hostname`, `username`, and `system` values must match the new machine. Keep the state-version values unless you are deliberately performing a NixOS/Home Manager state-version migration.

The hostname is also used by the flake output, so after changing it the rebuild target becomes `.#<hostname>`.

### 5. Review the remaining machine-specific files

`hardware-configuration.nix` is not the only file that can depend on the physical machine.

#### `hosts/machine/boot.nix`

Review the bootloader and firmware assumptions. The current configuration uses systemd-boot and EFI variables; change it if the new machine uses a different boot setup.

#### `hosts/machine/networking.nix`

Review NetworkManager, DNS, firewall, and any resolver-specific configuration. The current file contains machine/network policy and should not be assumed portable without review.

#### `hosts/machine/gpu.nix`

Select the GPU implementation that actually exists in the new computer. The current machine imports `gpu/rx580-2048sp.nix`; replace that import when the GPU changes.

### 6. Check the resulting flake target

```bash
nix flake show
```

The production configuration is generated from `hosts/machine/identity.nix`, so the target follows the configured hostname:

```bash
nixos-rebuild build --flake .#<hostname>
```

For the current machine, this is:

```bash
nixos-rebuild build --flake .#nixos
```

### 7. Apply the configuration

After reviewing the build result:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### 8. Update flake inputs

```bash
nix flake update
```

Review the resulting `flake.lock` changes before committing them.

## Profiles

Profiles are enabled through the host identity. Optional software should be added as a profile rather than directly to machine hardware definitions.

The `hermes-agent` profile installs Hermes Agent as a Home Manager package without adding provider, model, or API configuration. AI provider configuration remains the user's responsibility.

## Validation

Before committing a machine migration or configuration change:

```bash
nix fmt -- --check $(git ls-files '*.nix')
nix flake show
nixos-rebuild build --flake .#<hostname>
```

CI evaluates the hardware-independent `ci` host and checks formatting, evaluation, build planning, and flake outputs. The CI host does not replace the need to validate the real machine's generated hardware configuration.
