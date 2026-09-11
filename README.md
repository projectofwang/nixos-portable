# nixos-portable

`nixos-portable` là một NixOS flake dùng một host builder chung, tách cấu hình theo machine khỏi implementation dùng lại, và ghép hệ thống bằng các profile tùy chọn. Machine hardware nằm trong `hosts/machine`; NixOS modules chứa implementation hệ thống; Home Manager modules chứa user environment.

## Kiến trúc

```text
flake.nix
├── hosts/
│   ├── machine/
│   │   ├── identity.nix
│   │   ├── hardware-configuration.nix
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   ├── gpu.nix
│   │   └── gpu/
│   │       └── rx580-2048sp.nix
│   └── ci/default.nix
├── lib/
│   ├── default.nix
│   ├── mk-host.nix
│   ├── profiles.nix
│   └── home-manager.nix
├── modules/
│   ├── nixos/
│   │   ├── core/
│   │   ├── browser/
│   │   └── desktop/
│   └── home-manager/
├── profiles/
├── home/default.nix
├── flake.nix
└── .github/workflows/check.yml
```

Luồng tạo host:

```text
hosts/machine/identity.nix
          │
          ▼
     lib/mk-host.nix
          │
    ┌─────┼─────┐
    ▼     ▼     ▼
 machine  HM  profiles
 hardware       │
    │           ▼
    └────── modules
                │
                ▼
           NixOS system
```

`identity.nix` chọn machine identity và profiles. `gpu.nix` chọn cấu hình GPU của machine. `mk-host.nix` compose mọi lớp thành `nixosSystem`. Profile chọn chức năng; module triển khai chức năng.

## Machine portability

Machine mới không cần sửa implementation chung. Thông thường chỉ thay:

1. `hosts/machine/hardware-configuration.nix`
2. `hosts/machine/gpu.nix` để chọn GPU file tương ứng
3. `hosts/machine/identity.nix` nếu hostname, username, system hoặc profiles thay đổi
4. `boot.nix` hoặc `networking.nix` nếu machine có yêu cầu riêng

Ví dụ machine hiện tại dùng RX 580 2048SP:

```text
hosts/machine/gpu.nix
        │
        ▼
hosts/machine/gpu/rx580-2048sp.nix
```

Khi đổi sang GPU khác, thay import trong `gpu.nix`, ví dụ:

```nix
imports = [ ./gpu/nvidia-rtx-3060.nix ];
```

GPU là hardware capability của machine, không phải responsibility của profile `gaming` hay `browser`. Vì vậy các profile chỉ sử dụng graphics capability đã được machine cung cấp.

NixOS hiện tự động load `amdgpu` cho AMD GPU; file RX 580 hiện bật graphics userspace và 32-bit graphics cho machine. Đây là phần machine-specific, còn profile vẫn giữ độc lập với model GPU.

## Root files

### `flake.nix`

Composition root của flake.

- khai báo inputs.
- nạp framework từ `lib`.
- đọc machine identity.
- tạo production host và CI host.
- export `nixosConfigurations`.
- export CI check.
- chọn formatter.

Ví dụ:

```bash
nixos-rebuild build --flake .#nixos
```

### `flake.lock`

Khóa revision của mọi flake input.

Ví dụ cập nhật một input:

```bash
nix flake lock --update-input nixpkgs
```

### `home/default.nix`

Thiết lập Home Manager state cơ bản:

- username.
- home directory.
- Home Manager state version.

Ví dụ `username = "alice"` tạo home `/home/alice`.

## `hosts/`

Chứa machine definitions.

### `hosts/machine/identity.nix`

Machine metadata và profile selection.

```nix
{
  hostname = "nixos";
  username = "chicoarun";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";
  profiles = [ "base" "terminal" ];
}
```

### `hosts/machine/hardware-configuration.nix`

Hardware configuration được tạo cho machine thật.

Ví dụ:

```bash
sudo nixos-generate-config --show-hardware-config > hosts/machine/hardware-configuration.nix
```

File này là phần cần thay khi chuyển sang hardware khác.

### `hosts/machine/boot.nix`

Bootloader configuration của machine.

Hiện dùng systemd-boot và EFI variables.

### `hosts/machine/networking.nix`

Machine networking:

- NetworkManager.
- DNSCrypt local resolver.
- DNS fallback.
- firewall.

### `hosts/machine/gpu.nix`

GPU selector của machine. File này chỉ chọn implementation trong `hosts/machine/gpu/`.

Ví dụ:

```nix
imports = [ ./gpu/rx580-2048sp.nix ];
```

Khi đổi GPU, đây là file selector cần thay đổi thay vì sửa profiles.

### `hosts/machine/gpu/rx580-2048sp.nix`

Hardware graphics layer cho RX 580 2048SP.

```nix
hardware.graphics = {
  enable = true;
  enable32Bit = true;
};
```

`hardware.graphics` cung cấp Mesa/OpenGL/Vulkan userspace cần cho desktop, browser, game và ứng dụng GPU. NixOS documentation xác nhận AMD graphics hoạt động với `hardware.graphics.enable = true`; AMD kernel driver `amdgpu` được kernel tự động detect. citeturn0search0turn0search2

### `hosts/machine/default.nix`

Compose machine-specific files:

```text
hardware-configuration.nix
boot.nix
networking.nix
gpu.nix
```

### `hosts/ci/default.nix`

Minimal NixOS host dành cho CI. Nó không phụ thuộc hardware thật và được dùng để evaluate/build-plan cấu hình trong GitHub Actions.

## `lib/`

Framework nội bộ để tạo host.

### `lib/default.nix`

