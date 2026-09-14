# nixos-portable

Framework cấu hình NixOS cá nhân dùng để quản lý các máy của tôi, bao gồm host, profile, role, hardware, Home Manager, kiểm tra đa kiến trúc và một CLI triển khai nhỏ.

Repository này được duy trì dành riêng cho **personal use**. Đây không phải framework NixOS tổng quát, bản phân phối, hay cấu hình được hỗ trợ cho người dùng hoặc máy khác. Cấu trúc và interface có thể thay đổi bất cứ lúc nào theo nhu cầu cấu hình cá nhân.

## Bắt đầu nhanh

```bash
git clone https://github.com/projectofwang/nixos-portable.git
cd nixos-portable
nix develop
nixos-portable check
nixos-portable build machine
```

Áp dụng cấu hình cho máy hiện tại:

```bash
nixos-portable switch machine
```

Triển khai cùng host definition sang máy khác:

```bash
nixos-portable deploy machine root@server
```

Nếu kiến trúc đích không thể build hiệu quả trên máy hiện tại, chỉ định rõ máy build từ xa:

```bash
nixos-portable deploy machine root@server root@builder
```

CLI cũng có thể chạy trực tiếp từ flake:

```bash
nix run .#nixos-portable -- check
nix run .#nixos-portable -- build machine
```

## Thiết kế cho mục đích cá nhân

Repository được tổ chức xoay quanh các máy và workflow của tôi:

```text
nixos-portable
├── hosts/       identity và cấu hình riêng của từng máy
├── hardware/    hardware module có thể tái sử dụng
├── profiles/    các capability tùy chọn
├── roles/       nhóm profile
├── home/        cấu hình Home Manager cơ sở
├── modules/     NixOS/Home Manager module dùng lại
├── lib/         framework và implementation của CLI
└── tests/       các kiểm tra của framework
```

Cố ý không có cam kết compatibility cho các cấu hình bên ngoài repository này. Các thay đổi có thể mang tính opinionated và có thể yêu cầu sửa các host hiện có.

## Host

Mỗi host cần:

```text
hosts/<name>/
├── default.nix
└── identity.nix
```

Một máy vật lý thông thường cũng có:

```text
hosts/<name>/
└── hardware-configuration.nix
```

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

`architectures` tùy chọn dùng để khai báo toàn bộ kiến trúc mà host được phép evaluate. Nó phải bao gồm `system` chính.

Các thư mục host là flake target ổn định:

```bash
nixos-portable build machine
nixos-portable switch machine
```

Hostname cũng được expose dưới dạng flake alias để tương thích.

## Role và profile

**Profile** thêm một capability. **Role** mở rộng thành một tập profile có thể tái sử dụng.

Các role hiện tại:

| Role | Profile |
|---|---|
| `completed` | **tất cả profile được tự động phát hiện** |
| `ci` | **tất cả profile được tự động phát hiện**, evaluate trên CI host không phụ thuộc hardware |

### Role `completed`

`completed` là role cài đặt đầy đủ cho máy chính của tôi. Nó tự động lấy theo `profiles.available`:

```nix
{ profiles }:

{
  profiles = profiles.available;
}
```

Vì vậy:

- thêm `profiles/foo.nix` → `foo` tự động được `completed` chọn;
- xóa `profiles/foo.nix` → `foo` tự động bị loại khỏi `completed`.

Máy chính thông thường sử dụng:

```nix
roles = [ "completed" ];
profiles = [ ];
```

### Máy chọn profile riêng

Nếu một máy chỉ cần một số capability nhất định, sử dụng:

```nix
roles = [ ];
profiles = [
  "base"
  "desktop"
  "terminal-ide"
  "hermes-agent"
  "opencode"
];
```

Role cung cấp hành vi cài đặt đầy đủ mặc định; `profiles` tường minh dùng để override theo từng máy.

## Các profile hiện tại

| Profile | Mục đích | Kiến trúc |
|---|---|---|
| `ai` | công cụ llama.cpp Vulkan | x86_64, aarch64 |
| `base` | hệ thống NixOS cơ sở | x86_64, aarch64 |
| `bitwarden` | Bitwarden Desktop | x86_64, aarch64 |
| `desktop` | Umbriel, Noctalia, PipeWire, Flatpak | x86_64, aarch64 |
| `downloads` | qBittorrent | x86_64, aarch64 |
| `firefox` | Firefox và tích hợp browser Wayland | x86_64, aarch64 |
| `gaming` | Steam, GameMode, MangoHud | x86_64 |
| `helium` | tích hợp trình duyệt Helium | x86_64 |
| `hermes-agent` | Hermes Agent | x86_64, aarch64 |
| `keepassxc` | KeePassXC | x86_64, aarch64 |
| `media` | mpv, mpvpaper, VLC, Stremio | x86_64, aarch64 |
| `opencode` | OpenCode coding agent | x86_64, aarch64 |
| `signal` | Signal Desktop | x86_64, aarch64 |
| `telegram` | Telegram Desktop | x86_64, aarch64 |
| `terminal` | WezTerm, Zellij, công cụ terminal | x86_64, aarch64 |
| `terminal-ide` | terminal + LazyVim | x86_64, aarch64 |
| `thunderbird` | Thunderbird | x86_64, aarch64 |
| `umbriel` | tích hợp môi trường desktop Umbriel | x86_64, aarch64 |
| `vesktop` | Vesktop | x86_64, aarch64 |
| `vietnamese-input` | hỗ trợ nhập tiếng Việt | x86_64, aarch64 |

