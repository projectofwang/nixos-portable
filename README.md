# nixos-portable

Portable NixOS configuration framework for applying one shared configuration model across multiple machines.

## Architecture

```text
flake.nix
├── hosts/
│   ├── machine/          # Production machine identity + hardware/policy
│   └── ci/               # Hardware-independent CI host
├── lib/
│   ├── hosts.nix         # Automatic host discovery
│   ├── mk-host.nix       # Reusable NixOS host builder
│   └── profiles.nix      # Automatic profile discovery/validation
├── modules/              # Reusable NixOS and Home Manager modules
├── profiles/             # Optional user-facing features
└── home/                 # Shared Home Manager configuration
```

The framework separates three concerns:

- **Host identity** — hostname, username, architecture, state versions, and selected profiles.
- **Machine implementation** — hardware, boot, networking, GPU, and other physical-machine concerns.
- **Reusable configuration** — profiles and modules shared by every host.

Every directory under `hosts/` containing an `identity.nix` file is automatically discovered and exported as a NixOS flake configuration. This means adding a machine does not require editing `flake.nix`.

The current repository already demonstrates two hosts: the physical `machine` host and the hardware-independent `ci` host.

## Adding another machine

Create a new host directory:

```text
hosts/
└── laptop/
    ├── default.nix
    ├── identity.nix
    └── hardware-configuration.nix
```

The identity file defines only host-specific metadata and profile selection:

```nix
{
  hostname = "laptop";
  username = "your-user";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";

  profiles = [
    "base"
    "desktop"
    "terminal"
  ];
}
```

The host's `default.nix` should import only machine-specific implementation modules. Hardware configuration must be generated from the actual computer and must not be copied blindly from another host.

After adding the host, it is automatically available as:

```bash
nix flake show
nixos-rebuild build --flake .#laptop
sudo nixos-rebuild switch --flake .#laptop
```

The hostname in `identity.nix` becomes the flake target name.

## Machine-specific hardware

For a new NixOS installation, generate hardware facts from the target machine:

```bash
sudo nixos-generate-config --show-hardware-config > hosts/laptop/hardware-configuration.nix
```

Review filesystem UUIDs, swap, kernel modules, CPU settings, `nixpkgs.hostPlatform`, and any additional mounts before using the configuration.

Hardware-specific modules should stay inside the host or a reusable hardware module. Do not put physical device assumptions into shared profiles.

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
| `keepassxc` | KeePassXC password manager |
| `media` | Media applications |
| `downloads` | qBittorrent |
| `signal` | Signal Desktop |
| `telegram` | Telegram Desktop |
| `thunderbird` | Thunderbird mail client |
| `umbriel` | Umbriel compositor user config |
| `vesktop` | Vesktop |
| `vietnamese-input` | Fcitx5 + Lotus input method |

Profiles are automatically discovered from `profiles/*.nix` and validated before host composition. A profile describes reusable software or behavior; it is not a substitute for hardware configuration.

## Usage

### Inspect available hosts

```bash
nix flake show
```

### Build a specific machine

```bash
nixos-rebuild build --flake .#<hostname>
```

### Apply a specific machine

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### Validate the repository

```bash
nix fmt -- --check $(git ls-files '*.nix')
nix flake show
nix build .#checks.x86_64-linux.ci --dry-run
```

### Update inputs

```bash
nix flake update
```

Review `flake.lock` changes before committing them.

## Design direction

The intended model is:

```text
                 nixos-portable framework
                           │
              ┌────────────┴────────────┐
              │                         │
       shared profiles/modules    host-specific data
                                        │
                    ┌───────────────────┼───────────────────┐
                    │                   │                   │
                 desktop             laptop              server
                    │                   │                   │
                 hardware            hardware            hardware
```

The framework is deliberately data-driven: host discovery and host composition are centralized in `lib/`, while each machine owns only the information that actually differs. This provides the foundation for adding roles, reusable hardware definitions, additional architectures, and deployment tooling later without duplicating the core configuration.
