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
| `ai` | llama.cpp + Neovim integrations |
| `hermes-agent` | Hermes Agent CLI installation |
| `media` | Media applications |
| `downloads` | qBittorrent |
| `thunderbird` | Thunderbird |
| `bitwarden` | Bitwarden Desktop |
| `keepassxc` | KeePassXC |
| `umbriel` | Umbriel user configuration |
| `vietnamese-input` | Fcitx5 + Lotus |

Production machine identity intentionally selects only `base` and the explicitly enabled optional profiles. Add profiles when building a specific machine configuration.

## Hermes Agent

[Hermes Agent](https://github.com/NousResearch/hermes-agent) is installed as a standalone Home Manager package through the `hermes-agent` profile.

The profile intentionally provides **installation only**. It does not configure:

- providers or API keys
- models
- agent behavior
- gateway/services
- secrets

After rebuilding the system with the profile enabled, configure Hermes Agent yourself according to your preferred provider and model setup.

## AI

```text
llama.cpp : 127.0.0.1:8080
       └── Neovim CodeCompanion OpenAI-compatible adapter
```

The `ai` profile selects the Vulkan llama.cpp backend while the machine GPU layer provides the underlying graphics capability.

Hermes Agent is managed separately by the `hermes-agent` profile and is not coupled to the llama.cpp configuration.

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

## Validation

```bash
nix fmt -- --check $(git ls-files '*.nix')
nix flake show
nixos-rebuild build --flake .#nixos
```

CI evaluates the hardware-independent `ci` host and checks formatting, evaluation, build planning, and flake outputs.
