# TASK 01 — Schema CSDL & API Contract

- **Ngày:** 2 (07/06/2026)
- **Chủ trì:** Cả hai (BẮT BUỘC pair — nền móng chống lệch nhau)
- **Nhánh:** `docs/api-contract` + `feat/api-schema`
- **Mục tiêu:** Chốt schema PostgreSQL và hợp đồng API. Sau task này, hai người làm song song không chặn nhau.

---

## VIỆC CẦN LÀM

### Chung — Thiết kế dữ liệu (cùng nhau)
- [ ] Chốt ERD: USER, STORE, PRODUCT, INVOICE, INVOICE_ITEM.
- [ ] INVOICE_ITEM lưu **snapshot** `product_name` + `price` (hóa đơn bất biến).
- [ ] PRODUCT có `is_active` (soft delete) + `updated_at` (versioning).
- [ ] INVOICE dùng `id` = UUID sinh ở client (chống trùng khi đồng bộ).

### Chung — API Contract (ghi vào `shared/api-contract.md`)
- [ ] Định nghĩa endpoint: `/auth`, `/stores`, `/products`, `/invoices`, `/sync`, `/tax`, `/reports`.
- [ ] Mỗi endpoint: method, path, request body, response, mã lỗi.
- [ ] Định nghĩa DTO dùng chung cho giao dịch/hóa đơn.

### Thành viên B
- [ ] Viết `schema.prisma` đầy đủ theo ERD.
- [ ] Migration đầu tiên, tạo bảng trong PostgreSQL.
- [ ] Seed data: 1 store mẫu + ~15 món (phở, trà đá...).

### Thành viên A
- [ ] Tạo model/class Dart khớp DTO trong `shared/`.
- [ ] Dựng api client + lớp mock trả dữ liệu giả khớp contract (để app chạy độc lập backend).

---

## LỆNH BASH

```bash
# B
git checkout dev && git pull origin dev
git checkout -b feat/api-schema
cd server
npx prisma migrate dev --name init_schema
npx prisma studio
npx prisma db seed

# A
git checkout dev && git pull origin dev
git checkout -b docs/api-contract
```

---

## TEST PLAN

- [ ] `npx prisma studio` thấy đủ 5 bảng đúng cấu trúc.
- [ ] Seed xong có 1 store + danh sách món.
- [ ] `shared/api-contract.md` đủ tất cả endpoint, hai người hiểu giống nhau.
- [ ] Model Dart compile được, mock trả đúng định dạng contract.

---

## KẾT THÚC TASK (Git)

```bash
# B
git add . && git commit -m "feat(api): schema prisma + migration + seed"
git pull origin dev --rebase && git push origin feat/api-schema
# A
git add . && git commit -m "docs(api): chot api contract + models dart"
git pull origin dev --rebase && git push origin docs/api-contract
# Cả hai mở PR vào dev → review chéo → merge
```

> ⚠️ Sau merge, `shared/api-contract.md` là vùng nhạy cảm. Đổi gì phải báo nhau (RULEBASE mục 4).

- [ ] Đã merge cả hai PR vào `dev`.
- [ ] Cập nhật `DONE_task01.md` và `BUGS_task01.md`.
