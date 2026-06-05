# TASK 03 — Danh mục hàng hóa & Lưới món

- **Ngày:** 4 (09/06/2026)
- **Chủ trì:** A (app) + B (api)
- **Nhánh:** `feat/api-product`, `feat/app-product`
- **Mục tiêu:** CRUD hàng hóa; dựng lưới món một chạm trong app; chuẩn bị nền cho xử lý xung đột.

---

## VIỆC CẦN LÀM

### Thành viên B — Backend
- [ ] API `GET /products` (theo store).
- [ ] API `POST /products`, `PUT /products/:id`.
- [ ] API `DELETE /products/:id` → **soft delete** (`is_active=false`), KHÔNG xóa cứng.
- [ ] Mỗi lần sửa cập nhật `updated_at`.

### Thành viên A — App
- [ ] Màn hình **lưới món một chạm** (grid nút món lớn) — màn hình bán hàng chính.
- [ ] Tải danh mục từ API + lưu cache local (SQLite) để dùng offline.
- [ ] Màn hình quản lý món trong app (thêm/sửa/ẩn nhanh) — sẽ gom vào chế độ Quản lý ở Task 08.

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
# B
git checkout -b feat/api-product && cd server && npm run start:dev
# A
git checkout -b feat/app-product && cd app && flutter run
```

---

## TEST PLAN

- [ ] Thêm món mới → hiện trên lưới món của app.
- [ ] Sửa giá món → `updated_at` thay đổi.
- [ ] Xóa món → `is_active=false`, không hiện ở giao dịch mới nhưng vẫn trong DB.
- [ ] App: tải danh mục → tắt mạng → vẫn thấy lưới món (đọc cache).
- [ ] Lưới món hiển thị đúng, chạm phản hồi nhanh.

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "feat(<scope>): CRUD product + soft delete + luoi mon"
git pull origin dev --rebase && git push origin feat/<scope>-product
```

- [ ] Đã merge vào `dev`.
- [ ] Cập nhật `DONE_task03.md` và `BUGS_task03.md`.
