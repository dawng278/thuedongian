# DONE — Task 03: Danh mục hàng hóa & Lưới món

- **Ngày:** 4 (09/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 03`.

## Tiến độ
> Cập nhật thủ công: ____ / ____ mục đã xong.

## Checklist mục tiêu

- [ ] API `GET /products` (theo store).
- [ ] API `POST /products`, `PUT /products/:id`.
- [ ] API `DELETE /products/:id` → **soft delete** (`is_active=false`), KHÔNG xóa cứng.
- [ ] Mỗi lần sửa cập nhật `updated_at`.
- [ ] Màn hình **lưới món một chạm** (grid nút món lớn) — màn hình bán hàng chính.
- [ ] Tải danh mục từ API + lưu cache local (SQLite) để dùng offline.
- [ ] Màn hình quản lý món trong app (thêm/sửa/ẩn nhanh) — sẽ gom vào chế độ Quản lý ở Task 08.
- [ ] Thêm món mới → hiện trên lưới món của app.
- [ ] Sửa giá món → `updated_at` thay đổi.
- [ ] Xóa món → `is_active=false`, không hiện ở giao dịch mới nhưng vẫn trong DB.
- [ ] App: tải danh mục → tắt mạng → vẫn thấy lưới món (đọc cache).
- [ ] Lưới món hiển thị đúng, chạm phản hồi nhanh.
- [ ] Đã merge vào `dev`.
- [ ] Cập nhật `DONE_task03.md` và `BUGS_task03.md`.

## Ghi chú khi xong
- Người hoàn thành:
- Ngày hoàn thành thực tế:
- Link PR đã merge:
- Đã merge vào `dev`: [ ]
