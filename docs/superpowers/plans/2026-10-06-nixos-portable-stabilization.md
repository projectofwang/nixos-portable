# Plan: Ổn định NixOS-Portable — Hướng B "Trưởng thành vận hành tối thiểu"

- **Goal**: Đưa repo đạt đủ 7 phase P0–P6 của spec — lock helium đồng bộ, DNS fallback opt-in, docs backup, host tạm + host thứ 3, README/CHANGELOG, CI flake check + 1 nixosTest — giữ nguyên personal-first-public-mirror.
- **Architecture**: Framework discovery host hiện có (`lib/hosts.nix` readDir + `framework.mkHost`) được giữ nguyên, mỗi phase chỉ sửa đúng điểm chạm; DNS mặc định vẫn `server_names = [ "sdns" ]`, fallback chỉ qua option opt-in default off; CI mở rộng thêm `nix flake check` và đúng 1 NixOS boot test, không full-boot matrix.
- **Tech Stack**: Nix flake (nixosConfigurations, checks, lib), GitHub Actions, NixOS VM test (`nixosTest`).
- **Spec path**: `docs/superpowers/specs/2026-10-06-nixos-portable-stabilization-design.md`
- **Global Constraints**:
  - Giữ `x86_64-linux`, không multi-arch.
  - Personal-first public mirror: không SLA, không back-compat guarantee.
  - Default DNS luôn `[ "sdns" ]`; fallback opt-in default off.
  - Không refactor lớn `lib/`, không automation sops/restic, không CI full-boot matrix, không docs site.
  - Mỗi phase: verify pass rồi mới commit, phase sau không bắt đầu khi phase trước fail.
- **Review Focus** (5 dòng):
  1. `flake.lock` chỉ đổi node helium sang `0ccdc14`, không lẫn rev khác.
  2. Assert DNS giữ đúng giá trị mặc định `[ "sdns" ]` khi sửa `flake.nix:136-137`; eval test phủ cả 2 nhánh mặc định/fallback.
  3. Host tạm không lọt `lib.ciMatrix`; host thứ 3 không dùng role `completed`.
  4. CI thêm đúng 2 thứ (flake check + 1 nixosTest), không mở rộng scope.
  5. Diff không đụng mục "KHÔNG làm" của spec (multi-arch, sops/restic automation, refactor `lib/`).

---

## Task P0 — Lock helium + flake check

**Files chạm**: `flake.lock` (`flake.nix` chỉ khi flake check bắt lỗi thật — sửa tối thiểu đúng dòng lỗi)

- [ ] Baseline: `nix flake check --no-write-lock-file` trước khi update, ghi nhận lỗi hiện có (nếu có).
- [ ] Implement: `nix flake update helium` (hoặc sửa node helium trong `flake.lock` pin rev `0ccdc14`); không đụng node khác.
- [ ] Verify: `git diff flake.lock` chỉ có node helium đổi `35720b01` → `0ccdc14`.
- [ ] Verify: `nix flake check --no-write-lock-file` exit 0.
- [ ] Commit: `chore(lock): pin helium to 0ccdc14`.

## Task P1 — DNS fallback opt-in (default off) + eval test

**Files chạm**: `hosts/machine/networking.nix`, `flake.nix` (assert dòng 136-137), `tests/framework.nix`

- [ ] TDD red: thêm eval test vào `tests/framework.nix` — nhánh mặc định `server_names == [ "sdns" ]`, nhánh bật `enableDnsFallback` → list chứa resolver dự phòng; chạy `nix flake check --no-write-lock-file` → fail (chưa có option).
- [ ] Implement: thêm option `enableDnsFallback` (default `false`) trong `hosts/machine/networking.nix`; nới assert `flake.nix:136-137` chấp nhận biến fallback nhưng vẫn assert giá trị mặc định là `[ "sdns" ]`.
- [ ] Verify: `nix flake check --no-write-lock-file` exit 0 (assert cũ + eval test mới).
- [ ] Verify: `nix eval .#nixosConfigurations.machine.config.services.dnscrypt-proxy.settings.server_names --no-write-lock-file` → `[ "sdns" ]`.
- [ ] Commit: `feat(dns): opt-in fallback, default off, with eval tests`.

## Task P2 — Backup doc: declarative vs user-data

**Files chạm**: `docs/backup.md` (mới), `README.md` (link)

- [x] Viết `docs/backup.md`: lớp 1 declarative (repo git, khôi phục = clone + `nixos-rebuild switch --flake .#machine`), lớp 2 user-data/secret (ngoài Nix store, backup riêng bằng công cụ ngoài repo, nêu tên công cụ cụ thể), khẳng định không có automation trong scope.
- [x] Implement: link `docs/backup.md` từ README.
- [x] Verify: grep README có link `docs/backup.md`; docs có đủ 2 lớp + tên công cụ user-data.
- [x] Commit: `docs(backup): declarative vs user-data layers`.

## Task P3 — Host/VM tạm thời

**Files chạm**: `lib/hosts.nix` hoặc `lib/roles.nix` (cơ chế đánh dấu tối thiểu), `hosts/<ten-tam>/identity.nix` (khi cần)