Export `profiles` và `mkHost`.

### `lib/profiles.nix`

Tự discover `profiles/*.nix` và validate profile name.

Ví dụ:

```text
profiles/terminal.nix → terminal
```

Nếu profile không tồn tại, evaluation fail.

### `lib/home-manager.nix`

Tạo Home Manager configuration dùng chung cho host.

Nó nối system package set, user packages, state versions và user module tree.

### `lib/mk-host.nix`

Composition root của từng host.

Thực hiện:

1. validate profiles.
2. tạo Home Manager.
3. tạo `nixosSystem`.
4. truyền machine values qua `specialArgs`.
5. import host module.
6. import Home Manager.
7. import selected profiles.
8. đặt NixOS state version.

## `modules/nixos/`

Implementation cấp system.

### `modules/nixos/core/nix.nix`

Cấu hình Nix daemon, flakes, `nix-command`, store optimisation và garbage collection.

Ví dụ:

```bash
nix flake show
```

### `modules/nixos/core/system.nix`

Map machine identity vào hostname và timezone.

### `modules/nixos/core/users.nix`

Tạo user chính, Zsh và các group hệ thống cần thiết.

### `modules/nixos/core/security.nix`

Cấu hình sudo và policy mặc định cho system security.

### `modules/nixos/core/tools.nix`

Cài system-level tools thuộc base system, hiện gồm Git.

### `modules/nixos/browser/default.nix`

Browser/Wayland integration.

- `MOZ_ENABLE_WAYLAND`.
- `NIXOS_OZONE_WL`.
- `libva-utils`.
- `vulkan-tools`.

Graphics hardware không được khai báo ở đây; nó thuộc machine GPU layer.

### `modules/nixos/desktop/default.nix`

System desktop stack:

- Umbriel.
- Noctalia.
- Noctalia Greeter.
- PipeWire.
- RTKit.
- XDG desktop portal.
- `gpu-screen-recorder`.
- Krusader.
- Home Manager desktop import.

## `modules/home-manager/`

User-level implementation.

### `modules/home-manager/default.nix`

Baseline Home Manager; chỉ nạp shell environment.

### `modules/home-manager/shell.nix`

Shell và CLI environment:

- Bash/Zsh.
- Starship.
- direnv/nix-direnv.
- zoxide.
- Atuin.
- fzf.
- bat.
- eza.
- fd.
- ripgrep.
- fzf-tab.

Ví dụ:

```text
ls   → eza
cat  → bat
find → fd
cd   → z
```

### `modules/home-manager/terminal.nix`

Terminal environment:

- WezTerm.
- Zellij.
- btop.
- cava.
- fastfetch.
- jq.
- tree.
- yazi.

Neovim không được sở hữu ở đây.

### `modules/home-manager/lazyvim.nix`

Ownership duy nhất của Neovim/LazyVim.

- Neovim.
- `vi`/`vim` aliases.
- default editor.
- LazyVim bootstrap.
- language servers.
- formatters.

Ví dụ:

```bash
nvim
```

### `modules/home-manager/ide.nix`

Ownership của Zed.

- Zed package.
- editor settings.
- Nix/TOML/Rust extensions.
- format on save.
- project terminal.

### `modules/home-manager/ai-integration.nix`

Editor integration cho local AI.

- Zed dùng native `llama.cpp` provider.
- Neovim dùng CodeCompanion với OpenAI-compatible endpoint.
- Không tự cài editor.

Backend:

```text
127.0.0.1:8080
qwen3.5-4b
```

### `modules/home-manager/desktop/default.nix`

Noctalia Home Manager configuration và official screen-recorder plugin.

### `modules/home-manager/umbriel.nix`

Bật Umbriel user configuration.

### `modules/home-manager/umbriel/config.toml`

Runtime configuration cho compositor:

- appearance.
- input.
- workspaces.
- window management.
- terminal/file manager launch.
- Noctalia IPC.
- audio.
- screenshots.

## Profiles

Profile là composition layer. Profile chọn chức năng; implementation nằm trong modules.

| Profile | Nội dung |
|---|---|
| `base` | Nix, system identity, user, security, Git |
| `desktop` | Umbriel, Noctalia, greeter, PipeWire, portal |
| `terminal` | WezTerm, Zellij, terminal CLI stack |
| `terminal-ide` | `terminal` + LazyVim/Neovim |
| `browser-firefox` | Browser layer + Firefox |
| `browser-helium` | Browser layer + Helium |
| `gaming` | GameMode + Steam |
| `ai` | llama.cpp server + editor integrations |
| `ide` | Zed |
| `media` | mpv, mpvpaper, VLC, Stremio |
| `downloads` | qBittorrent GUI |
| `mail-thunderbird` | Thunderbird |
| `password-bitwarden` | Bitwarden Desktop |
| `password-keepassxc` | KeePassXC |
| `umbriel` | Umbriel user configuration |
| `vietnamese-input` | Fcitx5 + Lotus Vietnamese input |

GPU không phải profile. GPU được chọn trong `hosts/machine/gpu.nix` vì nó là machine hardware capability.

Ví dụ:

```nix
profiles = [
  "base"
  "desktop"
  "terminal"
  "terminal-ide"
  "gaming"
  "ai"
];
```

## Validation

Local validation:

```bash
nix fmt -- --check $(git ls-files '*.nix')
nix flake check
nix flake show
```

Production build:

```bash
nixos-rebuild build --flake .#nixos
```

Production switch:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

CI không evaluate production hardware configuration; CI dùng host `ci` để kiểm tra evaluation và build plan trên runner không có hardware của machine thật.
