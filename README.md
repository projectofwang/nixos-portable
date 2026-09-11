# nixos-portable

Portable NixOS configuration built around machine-specific hardware, reusable modules, and optional profiles.

## Architecture

```text
flake.nix
├── hosts/
│   ├── machine/
│   │   ├── identity.nix
│   │   ├── hardware-configuration.nix
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   ├── gpu.nix
│   │   └── gpu/<gpu>.nix
│   └── ci/default.nix
├── lib/
├── modules/
│   ├── nixos/
│   └── home-manager/
├── profiles/
├── home/
└── .github/workflows/check.yml
```

The composition flow is:

```text
machine identity + hardware
            │
            ▼
         mkHost
        ┌───┴───┐
        ▼       ▼
     profiles  Home Manager
        │       │
        └───┬───┘
            ▼
        NixOS system
```

## Portability

For a new machine, normally change only:

- `hosts/machine/hardware-configuration.nix`
- `hosts/machine/gpu.nix`
- `hosts/machine/identity.nix`
- machine-specific `boot.nix` or `networking.nix` when required

GPU selection is intentionally isolated:

```nix
# hosts/machine/gpu.nix
imports = [ ./gpu/rx580-2048sp.nix ];
```

To migrate to another GPU, replace that selector with another machine GPU module.

## GPU model

GPU configuration is a hardware capability, not a profile feature.

```text
hosts/machine/gpu.nix
        │
        ▼
hosts/machine/gpu/<gpu>.nix
        │
        ├── graphics / Mesa / Vulkan
        ├── video acceleration when GPU-specific setup is required
        └── compute runtime only when the GPU and workload require it
```

The current RX 580 2048SP configuration enables NixOS graphics and 32-bit graphics. Mesa supplies the normal AMD Vulkan/OpenGL stack; the AMD kernel driver is detected automatically. citeturn0search0

ROCm is **not** enabled for the RX 580 configuration. The current ROCm compatibility documentation does not list RX 580/Polaris as a supported current Radeon target, so adding ROCm preemptively would create an unsupported dependency rather than a useful capability. citeturn1search2turn1search13

The AI profile uses `llama-cpp-vulkan` because backend selection belongs to the workload. It does not make Vulkan or ROCm a global profile dependency.

## Profiles

Profiles select user-facing features. Modules implement them.

| Profile | Purpose |
|---|---|
| `base` | Nix, system identity, user, security, Git |
| `desktop` | Umbriel, Noctalia, greeter, PipeWire, portals |
| `terminal` | WezTerm, Zellij, terminal tools |
| `terminal-ide` | Terminal + LazyVim/Neovim |
| `browser-firefox` | Browser integration + Firefox |
| `browser-helium` | Browser integration + Helium |
| `gaming` | Steam + GameMode |
| `ai` | llama.cpp + editor integrations |
| `ide` | Zed |
| `media` | Media applications |
| `downloads` | qBittorrent |
| `mail-thunderbird` | Thunderbird |
| `password-bitwarden` | Bitwarden Desktop |
| `password-keepassxc` | KeePassXC |
| `umbriel` | Umbriel user configuration |
| `vietnamese-input` | Fcitx5 + Lotus |

The production profile list lives in one place:

```nix
# hosts/machine/identity.nix
profiles = [
  "base"
  "desktop"
  "terminal"
  "terminal-ide"
  "gaming"
  "ai"
  "ide"
];
```

## AI

```text
llama.cpp : 127.0.0.1:8080
       │
       ├── Zed native llama.cpp provider
       └── Neovim CodeCompanion OpenAI-compatible adapter
```

The server backend is selected by the `ai` profile. The machine GPU layer supplies the graphics capability it can actually support.

## Validation

```bash
nix fmt -- --check $(git ls-files '*.nix')
nix flake check
nix flake show
nixos-rebuild build --flake .#nixos
```

CI evaluates the hardware-independent `ci` host and checks formatting, evaluation, build planning, and flake outputs.
