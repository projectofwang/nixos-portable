# nixos-portable

`nixos-portable` là cấu hình NixOS dạng flake, dùng một host template chung, tách machine identity khỏi phần cấu hình dùng lại, và ghép hệ thống bằng các profile tùy chọn. Home Manager quản lý cấu hình người dùng; mỗi profile chỉ thêm phần chức năng thuộc trách nhiệm của nó.

## Kiến trúc

```text
flake.nix
├── hosts/
│   ├── machine/
│   │   ├── identity.nix
│   │   ├── hardware-configuration.nix
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   └── default.nix
│   └── ci/default.nix
├── lib/
│   ├── default.nix
│   ├── mk-host.nix
│   ├── profiles.nix
│   └── home-manager.nix
├── profiles/
├── modules/
│   ├── nixos/
│   └── home-manager/
├── home/default.nix
└── .github/workflows/check.yml
```

Luồng cấu hình:

```text
hosts/machine/identity.nix
        │
        ▼
lib/mk-host.nix
        │
        ├── host module
        ├── Home Manager
        └── selected profiles
                │
                ▼
        modules/nixos + modules/home-manager
```

`identity.nix` là nơi chọn machine identity và profile. `mk-host.nix` biến dữ liệu đó thành `nixosSystem`. Profile chỉ là composition layer; module chứa implementation.

Machine mới chủ yếu cần thay:

1. `hosts/machine/hardware-configuration.nix`
2. `hosts/machine/identity.nix`
3. `hosts/machine/boot.nix` nếu bootloader khác
4. `hosts/machine/networking.nix` nếu networking khác

## Cấu trúc thư mục

### `flake.nix`

Điểm vào của toàn bộ flake.

- `description`: tên và mục đích flake.
- `inputs.nixpkgs`: nguồn NixOS.
- `inputs.home-manager`: Home Manager dùng cùng `nixpkgs`.
- `inputs.fcitx5-lotus`: module và package nhập tiếng Việt.
- `inputs.noctalia`: Noctalia.
- `inputs.noctalia-greeter`: greeter.
- `inputs.xdg-desktop-portal-umbriel`: portal backend cho Umbriel.
- `inputs.umbriel`: compositor.
- `inputs.helium`: module/package cho Helium Browser.
- `framework = import ./lib`: nạp host builder.
- `machine = import ./hosts/machine/identity.nix`: đọc machine identity.
- `production`: tạo host thật từ machine identity.
- `ciMachine`: tạo machine giả lập để CI có thể evaluate/build plan mà không cần hardware thật.
- `nixosConfigurations`: xuất production host và `ci`.
- `checks.x86_64-linux.ci`: build target dùng cho CI.
- `formatter`: dùng `nixfmt` cho hệ thống tương ứng.

Ví dụ:

```bash
sudo nixos-rebuild build --flake .#nixos
```

### `flake.lock`

Khóa revision của các flake input. Không sửa thủ công; cập nhật bằng lệnh Nix.

Ví dụ:

```bash
nix flake lock --update-input nixpkgs
```

### `home/default.nix`

Thiết lập các giá trị Home Manager cơ bản từ machine identity:

- `home.username`: username.
- `home.homeDirectory`: `/home/<username>`.
- `home.stateVersion`: phiên bản state của Home Manager.

Ví dụ với username `alice` tạo `/home/alice`.

### `hosts/machine/`

Đây là phần machine-specific.

#### `hosts/machine/identity.nix`

Nơi khai báo:

```nix
{
  hostname = "nixos";
  username = "alice";
  system = "x86_64-linux";
  timeZone = "Asia/Ho_Chi_Minh";
  nixosStateVersion = "26.05";
  homeStateVersion = "26.05";
  profiles = [ "base" "terminal" ];
}
```

Ý nghĩa:

- `hostname`: hostname hệ thống.
- `username`: user chính.
- `system`: target platform.
- `timeZone`: timezone.
- `nixosStateVersion`: state version của NixOS.
- `homeStateVersion`: state version của Home Manager.
- `profiles`: danh sách profile được ghép vào host.

Đây là file chính cần sửa khi chuyển cấu hình sang machine khác.

#### `hosts/machine/hardware-configuration.nix`

Placeholder cho hardware configuration của machine thật. Phải thay bằng file được tạo trên machine đích.

Ví dụ:

