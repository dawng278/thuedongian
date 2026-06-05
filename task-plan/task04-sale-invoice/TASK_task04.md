# TASK 04 — Bán hàng & Tạo hóa đơn (Chế độ Bán hàng trong App)

- **Ngày:** 5 (10/06/2026)
- **Chủ trì:** A (app) + B (api)
- **Nhánh:** `feat/api-invoice`, `feat/app-sale`
- **Mục tiêu:** Bán hàng dưới 3 giây; tạo hóa đơn với giá snapshot; sinh số hóa đơn tuần tự ở server.

---

## VIỆC CẦN LÀM

### Thành viên A — App (chế độ Bán hàng - cốt lõi sản phẩm)
- [ ] Chạm món trên lưới → cộng dồn vào giỏ hiện tại.
- [ ] Hiển thị tổng tiền realtime.
- [ ] Nút "Hoàn tất" → tạo hóa đơn với:
  - `id` = UUID sinh tại client.
  - **snapshot** `product_name` + `price` + `tax_rate` từng dòng.
  - `issued_at` = thời điểm bán.
- [ ] Đo thời gian thao tác — mục tiêu **< 3 giây** cho đơn điển hình.

### Thành viên B — Backend
- [ ] API `POST /invoices` nhận hóa đơn (kèm UUID client).
- [ ] Logic **sinh số hóa đơn tuần tự** theo store (không trùng, không nhảy cóc).
- [ ] Lưu hóa đơn + dòng item (immutable).
- [ ] API `GET /invoices` (lọc theo ngày).

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
# A
git checkout -b feat/app-sale && cd app && flutter run
# B
git checkout -b feat/api-invoice && cd server && npm run start:dev
```

---

## TEST PLAN

- [ ] Tạo đơn "1 phở + 1 trà đá" → tổng tiền đúng.
- [ ] Hoàn tất → hóa đơn lưu được, có số tuần tự.
- [ ] 2 hóa đơn liên tiếp → số tăng đúng, không trùng.
- [ ] **Sửa giá món sau khi bán** → hóa đơn cũ giữ giá cũ (snapshot OK).
- [ ] Bấm giờ luồng bán đơn điển hình → ghi số giây (mục tiêu < 3s).

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "feat(app): che do ban hang < 3s + snapshot gia"
git add . && git commit -m "feat(api): tao hoa don + sinh so tuan tu"
git pull origin dev --rebase && git push origin feat/<scope>-...
```

- [ ] Đã merge vào `dev`.
- [ ] Ghi số giây đo được vào `DONE_task04.md`.
- [ ] Cập nhật `BUGS_task04.md`.
