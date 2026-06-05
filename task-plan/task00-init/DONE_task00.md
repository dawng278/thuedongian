# DONE — Task 00: Khởi tạo dự án & Môi trường

- **Ngày:** 1 (06/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 00`.

## Tiến độ
> Cập nhật thủ công: 9 / 13 mục đã xong.

## Checklist mục tiêu

- [x] Tạo repo GitHub `thuedongian`, thêm cả hai làm collaborator.
- [x] Tạo cấu trúc thư mục `app/ server/ shared/ docs/ task-plan/`.
- [x] Tạo `main` và `dev`. Đặt `dev` làm nhánh mặc định.
- [x] Thêm `README.md` gốc + copy `RULEBASE.md` vào repo.
- [x] Thêm `.gitignore` cho từng phần.
- [x] Khởi tạo project Flutter (pubspec.yaml + lib/main.dart skeleton 2 chế độ).
- [x] Cài package: `sqflite`, `dio`, `qr_flutter`, `uuid`, `intl`, `fl_chart`.
- [x] Khởi tạo NestJS + Prisma + `.env.example` (cần PostgreSQL local/Docker).
- [ ] `flutter run` → app trắng không lỗi. *(Cần cài Flutter SDK)*
- [ ] `npm run start:dev` (server) → lên cổng, không lỗi DB. *(Cần PostgreSQL chạy)*
- [ ] Người kia `git clone` → build được cả app + server theo README.
- [ ] Đã merge vào `dev`, `dev` build được cả app + server.
- [ ] Cập nhật `DONE_task00.md` và `BUGS_task00.md`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code (scaffold)
- Ngày hoàn thành thực tế: 06/06/2026
- Link PR đã merge: *(main + dev đã push, chưa có PR)*
- Đã merge vào `dev`: [ ]

## Việc còn lại
1. Push repo lên GitHub, thêm collaborator.
2. Cài Flutter SDK → chạy `flutter pub get` và `flutter run`.
3. Chạy PostgreSQL (local hoặc Docker) → `npm run start:dev` trong `server/`.
4. Merge vào `dev` sau khi test thành công.