```bash
sudo nixos-generate-config --show-hardware-config > hosts/machine/hardware-configuration.nix
```

#### `hosts/machine/boot.nix`

Thiết lập systemd-boot và cho phép NixOS cập nhật EFI variables.

Ví dụ cấu hình hiện tại dùng:

```nix
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
```

#### `hosts/machine/networking.nix`

Thiết lập NetworkManager, DNS và firewall.

- DNS ưu tiên local `dnscrypt-proxy`.
- `1.1.1.1` là fallback.
- `systemd-resolved` bị tắt.
- NetworkManager quản lý network.
- firewall được bật.

Ví dụ DNS local:

```text
127.0.0.1:53
[::1]:53
```

#### `hosts/machine/default.nix`

Gộp ba module machine-specific:

```text
hardware-configuration.nix
boot.nix
networking.nix
```

### `hosts/ci/default.nix`

Host NixOS tối giản dành cho CI. Nó bật container mode và cung cấp root filesystem `tmpfs` để NixOS có thể evaluate mà không cần hardware configuration thật.

### `lib/`

Lớp framework nội bộ dùng để tạo host.

#### `lib/default.nix`

Nạp `profiles.nix` và `mk-host.nix`, sau đó export `profiles` và `mkHost`.

Ví dụ:

```nix
framework.mkHost { ... }
```

#### `lib/profiles.nix`

Đọc các file `profiles/*.nix`, lấy tên profile từ filename và kiểm tra profile được chọn có tồn tại.

Ví dụ:

```text
profiles/terminal.nix → "terminal"
```

Nếu machine chọn profile không tồn tại, evaluation dừng với lỗi liệt kê profile hợp lệ.

#### `lib/home-manager.nix`

Tạo cấu hình Home Manager dùng chung:

- `useGlobalPkgs = true`: dùng package set của hệ thống.
- `useUserPackages = true`: package user được quản lý bởi Home Manager.
- `backupFileExtension`: extension cho file backup.
- `extraSpecialArgs`: truyền input và state version vào module.
- `users.<username>`: nạp `modules/home-manager` và `home/default.nix`.

#### `lib/mk-host.nix`

Hàm `mkHost` là composition root.

Nó:

1. validate profile.
2. tạo Home Manager.
3. gọi `lib.nixosSystem`.
4. truyền machine values qua `specialArgs`.
5. import host module.
6. import Home Manager.
7. import từng profile.
8. đặt `system.stateVersion`.

Ví dụ:

```nix
mkHost {
  machine = machine;
  hostModule = ./hosts/machine;
}
```

### `modules/nixos/`

Nơi chứa implementation cấp hệ thống.

#### `modules/nixos/core/nix.nix`

Thiết lập Nix:

- tắt channel cũ.
- bật `nix-command` và `flakes`.
- chỉ `root` là trusted user.
- bật automatic store optimisation.
- garbage collection hàng tuần.
- xóa generation/store item cũ hơn 30 ngày.

Ví dụ:

```bash
nix flake show
```

#### `modules/nixos/core/system.nix`

Đặt hostname và timezone từ machine identity bằng `lib.mkDefault`.

Ví dụ:

```text
hostname = nixos
timezone = Asia/Ho_Chi_Minh
```

#### `modules/nixos/core/users.nix`

Tạo normal user, shell zsh và các group cơ bản.

- `wheel`: sudo.
- `networkmanager`: quản lý network.
- `programs.zsh.enable`: bật zsh ở cấp NixOS.
- password không được hard-code vào cấu hình.

#### `modules/nixos/core/security.nix`

Bật sudo và để polkit ở `false` mặc định để module desktop có thể override khi cần.

#### `modules/nixos/core/tools.nix`

Cài `git` ở cấp system.

#### `modules/nixos/graphics.nix`

Module graphics dùng chung cho các profile cần acceleration.

Bật:

```nix
hardware.graphics.enable = true;
hardware.graphics.enable32Bit = true;
```

Ví dụ profile browser và gaming cùng import module này thay vì khai báo trùng.

#### `modules/nixos/browser/default.nix`

Shared browser/Wayland layer.

- import graphics.
- bật `MOZ_ENABLE_WAYLAND`.
- bật `NIXOS_OZONE_WL`.
- cài `libva-utils` và `vulkan-tools`.

