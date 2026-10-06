# Backup

Backup chia thành hai lớp tách bạch. Mỗi lớp có công cụ và quy trình riêng; không lớp nào được khôi phục bằng công cụ của lớp kia.

## Lớp 1 — Declarative (repo git)

Toàn bộ cấu hình khai báo (host, profile, role, module, flake input) nằm trong repo này và được version control bằng git; `flake.lock` pin đúng revision đã kiểm chứng. Git history là bản backup của lớp này — không cần backup thêm artifact nào khác.

Khôi phục trên máy mới:

```bash
git clone <repo-url> nixos-portable
cd nixos-portable
nixos-rebuild switch --flake .#machine
```

Clone lấy đúng revision đã lock, `nixos-rebuild` dựng lại cấu hình declarative đúng như trước.

## Lớp 2 — User-data và secret (ngoài Nix store)

Dữ liệu người dùng và secret — home directory, credential/key, database, file cá nhân — **không** nằm trong Nix store và **không** được `nixos-rebuild` khôi phục. Lớp này phải được backup riêng bằng công cụ backup nằm ngoài repo này, ví dụ **restic** (hoặc BorgBackup) trỏ tới repository backup riêng của bạn (remote hoặc ổ lưu trữ ngoài).

Repo không chứa secret; secret do owner quản lý và tự cấu hình công cụ backup tương ứng.

## Không có automation trong scope

Repo này **không** có automation backup: không sops, không wrapper restic, không job backup nào được khai báo trong flake hay CI. Backup dừng ở mức tài liệu — việc chạy backup lớp 2 do owner tự thực hiện bằng công cụ nêu trên.
