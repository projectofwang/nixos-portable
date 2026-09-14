# nixos-portable

Cấu hình **NixOS cá nhân** dùng để quản lý máy chính của tôi. Repository này chứa host, hardware, profile, role, Home Manager, module dùng lại, kiểm tra framework và CLI triển khai.

Đây là **personal infrastructure**, không phải framework public có API ổn định. Cấu trúc, profile, module, input và workflow có thể thay đổi bất cứ lúc nào theo nhu cầu cá nhân.

## Cấu trúc

```text
nixos-portable
├── hosts/       cấu hình riêng của từng host
├── hardware/    hardware module dùng lại
├── profiles/    capability có thể chọn
├── roles/       nhóm profile
├── modules/     NixOS/Home Manager module
├── home/        cấu hình Home Manager cơ sở
├── lib/         composition framework và CLI
└── tests/       kiểm tra framework
```

Host production là `machine`. Host `ci` là host không phụ thuộc hardware, dùng để kiểm tra profile trên **`x86_64-linux`**.

Repository hiện chỉ có một system target: **`x86_64-linux`**. ARM, i686 và các kiến trúc khác nằm ngoài phạm vi hỗ trợ của framework này.

## Sử dụng

Tại thư mục repository:

```bash
nix develop
nixos-portable check
nixos-portable build machine
nixos-portable switch machine
```

Hoặc chạy CLI trực tiếp từ flake:

```bash
nix run .#nixos-portable -- check
nix run .#nixos-portable -- build machine
```

Deploy tới máy khác:

```bash
nixos-portable deploy machine root@server
nixos-portable deploy machine root@server root@builder
```

CLI hiện có bốn thao tác: `check`, `build`, `switch`, `deploy`. Nó dùng `set -euo pipefail` và chuyển các thao tác hệ thống cho `nixos-rebuild --flake`.

## Host

Host được tự động phát hiện nếu có `identity.nix`:

```text
hosts/<name>/
├── identity.nix
└── default.nix
```

Host vật lý có thể có thêm `hardware-configuration.nix`, `boot.nix`, `networking.nix` và `gpu.nix`.

Ví dụ identity:

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

`architectures` là tùy chọn và phải chứa `system` chính nếu được khai báo. Framework kiểm tra field bắt buộc, kiểu dữ liệu, architecture, hostname trùng và `default.nix` trước khi tạo NixOS configuration.

## Role và profile

**Profile** là một capability. **Role** là một tập profile.

| Role | Hành vi |
|---|---|
| `completed` | tự động chọn toàn bộ `profiles/*.nix` |
| `ci` | tự động chọn toàn bộ profile cho CI |

`completed` và `ci` đều lấy từ `profiles.available`, vì vậy thêm hoặc xóa profile không cần sửa thêm danh sách role.

Host chọn lọc có thể dùng:

```nix
roles = [ ];
profiles = [
  "base"
  "desktop"
  "terminal"
];
```

Profile được phát hiện từ `profiles/*.nix` và được kiểm tra tương thích với `x86_64-linux` khi build.

### Profile hiện tại

| Profile | Mục đích |
|---|---|
| `ai` | llama.cpp Vulkan |
| `base` | NixOS baseline |
| `bitwarden` | Bitwarden Desktop |
| `desktop` | Umbriel, Noctalia, Flatpak, PipeWire |
| `downloads` | qBittorrent |
| `firefox` | Firefox + Wayland defaults |
| `gaming` | Steam, GameMode, MangoHud |
| `helium` | Helium Browser |
| `hermes-agent` | Hermes Agent |
| `keepassxc` | KeePassXC |
| `media` | mpv, mpvpaper, VLC, Stremio |
| `opencode` | OpenCode |
| `signal` | Signal Desktop |
| `telegram` | Telegram Desktop |
| `terminal` | WezTerm, Zellij, terminal tools |
| `terminal-ide` | terminal + LazyVim |
| `thunderbird` | Thunderbird |
| `umbriel` | Umbriel |
| `vesktop` | Vesktop |
| `vietnamese-input` | Fcitx5 + Lotus |

Tất cả profile trong framework đều được đánh giá trong target `x86_64-linux` hiện tại.

## Helium

Helium được tách thành repository cá nhân riêng:

```text
nixos-portable
      │
      └── helium-nix
             └── binary Helium upstream
```

Input trong `flake.nix` hiện là:

```nix
helium = {
  url = "github:projectofwang/helium-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Profile `helium` import NixOS module từ input và bật các flag Wayland/accelerated video cần cho máy hiện tại.

`helium-nix` hiện chỉ hỗ trợ `x86_64-linux`, phù hợp với binary AMD64 upstream mà package sử dụng. `nixos-portable` cũng chỉ đánh giá profile Helium trên `x86_64-linux`.

**Trạng thái lockfile:** `flake.lock` pin một revision cụ thể của `projectofwang/helium-nix`; lockfile phải được cập nhật bằng Nix khi muốn đưa revision mới nhất của package vào parent flake:

```bash
nix flake lock --update-input helium
nix flake check
```

Không tự đoán hoặc điền `narHash` bằng tay.

## Hardware và networking

Hardware thật nằm trong `hosts/machine/`; module dùng lại nằm trong `hardware/`. GPU hiện tại dùng module AMD RX 580 2048SP với graphics 32-bit.

Networking dùng NetworkManager và `dnscrypt-proxy`. DNS của host đi qua `127.0.0.1:53` và `[::1]:53`; `1.1.1.1:53` chỉ được dùng làm bootstrap cho encrypted DNS. Firewall được bật.

## CI

CI gồm:

1. framework/flake evaluation;
2. profile × architecture matrix;
3. build production host.

Architecture matrix hiện chỉ có một architecture: `x86_64-linux`.

GitHub Actions trong workflow kiểm tra chính được pin bằng commit SHA, checkout không giữ credentials, và cache dùng GitHub Actions cache.

CodeQL chỉ phân tích GitHub Actions và cũng đã được pin bằng commit SHA.

Chạy kiểm tra tại máy:

```bash
nixos-portable check
nix flake check --no-write-lock-file
```

## Bảo trì

Development shell cung cấp `nil`, `nixfmt`, `statix`, `pre-commit` và CLI.

```bash
nix develop
pre-commit run --all-files
nix flake check
```

Cập nhật input có chủ đích:

```bash
nix flake update
nix flake check
```

Không cập nhật lockfile mù quáng, đặc biệt với binary package và các repository cá nhân được dùng làm flake input.

Các repository cá nhân được dùng làm input cũng là trust boundary. Khi đổi revision, cần xem xét diff và chạy lại `nix flake check`.

## Phạm vi sử dụng

Repository này public chỉ để version control và truy cập thuận tiện. Mục tiêu thiết kế là **chỉ phục vụ các máy cá nhân của tôi**.

Không có cam kết về backward compatibility, API ổn định, hỗ trợ máy khác, SLA hoặc release cadence. Nếu một thay đổi phá vỡ cấu trúc cũ nhưng phù hợp hơn với cấu hình cá nhân, thay đổi đó vẫn có thể được chấp nhận.
