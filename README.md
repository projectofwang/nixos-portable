# nixos-portable

**Personal NixOS infrastructure** dùng để xây dựng, quản lý và triển khai cấu hình NixOS cho các máy tôi trực tiếp sử dụng.

Đây là một project **personal-use first**. Repository public chủ yếu để version control, backup và truy cập thuận tiện; nó không phải một NixOS distribution, framework public có API ổn định, hay package collection có compatibility/support contract.

## Mục đích

`nixos-portable` gom system configuration vào một Nix flake có cấu trúc rõ ràng:

- quản lý host và hardware;
- tổ chức phần mềm thành profile và role;
- dùng lại NixOS/Home Manager modules;
- validate metadata và composition framework;
- cung cấp CLI cho `check`, `build`, `switch`, `deploy`;
- evaluate toàn bộ profile bằng CI;
- build production host;
- tách binary packaging của Helium sang `helium-nix`.

Ưu tiên thiết kế là **reproducibility, maintainability và cấu hình đúng với máy cá nhân**, không phải portability tối đa.

## Kiến trúc

```text
nixos-portable
│
├── hosts/ ───────────── host identity + system configuration
│     ├── machine/ ───── production host
│     └── ci/ ─────────── CI/evaluation host
│
├── profiles/ ─────────── capabilities / software groups
├── roles/ ────────────── collections of profiles
├── hardware/ ─────────── reusable hardware modules
├── modules/ ──────────── reusable NixOS/Home Manager modules
├── home/ ─────────────── base Home Manager configuration
├── lib/ ───────────────── discovery, validation, composition, CLI
├── tests/ ─────────────── framework tests
└── .github/workflows/ ─── CI + security checks
```

Luồng composition chính:

```text
host identity
     │
     ├── roles ──► profiles
     ├── hardware
     └── modules
           │
           ▼
     lib/ validation + composition
           │
           ▼
     NixOS + Home Manager configuration
           │
           ▼
       x86_64-linux
```

`lib/` tự phát hiện host/profile và kiểm tra metadata trước khi tạo configuration. Framework reject host không hợp lệ, architecture ngoài phạm vi, hostname trùng và các cấu trúc bắt buộc bị thiếu.

## Cấu trúc host

Mỗi host được phát hiện thông qua:

```text
hosts/<name>/
├── identity.nix
├── default.nix
└── hardware-configuration.nix   # nếu cần
```

`identity.nix` mô tả hostname, username, system, timezone, state versions, roles và profiles. `machine` là production host; `ci` là host không phụ thuộc hardware thực tế để CI evaluate/build profiles.

Ví dụ tối giản:

```nix
{
  hostname = "nixos";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";
  roles = [ "completed" ];
  profiles = [ ];
}
```

## Profile và role

**Profile** là một capability. **Role** là một tập profile.

```text
role
 ├── profile
 ├── profile
 └── profile
```

Các role hiện tại:

| Role | Mục đích |
|---|---|
| `completed` | production host dùng toàn bộ profile hiện có |
| `ci` | CI evaluate toàn bộ profile |

Profile được phát hiện tự động từ `profiles/*.nix`, nên thêm profile mới không cần cập nhật thủ công danh sách profile của các role này.

> Lưu ý maintain mode: `completed` (production) và `ci` đều expand ra toàn bộ `profiles.available`.
> Thêm `profiles/<name>.nix` là tự động lên production ở lần `switch` tiếp theo.
> Đây là hành vi có chủ đích cho personal-use, không phải staging/canary.

Các profile hiện tại gồm: `ai`, `base`, `bitwarden`, `desktop`, `downloads`, `firefox`, `gaming`, `helium`, `hermes-agent`, `keepassxc`, `media`, `opencode`, `signal`, `telegram`, `terminal`, `terminal-ide`, `thunderbird`, `umbriel`, `vesktop` và `vietnamese-input`.

## Architecture policy

Project **chỉ hỗ trợ `x86_64-linux`**.

```text
Supported:
  x86_64-linux

Out of scope:
  i686 / 32-bit
  aarch64 / ARM
  mọi architecture khác
```

Đây là policy có chủ đích. Không có mục tiêu mở rộng sang ARM, 32-bit hoặc architecture khác. Framework và CI đều enforce policy này.

## Helium

Helium được tách thành repository `helium-nix` để giữ ranh giới giữa system configuration và binary packaging:

```text
nixos-portable
      │
      └── helium-nix
              │
              └── official Helium Linux release
```

Input:

```nix
helium = {
  url = "github:projectofwang/helium-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

`helium-nix` tự theo dõi release upstream và tạo PR khi có version mới. `nixos-portable` vẫn pin một revision cụ thể trong `flake.lock`; muốn đưa revision mới vào parent flake thì cập nhật có chủ đích:

```bash
nix flake lock --update-input helium
nix flake check
```

Không tự điền `narHash` bằng tay.

## CLI

```bash
nixos-portable check
nixos-portable build machine
nixos-portable switch machine
nixos-portable deploy machine root@server
```

Có thể chạy từ flake:

```bash
nix run .#nixos-portable -- check
nix run .#nixos-portable -- build machine
```

`deploy` hỗ trợ optional build host:

```bash
nixos-portable deploy machine root@server root@builder
```

CLI dùng `set -euo pipefail`, validate arguments và chuyển thao tác hệ thống cho `nixos-rebuild --flake`.

## Hardware và system configuration

Hardware-specific configuration nằm dưới `hosts/machine/`; reusable hardware modules nằm dưới `hardware/`.

Graphics, audio, networking, boot, desktop services và thiết bị ngoại vi hiện được tối ưu cho máy cá nhân. Chúng không được thiết kế như abstraction layer cho mọi hardware configuration.

`hosts/machine/networking.nix` dùng `dnscrypt-proxy` với `server_names = [ "sdns" ]`
(self-hosted, xem `Serverless-Edge-DNS-Gateway`) và `ignore_system_dns = true`.
Nếu resolver tự host down, máy mất DNS hoàn toàn. Fallback khẩn cấp:

```nix
# hosts/machine/networking.nix — tạm thời thay server_names
server_names = [ "cloudflare" ];
# hoặc: services.dnscrypt-proxy.enable = false;
# và networking.networkmanager.dns = "default";
```

sau đó `nixos-rebuild switch --flake .#machine`.

## CI và security

CI kiểm tra:

1. formatting;
2. framework tests;
3. CI host evaluation;
4. flake structure;
5. CLI;
6. toàn bộ profile × architecture matrix;
7. production host build.

Matrix chỉ có `x86_64-linux`.

GitHub Actions quan trọng được pin bằng commit SHA, checkout không giữ credentials và workflow permissions được giới hạn theo nhu cầu. CodeQL được dùng để kiểm tra GitHub Actions.

Local validation:

```bash
nix develop
nixos-portable check
nix flake check --no-write-lock-file
pre-commit run --all-files
```

## Maintenance

Development shell cung cấp các công cụ format, lint, validate và CLI.

Cập nhật dependencies có chủ đích (cadence khuyến nghị: monthly, hoặc khi cần security fix):

```bash
nix flake update
nix flake check
```

Sau mỗi `nix flake update`, kiểm tra lại `profiles/opencode.nix`:
patch `opencode-compiled-filesystem-cycle.patch` chỉ là workaround cho
`anomalyco/opencode#48397` (nixpkgs 1.18.30 + Bun 1.4.2). Nếu upstream đã fix,
bỏ override `programs.opencode.package`.

Quy trình vào maintain mode: giữ `main` xanh (`nixos-portable check` + CI),
chỉ update inputs, không sửa `lib/`. Tag stable commit:

```bash
git tag stable-2026-09-15
```

Các flake input là trust boundary của hệ thống. Khi đổi revision, nên xem xét diff và chạy validation trước khi sử dụng.

## Personal-use scope

Repository này được thiết kế **cho cá nhân tôi và các máy tôi trực tiếp quản lý**.

Không có cam kết về:

- backward compatibility;
- API stability;
- compatibility với hardware khác;
- release cadence;
- SLA hoặc support;
- khả năng sử dụng nguyên trạng bởi người khác.

Nếu một thay đổi phá vỡ cấu trúc cũ nhưng làm cấu hình cá nhân tốt hơn, thay đổi đó vẫn có thể được chấp nhận.

## License và third-party software

Repository chủ yếu chứa configuration, modules, framework code và automation của project cá nhân. Dependency và phần mềm bên thứ ba vẫn chịu license riêng của chúng. Việc sử dụng một dependency/input không đồng nghĩa project này sở hữu hoặc cấp lại license cho phần mềm upstream.

## Design principles

- **Personal first** — ưu tiên nhu cầu thực tế của chủ repository.
- **Reproducible** — lock inputs và fixed-output artifacts khi phù hợp.
- **Explicit** — architecture, host và profile policy được khai báo rõ.
- **Validated** — framework và production configuration đều được kiểm tra.
- **Small abstractions** — chỉ abstraction những gì thực sự cần dùng lại.
- **Upstream-aware** — dependency và binary input có nguồn gốc rõ ràng.
- **No fake compatibility** — không giả lập support cho platform không thuộc phạm vi.
