# Design Spec: Ổn định NixOS-Portable — Hướng B "Trưởng thành vận hành tối thiểu"

- Ngày: 2026-10-06
- Trạng thái: Đã duyệt (hướng B)
- Validation owner: orchestrator review
- Scope thay đổi của spec này: chỉ tạo file này; mọi sửa code nằm trong các phase P0–P6 bên dưới.

## 1. Mục tiêu + Non-goals

### Mục tiêu

1. Ổn định máy hiện tại (`hosts/machine`): lock file helium đồng bộ, DNS không còn đường gãy im lặng.
2. Multi-host: thêm host thứ 3 (và host tạm cho thử nghiệm VM) mà discovery framework không phải sửa tay.
3. Public chia sẻ được: README scope rõ ràng, hướng dẫn thêm host, CHANGELOG — giữ mô hình **personal-first, public-mirror**.
4. CI bắt được lỗi hỏng build/eval thực sự: thêm `nix flake check` + 1 boot test NixOS tối thiểu.

### Non-goals (cam kết không mở rộng)

- Không SLA, không backward-compat guarantee cho thay đổi cấu trúc (mirror công khai, người dùng tự pin rev).
- Không multi-arch (giữ `x86_64-linux` cho hai host hiện hữu).
- Không refactor lớn `lib/` (chỉ sửa đúng điểm chạm mỗi phase).
- Không thêm automation sops/restic — backup dừng ở mức tài liệu.
- Không CI full-boot toàn bộ matrix.
- Không docs site, không versioning tài liệu.

### Hiện trạng đã verify

- Discovery host qua `lib/hosts.nix` (readDir `hosts/`, validate `identity.nix`) + `framework.mkHost` (`flake.nix:50`).
- 2 host: `machine` (roles `[completed]`) và `ci` (ci/all), đều `x86_64-linux`, `profiles = []`.
- Role `completed` = bộ profile đầy đủ, assert cứng trong `tests/framework.nix:50`.
- DNS: assert cứng `productionConfig.services.dnscrypt-proxy.settings.server_names == [ "sdns" ]` tại `flake.nix:136`; fallback khẩn cấp là snippet thủ công trong `README.md:191-202`.
- CI (`.github/workflows/check.yml`): fmt check + eval framework/integration/ci + eval matrix + build matrix checks — **thiếu** `nix flake check` và **thiếu** boot test `nixosTest`.
- `flake.lock` helium đang pin `35720b01` (dòng 89), lag so với `0ccdc14`.

## 2. Approaches

### A. Mở rộng tối đa (infra trưởng thành đầy đủ)

Multi-arch matrix, sops/restic automation, CI full-boot, docs site, versioning.

- Ưu điểm: bao trọn mọi rủi ro vận hành.
- Nhược điểm: contradicts personal-first-public-mirror; chi phí CI/duy trì vượt giá trị khi mới 2–3 host; vi phạm non-goals.

### B. Trưởng thành vận hành tối thiểu (CHỌN)

Đúng 7 phase P0–P6: khoá lock, DNS opt-in fallback, tài liệu backup, host tạm, host thứ 3 subset, README/CHANGELOG, CI flake check + 1 nixosTest boot.

- Ưu điểm: mỗi phase verify độc lập, diff nhỏ, không đụng cấu trúc `lib/`; sửa đúng nguyên nhân gốc (lock lag, assert chết gãy DNS, CI không bắt lỗi boot).
- Nhược điểm: backup vẫn thủ công, CI vẫn không boot toàn matrix — chấp nhận được vì non-goals đã loại.

### C. Ổn định bằng documentation-only

Chỉ viết README/CHANGELOG, không sửa lock/CI/DNS.

- Ưu điểm: không rủi ro regression.
- Nhược điểm: không xử lý được lỗi thật (lock helium lag, DNS gãy im lặng, CI mù boot) — thất bại mục tiêu "ổn định máy hiện tại".

**Chọn B**: là đường ngắn nhất xử lý đủ 4 mục tiêu, mỗi bước có tiêu chí verify chạy được, không đụng phần bị coi là non-goal.

## 3. Pha P0–P6

