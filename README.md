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
| `ai` | llama.cpp + editor integrations |
| `ide` | Zed |
| `media` | Media applications |
| `downloads` | qBittorrent |
| `thunderbird` | Thunderbird |
| `bitwarden` | Bitwarden Desktop |
| `keepassxc` | KeePassXC |
| `umbriel` | Umbriel user configuration |
| `vietnamese-input` | Fcitx5 + Lotus |

Production machine identity intentionally selects only `base`. Add optional profiles when building a specific machine configuration.

## GPU

```text
hosts/machine/gpu.nix
        │
        ▼
hosts/machine/gpu/<gpu>.nix
        │
        ├── graphics / Mesa / Vulkan
        ├── video acceleration when required
        └── compute runtime when required
```

The current RX 580 2048SP uses the standard Mesa graphics stack. ROCm is not enabled because Polaris is not a supported current Radeon target.

`gpu-tools` owns diagnostic applications such as `vulkaninfo` and `vainfo`; the GPU hardware module only owns hardware capability.

## AI

```text
llama.cpp : 127.0.0.1:8080
       ├── Zed native llama.cpp provider
       └── Neovim CodeCompanion OpenAI-compatible adapter
```

The `ai` profile selects the Vulkan llama.cpp backend while the machine GPU layer provides the underlying graphics capability.

## Validation

```bash
nix fmt -- --check $(git ls-files '*.nix')
nix flake show
nixos-rebuild build --flake .#nixos
```

CI evaluates the hardware-independent `ci` host and checks formatting, evaluation, build planning, and flake outputs.
