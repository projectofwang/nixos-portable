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
    "gaming"
    "ai"
    "ide"
    "umbriel"
    "vietnamese-input"
  ];
}
```

Profiles are the feature boundary: add or remove a profile here instead of editing shared modules for machine-specific software choices. For example, `ai` enables the local Ollama service and AI integration for the IDE when `ide` is also selected; `ide` by itself does not enable or require Ollama.

`vietnamese-input` enables Fcitx5 with the [Fcitx5 Lotus](https://github.com/LotusInputMethod/fcitx5-lotus) Vietnamese input method. The package is built reproducibly from the upstream Lotus release and includes its required udev/systemd integration.

Change only the values required by the target machine. Keep state versions at the versions originally selected for that machine.

### 4. Validate

```bash
nix --no-write-lock-file fmt -- --check $(git ls-files '*.nix')
nix flake check --no-write-lock-file
```

### 5. Build before switching

Use the hostname configured in `hosts/machine/identity.nix`:

```bash
sudo nixos-rebuild build --flake .#<hostname>
```

Then switch only after the build succeeds:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```