- [ ] Implement: thêm cơ chế đánh dấu host tạm (ý định: tách khỏi default production set, không hardcode danh sách host, tận dụng discovery sẵn có) — diff tối thiểu trong `lib/`.
- [ ] Assert/eval test: thêm case vào `tests/framework.nix` — host đánh dấu tạm không thuộc production set; `nix flake check --no-write-lock-file` red trước khi implement phần lib.
- [ ] Verify: `nix flake check --no-write-lock-file` exit 0.
- [ ] Verify: `nix eval .#lib.ciMatrix --json --no-write-lock-file` không chứa host tạm; `nix eval .#lib.hosts.default --no-write-lock-file` vẫn là `"machine"` (hoặc đọc `framework.hosts.default` tương ứng).
- [ ] Commit: `feat(hosts): mark temporary hosts out of production matrix`.

## Task P4 — Host thứ 3 (permanent, subset roles, không `completed`)

**Files chạm**: `hosts/<ten-host-3>/identity.nix`, `hosts/<ten-host-3>/default.nix`, module trong `hosts/<ten-host-3>/`; `flake.nix` chỉ nếu matrix buộc phải khai báo (ưu tiên không sửa)

- [ ] TDD red: assert trong `tests/framework.nix` — host thứ 3 có mặt trong discovery nhưng roles không chứa `completed`; chạy `nix flake check --no-write-lock-file` → fail khi chưa có host.
- [ ] Implement: tạo `hosts/<ten-host-3>/identity.nix` (`system = "x86_64-linux"`, `roles` = subset, `profiles` = []) + `default.nix` + module; không sửa `lib/hosts.nix`.
- [ ] Verify: `nix flake check --no-write-lock-file` exit 0.
- [ ] Verify: `nix eval .#nixosConfigurations.<ten-host-3>.config.system.build.toplevel.drvPath --no-write-lock-file` exit 0.
- [ ] Verify: `nix eval .#lib.ciEvaluationMatrix --json --no-write-lock-file` chứa host thứ 3; output `identity.roles` không chứa `"completed"`.
- [ ] Commit: `feat(hosts): add third permanent host with subset roles`.

## Task P5 — README scope + guide thêm host + CHANGELOG

**Files chạm**: `README.md`, `CHANGELOG.md` (mới)

- [ ] Implement README: (a) mục scope personal-first-public-mirror — không SLA/back-compat; (b) guide "thêm host mới": các field bắt buộc của `identity.nix`, `default.nix`, discovery tự chạy, lệnh eval kiểm thử; (c) cập nhật phần DNS `README.md:191-202` cho khớp option opt-in P1, xóa snippet fallback thủ công.
- [ ] Implement: tạo `CHANGELOG.md` liệt kê P0–P6.
- [ ] Verify: grep README không còn snippet `server_names = [ "cloudflare" ]` thủ công; README có 3 mục scope/thêm host/DNS mới; `CHANGELOG.md` liệt kê đủ P0–P6.
- [ ] Commit: `docs: scope, add-host guide, DNS fallback, CHANGELOG`.

## Task P6 — CI: flake check + 1 nixosTest boot minimal

**Files chạm**: `.github/workflows/check.yml`, file nixosTest mới trong `tests/`, `flake.nix` (đăng ký vào `checks` nếu chưa tự động)

- [ ] TDD red: viết 1 `nixosTest` minimal (boot VM, assert systemd active + networking OK) trong `tests/`; đăng ký vào `checks`; `nix flake check --no-write-lock-file` chạy qua nó (chưa đăng ký CI thì red ở bước sau).
- [ ] Implement: thêm bước `nix flake check --no-write-lock-file` vào `.github/workflows/check.yml`.
- [ ] Verify: `nix flake check --no-write-lock-file` cục bộ exit 0, log có chạy nixosTest.
- [ ] Verify: `nix build .#checks.x86_64-linux.<ten-nixosTest> --no-link --no-write-lock-file` exit 0.
- [ ] Verify: CI xanh, log có bước flake check + nixosTest (nếu test > 10 phút → giảm scope test, không remove flake check).
- [ ] Commit: `ci: add flake check and minimal nixosTest boot`.

---

## Summary

1. Plan 7 task P0–P6, mỗi task đúng pattern: red test/assert → `nix flake check --no-write-lock-file` → implement → verify bằng lệnh `nix eval`/`nix build` cụ thể → commit.
2. Global constraints giữ nguyên từ spec: `x86_64-linux`, personal-first no SLA, default DNS `[ "sdns" ]`, không refactor `lib/`, không full-boot CI.
3. Files chạm được lấy trực tiếp từ spec (lock, DNS assert `flake.nix:136-137`, `lib/hosts.nix`, `hosts/<ten>`, README/CHANGELOG, `check.yml`, `tests/`).
4. Review focus 5 dòng tập trung vào các điểm rủi ro cao nhất: lock rev, assert DNS, host tạm/host thứ 3 lọt matrix, scope CI, danh sách "KHÔNG làm".
5. File đã tạo: `docs/superpowers/plans/2026-10-06-nixos-portable-stabilization.md`.