Browser cụ thể được chọn bởi profile `browser-firefox` hoặc `browser-helium`.

#### `modules/nixos/desktop/default.nix`

Cấp system cho desktop stack:

- Umbriel.
- Noctalia.
- Noctalia Greeter.
- PipeWire.
- RTKit.
- XDG desktop portal GTK.
- `gpu-screen-recorder`.
- Krusader.
- Home Manager desktop module.

Noctalia screen recorder được bật từ Home Manager bằng plugin chính thức.

### `modules/home-manager/`

Nơi quản lý user environment và ứng dụng user-level.

#### `modules/home-manager/default.nix`

Chỉ import `shell.nix`. Đây là baseline Home Manager.

#### `modules/home-manager/shell.nix`

Cấu hình shell và CLI environment:

- Bash.
- Zsh.
- Starship.
- direnv + nix-direnv.
- zoxide.
- Atuin.
- fzf.
- bat.
- eza.
- fzf-tab.
- `fd`.
- `ripgrep`.

Ví dụ alias:

```text
ls   → eza
cat  → bat
find → fd
cd   → z
```

#### `modules/home-manager/terminal.nix`

Cấu hình terminal GUI và multiplexer:

- WezTerm.
- Zellij.
- btop.
- cava.
- fastfetch.
- jq.
- tree.
- yazi.

WezTerm mở Zellij làm chương trình mặc định. Zellij dùng Neovim làm scrollback editor.

#### `modules/home-manager/lazyvim.nix`

Ownership duy nhất của terminal Neovim/LazyVim.

- bật Neovim.
- đặt làm default editor.
- bật `vi`/`vim` alias.
- cài language server và formatter cần thiết.
- bootstrap LazyVim từ nixpkgs.
- dùng `linkFarm` để cung cấp plugin path ổn định cho Lazy.

Ví dụ:

```bash
nvim
```

#### `modules/home-manager/ide.nix`

Ownership của GUI IDE Zed.

- bật Zed.
- khóa mutable user settings.
- cài extension Nix/TOML/Rust.
- format on save.
- terminal làm việc tại project directory.

#### `modules/home-manager/ai-integration.nix`

Lớp integration, không phải AI server.

- nếu Zed đã bật: cấu hình provider `llama.cpp` tại `127.0.0.1:8080`.
- nếu Neovim đã bật: thêm CodeCompanion với OpenAI-compatible endpoint.
- AI profile không tự cài Zed hay Neovim.

Ví dụ model:

```text
qwen3.5-4b
```

#### `modules/home-manager/desktop/default.nix`

Bật Noctalia và declaratively enable plugin:

```text
noctalia/screen_recorder
```

#### `modules/home-manager/umbriel.nix`

Bật Umbriel trong Home Manager và lấy cấu hình từ `umbriel/config.toml`.

#### `modules/home-manager/umbriel/config.toml`

Cấu hình runtime cho Umbriel:

- autostart Noctalia.
- XWayland.
- appearance/blur/shadow.
- keyboard/touchpad/mouse.
- workspace switching.
- window focus và window management.
- terminal/file manager launch.
- Noctalia launcher/clipboard/wallpaper/settings.
- volume controls.
- screenshots.

Ví dụ:

```text
Mod+Return → WezTerm
Mod+E      → Krusader
Mod+Space  → Noctalia launcher
Mod+Q      → đóng window
```

## Profiles

Profile là đơn vị lựa chọn chức năng cho từng machine. Profile không nên chứa chức năng không liên quan đến tên của nó.

| Profile | Nội dung |
|---|---|
| `base` | Nix, system identity, user, security, git |
| `desktop` | Umbriel, Noctalia, greeter, PipeWire, portal, desktop dependencies |
| `terminal` | WezTerm, Zellij và CLI terminal stack |
| `terminal-ide` | `terminal` + LazyVim/Neovim |
| `browser-firefox` | browser shared layer + Firefox |
| `browser-helium` | browser shared layer + Helium |
| `gaming` | graphics + GameMode + Steam |
| `ai` | llama.cpp server + editor integrations nếu editor đã bật |
| `ide` | Zed |
| `media` | mpv, mpvpaper, VLC, Stremio |
| `downloads` | qBittorrent GUI |
| `mail-thunderbird` | Thunderbird |
| `password-bitwarden` | Bitwarden Desktop |
| `password-keepassxc` | KeePassXC |
| `umbriel` | Umbriel user configuration |
| `vietnamese-input` | Fcitx5 + Lotus Vietnamese input |