Mỗi phase ghi: việc — file chạm — verify. Merge lần lượt, phase sau không bắt đầu khi phase trước verify pass.

### P0 — Lock helium + flake check

- Việc: update `flake.lock` để helium pin `0ccdc14` (chấm dứt lag `35720b01`); chạy `nix flake check` cục bộ một lần để bắt assert/eval vỡ trước khi đẩy phase sau.
- File chạm: `flake.lock` (không sửa `flake.nix` trừ khi flake check bắt lỗi thật — nếu có, sửa tối thiểu tại đúng dòng lỗi).
- Verify: `git diff flake.lock` chỉ có node helium đổi rev sang `0ccdc14`; `nix flake check --no-write-lock-file` exit 0.

### P1 — DNS fallback opt-in (mặc định tắt) + eval test

- Việc: bỏ đường gãy im lặng khi resolver self-hosted `sdns` down. Thêm cơ chế fallback **opt-in, default off**: cấu hình production mặc định giữ nguyên `server_names = [ "sdns" ]`; fallback (ví dụ qua biến/option `enableDnsFallback`) chỉ đổi sang resolver dự phòng khi người dùng tự bật. Không hardcode snippet tay như README hiện tại.
- File chạm: `hosts/machine/networking.nix`, `flake.nix` (assert `flake.nix:136-137` nới lỏng để chấp nhận biến fallback mà vẫn assert giá trị mặc định là `[ "sdns" ]`), `tests/framework.nix` (thêm eval test: mặc định = `[ "sdns" ]`, bật fallback = list chứa resolver dự phòng).
- Verify: `nix flake check` pass (assert cũ + eval test mới); `nix eval .#nixosConfigurations.machine.config.services.dnscrypt-proxy.settings.server_names` trả `[ "sdns" ]` khi mặc định.

### P2 — Backup: tài liệu declarative vs user-data

 Việc: viết docs phân định rõ hai lớp backup — cấu trúc declarative (repo git, khôi phục bằng clone + rebuild) và user-data/secret (ngoài Nix store, phải backup riêng bằng công cụ ngoài repo). Không viết automation.
- File chạm: `docs/backup.md` (tạo mới), liên kết từ README.
- Verify: docs tồn tại, nêu được 2 lớp, nêu được công cụ cụ thể cho user-data và khẳng định không có automation trong scope.

### P3 — Host/VM tạm thời

- Việc: cho phép host tạm (thử VM/kiểm thử) tồn tại mà không lọt vào production/CI matrix chính — tận dụng discovery sẵn có, không hardcode danh sách host.
- File chạm: `lib/hosts.nix` hoặc `lib/roles.nix` (tách host tạm khỏi default production set — chỉ thêm cơ chế đánh dấu tối thiểu), `hosts/<ten-tam>/identity.nix` (tạo khi cần).
- Verify: `nix flake check` pass; host tạm không xuất hiện trong `nix eval .#lib.ciMatrix` output; host `machine` vẫn là default.

### P4 — Host thứ 3 (permanent, subset profile, không dùng `completed`)

- Việc: thêm host permanent với roles **subset** (ví dụ roles cụ thể thay vì `completed`), chứng minh discovery + matrix đa-host hoạt động mà không sửa `lib/hosts.nix`.
- File chạm: `hosts/<ten-host-3>/identity.nix`, `hosts/<ten-host-3>/default.nix`, module riêng trong `hosts/<ten-host-3>/`; `flake.nix` chỉ sửa nếu matrix cần khai báo thêm (ưu tiên không sửa).
- Verify: `nix flake check` pass; `nix eval .#nixosConfigurations.<ten>.config.system.build.toplevel.drvPath` exit 0; host thứ 3 xuất hiện trong `lib.ciEvaluationMatrix`; roles của nó **không** chứa `completed`; `tests/framework.nix` vẫn pass (assert `completed` không bị vi phạm).

### P5 — README scope + hướng dẫn thêm host + CHANGELOG

