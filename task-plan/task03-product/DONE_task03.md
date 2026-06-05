# DONE — Task 03: Danh mục hàng hóa & Lưới món

- **Ngày:** 4 (09/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 03`.

## Tiến độ
> Cập nhật thủ công: 14 / 14 mục đã xong. ✅

## Checklist mục tiêu

- [x] API `GET /products` (theo store).
- [x] API `POST /products`, `PUT /products/:id`.
- [x] API `DELETE /products/:id` → **soft delete** (`is_active=false`), KHÔNG xóa cứng.
- [x] Mỗi lần sửa cập nhật `updated_at`.
- [x] Màn hình **lưới món một chạm** (grid nút món lớn) — màn hình bán hàng chính.
- [x] Tải danh mục từ API + lưu cache local (SQLite) để dùng offline.
- [x] Màn hình quản lý món trong app (thêm/sửa/ẩn nhanh) — sẽ gom vào chế độ Quản lý ở Task 08.
- [x] Thêm món mới → hiện trên lưới món của app.
- [x] Sửa giá món → `updated_at` thay đổi.
- [x] Xóa món → `is_active=false`, không hiện ở giao dịch mới nhưng vẫn trong DB.
- [x] App: tải danh mục → tắt mạng → vẫn thấy lưới món (đọc cache).
- [x] Lưới món hiển thị đúng, chạm phản hồi nhanh.
- [x] Đã merge vào `main`.
- [x] Cập nhật `DONE_task03.md` và `BUGS_task03.md`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code + Trinh Hai Dang
- Ngày hoàn thành thực tế: 05/06/2026
- Link PR đã merge:
- Đã merge vào `main`: [x]
