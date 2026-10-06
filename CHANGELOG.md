# Changelog

Trạng thái các phase của plan ổn định 2026-10-06 (`docs/superpowers/plans/2026-10-06-nixos-portable-stabilization.md`). Chỉ ghi **done** khi phase đã implement + verify + commit; chưa verify thì ghi pending.

| Phase | Nội dung | Trạng thái |
| --- | --- | --- |
| P0 | Lock helium pin `0ccdc14` + `nix flake check` | **pending** — cần môi trường có nix/CI |
| P1 | DNS fallback (mặc định tắt) + eval test | **pending** — cần môi trường có nix/CI |
| P2 | Backup doc: declarative vs user-data (`docs/backup.md`, link từ README) | **done** |
| P3 | Đánh dấu host tạm, tách khỏi production/CI matrix | **pending** — cần môi trường có nix/CI |
| P4 | Host thứ 3 permanent, roles subset, không dùng `completed` | **pending** — cần môi trường có nix/CI |
| P5 | README scope + guide thêm host mới + CHANGELOG này | **partial** — README scope/guide và CHANGELOG đã làm; phần cập nhật README DNS phụ thuộc P1 (chưa implement) nên để nguyên |
| P6 | CI: thêm `nix flake check` + 1 nixosTest boot minimal | **pending** — cần môi trường có nix/CI |

Ghi chú:

- P0/P1/P3/P4/P6 chưa được thực hiện trong môi trường này (không có nix, chưa chạy CI) — không phase nào ngoài P2 được ghi done.
- P5 (DNS) bị split theo ruling: phần DNS trong README (snippet fallback thủ công hiện tại) giữ nguyên cho tới khi P1 có cơ chế opt-in.
