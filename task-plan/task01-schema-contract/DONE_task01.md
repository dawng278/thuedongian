# DONE — Task 01: Schema CSDL & API Contract

- **Ngày:** 2 (07/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 01`.

## Tiến độ
> Cập nhật thủ công: ____ / ____ mục đã xong.

## Checklist mục tiêu

- [ ] Chốt ERD: USER, STORE, PRODUCT, INVOICE, INVOICE_ITEM.
- [ ] INVOICE_ITEM lưu **snapshot** `product_name` + `price` (hóa đơn bất biến).
- [ ] PRODUCT có `is_active` (soft delete) + `updated_at` (versioning).
- [ ] INVOICE dùng `id` = UUID sinh ở client (chống trùng khi đồng bộ).
- [ ] Định nghĩa endpoint: `/auth`, `/stores`, `/products`, `/invoices`, `/sync`, `/tax`, `/reports`.
- [ ] Mỗi endpoint: method, path, request body, response, mã lỗi.
- [ ] Định nghĩa DTO dùng chung cho giao dịch/hóa đơn.
- [ ] Viết `schema.prisma` đầy đủ theo ERD.
- [ ] Migration đầu tiên, tạo bảng trong PostgreSQL.
- [ ] Seed data: 1 store mẫu + ~15 món (phở, trà đá...).
- [ ] Tạo model/class Dart khớp DTO trong `shared/`.
- [ ] Dựng api client + lớp mock trả dữ liệu giả khớp contract (để app chạy độc lập backend).
- [ ] `npx prisma studio` thấy đủ 5 bảng đúng cấu trúc.
- [ ] Seed xong có 1 store + danh sách món.
- [ ] `shared/api-contract.md` đủ tất cả endpoint, hai người hiểu giống nhau.
- [ ] Model Dart compile được, mock trả đúng định dạng contract.
- [ ] Đã merge cả hai PR vào `dev`.
- [ ] Cập nhật `DONE_task01.md` và `BUGS_task01.md`.

## Ghi chú khi xong
- Người hoàn thành:
- Ngày hoàn thành thực tế:
- Link PR đã merge:
- Đã merge vào `dev`: [ ]