Profile được tự động phát hiện từ `profiles/*.nix`. Compatibility theo kiến trúc được khai báo tập trung trong `lib/profiles.nix`.

## Helium

Helium được tách thành một flake cá nhân riêng để phần đóng gói browser không nằm trực tiếp trong framework:

```text
nixos-portable
      │
      └── helium-nix
             └── binary Helium upstream
```

Input được pin trong `flake.lock` và dùng cùng input `nixpkgs` của repository này:

```nix
helium = {
  url = "github:projectofwang/helium-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Profile `helium` import NixOS module riêng. Các flag và policy phụ thuộc từng máy nằm trong `nixos-portable`; chi tiết đóng gói nằm trong `helium-nix`.

`helium` hiện bị giới hạn ở `x86_64-linux` trong framework này dù package repository riêng cũng có package `aarch64-linux`. Đây là giới hạn theo cấu hình máy hiện tại, không phải tuyên bố rằng package không chạy được trên ARM64.

## Hardware

Hardware phụ thuộc từng máy thuộc `hosts/<name>/`. Hardware implementation có thể tái sử dụng thuộc `hardware/`.

Host chọn các hardware implementation cần thiết; profile không nên chứa giả định về thiết bị vật lý cụ thể.

## DNS

Host gửi truy vấn DNS thông thường chỉ tới các listener `dnscrypt-proxy` cục bộ tại `127.0.0.1:53` và `[::1]:53`. Upstream mã hóa được cấu hình là server `sdns.taiyuanwangjie.dpdns.org` tự vận hành.

Bootstrap resolver chỉ được dùng để phân giải hostname của encrypted server. Nó không được quảng bá như nameserver hệ thống thông thường, do đó ứng dụng không có đường fallback trực tiếp tới `1.1.1.1` thông qua cấu hình resolver của host.

## Kiến trúc được hỗ trợ

Framework hiện nhắm tới:

- `x86_64-linux`
- `aarch64-linux`

Từng profile có thể cố ý hỗ trợ ít kiến trúc hơn. Ví dụ, `gaming` và profile `helium` hiện tại chỉ dùng `x86_64-linux` trong cấu hình cá nhân này.

## CI

Framework tạo matrix theo:

```text
host × architecture × compatible profile
```

GitHub Actions kiểm tra formatting, semantics của framework, cấu trúc flake, khả năng chạy CLI và các matrix entry tương thích. Các matrix entry được cấu hình để thực hiện build NixOS thực tế.

Role `ci` theo `profiles.available`, vì vậy profile mới tương thích sẽ tự động trở thành một phần của CI surface.

Chạy các kiểm tra tương tự trên máy cá nhân:

```bash
nixos-portable check
nix flake check --no-write-lock-file
```

Kiểm tra riêng của framework:

```bash
nix build .#checks.x86_64-linux.framework-tests --no-link --no-write-lock-file
```

## Thêm một máy

1. Tạo thư mục host.
2. Thêm `identity.nix`.
3. Thêm `default.nix`.
4. Sinh hardware facts trên máy đích.
5. Dùng `roles = [ "completed" ]` cho toàn bộ profile, hoặc `roles = [ ];` kết hợp `profiles` tường minh cho máy chọn lọc.
6. Kiểm tra trước khi switch.

Ví dụ:

```bash
mkdir -p hosts/laptop
sudo nixos-generate-config --show-hardware-config > hosts/laptop/hardware-configuration.nix
```

Sau đó tạo `hosts/laptop/identity.nix` và `hosts/laptop/default.nix`.

Kiểm tra:

```bash
nixos-portable check
nixos-portable build laptop
```

Áp dụng trên máy:

```bash
nixos-portable switch laptop
```

## Phát triển và bảo trì

Phần này mô tả workflow dùng để bảo trì cấu hình cá nhân, không phải môi trường phát triển được hỗ trợ cho bên thứ ba.

Vào development shell:

```bash
nix develop
```

Các công cụ có sẵn gồm `nil`, `nixfmt`, `statix`, `pre-commit` và `nixos-portable`.

Kiểm tra formatting:

```bash
nix fmt --no-write-lock-file -- --check $(git ls-files '*.nix')
```

Chạy pre-commit:

```bash
pre-commit run --all-files
```

Build CLI package:

```bash
nix build .#nixos-portable
./result/bin/nixos-portable --help
```

## Cập nhật input

Xem xét thay đổi trước khi cập nhật lockfile:

```bash
nix flake update
nix flake check
```

Commit `flake.lock` cùng với các thay đổi input có chủ đích.

## Thông báo về phạm vi sử dụng cá nhân

Repository này được public trên GitHub để thuận tiện cho version control và truy cập, nhưng mục tiêu thiết kế là phục vụ **các máy cá nhân của tôi**.

Không có cam kết về backward compatibility, hỗ trợ issue, release management hoặc hỗ trợ người dùng khác. Có thể fork hoặc điều chỉnh nếu thấy hữu ích, nhưng hãy xem trạng thái hiện tại của repository là **personal infrastructure**, không phải một framework public ổn định.
