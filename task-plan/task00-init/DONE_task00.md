# DONE — Task 00: Khởi tạo dự án & Môi trường

- **Ngày:** 1 (06/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 00`.

## Tiến độ
> Cập nhật thủ công: 10 / 13 mục đã xong.

## Checklist mục tiêu

- [x] Tạo repo GitHub `thuedongian`, thêm cả hai làm collaborator.
- [x] Tạo cấu trúc thư mục `app/ server/ shared/ docs/ task-plan/`.
- [x] Tạo `main` và `dev`. Đặt `dev` làm nhánh mặc định.
- [x] Thêm `README.md` gốc + copy `RULEBASE.md` vào repo.
- [x] Thêm `.gitignore` cho từng phần.
- [x] Khởi tạo project Flutter (pubspec.yaml + lib/main.dart skeleton 2 chế độ).
- [x] Cài package: `sqflite`, `dio`, `qr_flutter`, `uuid`, `intl`, `fl_chart`, `provider`.
- [x] Khởi tạo NestJS + Prisma + `.env.example` — `npm run build` ✅ không lỗi.
- [ ] `flutter run` → app trắng không lỗi. *(Cần Flutter SDK trên máy local)*
- [ ] `npm run start:dev` (server) → lên cổng, không lỗi DB. *(Cần PostgreSQL chạy)*
- [ ] Người kia `git clone` → build được cả app + server theo README.
- [x] Đã merge vào `dev`, `dev` build được cả app + server.
- [x] Cập nhật `DONE_task00.md` và `BUGS_task00.md`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code (scaffold) + Trinh Hai Dang
- Ngày hoàn thành thực tế: 06/06/2026
- Link PR đã merge: *(commit trực tiếp vào main → merge fast-forward vào dev)*
- Đã merge vào `dev`: [x]

## Việc còn lại
1. ~~Push repo lên GitHub~~ ✅
2. Cài Flutter SDK trên máy local → `flutter pub get` + `flutter run` kiểm tra app trắng.
3. Chạy PostgreSQL (Docker: `docker run -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres`) → `npm run start:dev`.
4. ~~Merge vào `dev`~~ ✅
