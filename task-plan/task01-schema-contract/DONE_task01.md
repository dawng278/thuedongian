# DONE — Task 01: Schema CSDL & API Contract

- **Ngày:** 2 (07/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 01`.

## Tiến độ
> Cập nhật thủ công: 12 / 18 mục đã xong.

## Checklist mục tiêu

- [x] Chốt ERD: USER, STORE, PRODUCT, INVOICE, INVOICE_ITEM.
- [x] INVOICE_ITEM lưu **snapshot** `product_name` + `price` (hóa đơn bất biến).
- [x] PRODUCT có `is_active` (soft delete) + `updated_at` (versioning).
- [x] INVOICE dùng `id` = UUID sinh ở client (chống trùng khi đồng bộ).
- [x] Định nghĩa endpoint: `/auth`, `/stores`, `/products`, `/invoices`, `/sync`, `/tax`, `/reports`.
- [x] Mỗi endpoint: method, path, request body, response, mã lỗi.
- [x] Định nghĩa DTO dùng chung cho giao dịch/hóa đơn.
- [x] Viết `schema.prisma` đầy đủ theo ERD.
- [ ] Migration đầu tiên, tạo bảng trong PostgreSQL. *(Cần PostgreSQL chạy)*
- [x] Seed data: 1 store mẫu + ~15 món — `prisma/seed.ts` đã viết.
- [x] Tạo model/class Dart khớp DTO — `app/lib/models/`.
- [x] Dựng api client + lớp mock — `app/lib/services/mock_api_service.dart`.
- [ ] `npx prisma studio` thấy đủ 5 bảng đúng cấu trúc. *(Cần PostgreSQL)*
- [ ] Seed xong có 1 store + danh sách món. *(Cần PostgreSQL)*
- [x] `shared/api-contract.md` đủ tất cả endpoint.
- [ ] Model Dart compile được, mock trả đúng định dạng contract. *(Cần Flutter SDK)*
- [x] Đã merge vào `dev`.
- [x] Cập nhật `DONE_task01.md` và `BUGS_task01.md`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code
- Ngày hoàn thành thực tế: 06/06/2026
- Link PR đã merge: *(merge trực tiếp vào dev)*
- Đã merge vào `dev`: [x]

## Việc còn lại (cần môi trường local)
1. `cd server && npx prisma migrate dev --name init_schema` — cần PostgreSQL.
2. `npx prisma db seed` — cần PostgreSQL + migration đã chạy.
3. `npx prisma studio` — verify 5 bảng.
4. `flutter build apk` hoặc `flutter analyze` — verify Dart models compile.