Ví dụ machine dùng terminal + Zed + AI:

```nix
profiles = [
  "base"
  "terminal"
  "ide"
  "ai"
];
```

Ví dụ terminal IDE không cần Zed:

```nix
profiles = [
  "base"
  "terminal-ide"
];
```

`ai` có thể đi cùng `ide`, `terminal-ide`, cả hai, hoặc không editor nào. Khi không có editor, AI profile chỉ cung cấp server.

## Luật ownership

```text
base
 └── core system

terminal
 └── WezTerm + Zellij + CLI

terminal-ide
 └── terminal
 └── LazyVim / Neovim

ide
 └── Zed

ai
 └── llama.cpp
      ├── Zed integration nếu Zed tồn tại
      └── CodeCompanion nếu Neovim tồn tại

desktop
 └── Umbriel + Noctalia + desktop plumbing
```

Các nguyên tắc chính:

- Không cài GUI/IDE/AI vào `base`.
- Không cấu hình Neovim trong `terminal.nix`.
- Không để `ai` tự chọn editor.
- Không khai báo graphics lặp lại giữa browser và gaming.
- Machine-specific values nằm ở `hosts/machine`.
- Profile selection nằm ở `hosts/machine/identity.nix`.
- `flake.lock` là lockfile, không phải nơi cấu hình chức năng.

## Cài đặt trên machine mới

### 1. Clone

```bash
git clone https://github.com/projectofwang/nixos-portable.git
cd nixos-portable
```

### 2. Tạo hardware configuration

```bash
sudo nixos-generate-config --show-hardware-config > hosts/machine/hardware-configuration.nix
```

### 3. Sửa machine identity

```text
hosts/machine/identity.nix
```

Thay `hostname`, `username`, `system` và chọn `profiles` cần dùng.

### 4. Kiểm tra

```bash
nix fmt -- --check $(git ls-files '*.nix')
nix eval .#nixosConfigurations.ci.config.system.build.toplevel.drvPath --no-write-lock-file
nix build .#checks.x86_64-linux.ci --no-link --dry-run --no-write-lock-file
nix flake show --no-write-lock-file
```

### 5. Build

```bash
sudo nixos-rebuild build --flake .#<hostname>
```

### 6. Switch

Chỉ switch sau khi build thành công:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

## CI

Workflow nằm tại `.github/workflows/check.yml`.

CI thực hiện:

1. checkout repository.
2. cài Nix với flakes.
3. kiểm tra formatting Nix.
4. evaluate CI system.
5. kiểm tra build plan của CI target.
6. hiển thị flake outputs.

Production host không được evaluate trên GitHub runner vì hardware configuration là machine-specific. CI dùng `nixosConfigurations.ci` thay thế.

## Cách đọc một module Nix

Các pattern chính trong repository:

| Cấu trúc | Tác dụng | Ví dụ |
|---|---|---|
| `{ pkgs, ... }:` | nhận package set từ NixOS/Home Manager | `{ pkgs, ... }:` |
| `{ username, ... }:` | nhận machine username | `users.users.${username}` |
| `imports = [ ... ];` | ghép module khác | `imports = [ ./shell.nix ];` |
| `lib.mkDefault` | đặt default nhưng cho module khác override | `security.polkit.enable = lib.mkDefault false;` |
| `lib.mkIf` | chỉ áp dụng cấu hình khi điều kiện đúng | `lib.mkIf config.programs.neovim.enable` |
| `lib.mkMerge` | hợp nhất nhiều nhánh module | AI integrations |
| `${name}` | interpolation | `/home/${username}` |
| `with pkgs; [ ... ]` | lấy package trực tiếp từ `pkgs` | `[ git ripgrep fd ]` |
| `home-manager.users.<user>` | cấu hình Home Manager từ NixOS | `home-manager.users.${username}.imports` |
| `nixpkgs.config.allowUnfreePackages` | mở unfree package có scope | Steam, Stremio |
| `system.stateVersion` | giữ semantics state của NixOS | `26.05` |

## Trạng thái kiểm tra

Commit hiện tại đã được CI kiểm tra với toàn bộ các bước formatting, evaluation, build-plan và flake output thành công.