- Việc: README ghi rõ scope personal-first-public-mirror (không SLA/back-compat); mục "thêm host mới" liệt kê các bước bắt buộc (`identity.nix` các field, `default.nix`, discovery, eval); cập nhật phần DNS (`README.md:191-202`) cho khớp cơ chế opt-in của P1; tạo CHANGELOG ghi các phase P0–P6.
- File chạm: `README.md`, `CHANGELOG.md` (tạo mới).
- Verify: README không còn snippet fallback thủ công P1-đã-thay-đổi; có đủ 3 mục scope/thêm host/DNS mới; CHANGELOG liệt kê P0–P6.

### P6 — CI: thêm flake check + 1 nixosTest boot minimal

- Việc: `.github/workflows/check.yml` thêm bước `nix flake check --no-write-lock-file`; thêm 1 NixOS test (`nixosTest`) boot minimal — VM boot 1 host cấu hình nhỏ (dùng host `ci` hoặc module thu nhỏ), chạy 1 assertion đơn giản (systemd lên, networking OK). Chỉ **một** test, không full-boot matrix.
- File chạm: `.github/workflows/check.yml`, `tests/` (thêm file nixosTest mới), `flake.nix` (đăng ký check vào `checks` nếu chưa tự động).
- Verify: CI xanh; bước flake check và nixosTest có trong log; `nix flake check` cục bộ chạy qua nixosTest.

## 4. KHÔNG làm

- Multi-arch (giữ `x86_64-linux`).
- SLA / backward-compat guarantee.
- Refactor lớn `lib/` (đổi tên module, tái cấu trúc discovery, đổi identity schema).
- Thêm automation sops/restic (backup = docs, xem P2).
- CI full-boot toàn bộ host matrix (chỉ 1 nixosTest, P6).
- Docs site, versioning, release process.

## 5. Rủi ro + Cách giảm thiểu

| Rủi ro | Giảm thiểu |
| --- | --- |
| Update lock helium (`0ccdc14`) kéo theo regression eval/build | P0 chạy `nix flake check` trước, ghi nhận rev; nếu fail → revert lock, báo orchestrator thay vì sửa lén |
| Assert DNS `flake.nix:136` sửa sai làm lọt cấu hình DNS sai ra production | P1 giữ assert cho giá trị mặc định; eval test phủ 2 nhánh (mặc định/fallback) |
| Cơ chế host tạm vô tình lọt CI matrix, CI chậm/cháy | P3 verify bằng `nix eval .#lib.ciMatrix` phải loại host tạm |
| Host thứ 3 dùng `completed` phá assertion `tests/framework.nix:50` | P4 yêu cầu roles subset, không `completed`; `nix flake check` là gate |
| Thêm nixosTest làm CI quá chậm vượt ngưỡng | P6 chỉ 1 test minimal; nếu > 10 phút → giảm scope test, không remove flake check |
| README/CHANGELOG lệch thực tế sau các phase | P5 viết sau cùng, đối chiếu lại P0–P4 đã merge |
| Scope creep thành hướng A | Mục 4 là danh sách chặn; mọi đề xuất ngoài scope trả về orchestrator |

## 6. Tiêu chí nghiệm thu cuối

Tất cả phải đúng một lần, chạy trên máy hiện tại:

1. `flake.lock` helium pin `0ccdc14` (không còn `35720b01`).
2. `nix flake check --no-write-lock-file` exit 0, bao gồm assert DNS + eval test fallback + nixosTest boot.
3. `nix eval .#nixosConfigurations.machine.config.services.dnscrypt-proxy.settings.server_names` = `[ "sdns" ]` khi fallback default off; bật opt-in đổi được sang resolver dự phòng.
4. `docs/backup.md` tồn tại, phân định declarative vs user-data, không có automation.
5. Host tạm (nếu có) không nằm trong `lib.ciMatrix`; `machine` vẫn default.
6. Host thứ 3 (permanent) eval được, nằm trong `lib.ciEvaluationMatrix`, roles không chứa `completed`.
7. README có scope personal-first-public-mirror + guide thêm host + DNS mới; CHANGELOG ghi P0–P6.
8. CI `.github/workflows/check.yml` có bước `nix flake check` và 1 bước nixosTest boot minimal; CI xanh.
9. Không có thay đổi nào thuộc mục 4 (KHÔNG làm).
10. Orchestrator review pass (validation owner).
