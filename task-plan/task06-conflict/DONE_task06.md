# DONE — Task 06: Đồng bộ & Xử lý xung đột

- **Ngày:** 7 (12/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 06`.

## Tiến độ
> Cập nhật thủ công: 11 / 13 mục đã xong.

## Checklist mục tiêu

- [x] Xác nhận hóa đơn **immutable**: PATCH/DELETE /invoices/:id trả 405 MethodNotAllowed.
- [x] Xung đột danh mục — sửa giá: dùng `updated_at`, **last-write-wins** (Prisma updatedAt tự cập nhật).
- [x] Xóa món đang dùng → giữ **soft delete** (`is_active=false`), hóa đơn offline vẫn lưu hợp lệ.
- [x] Doanh thu/thuế luôn tính từ **giá snapshot trong hóa đơn** (InvoiceItem.price immutable).
- [x] Đồng bộ khi món đã bị xóa trên server → hóa đơn vẫn đẩy thành công nhờ snapshot.
- [x] Hiển thị trạng thái đồng bộ rõ ràng (cloud badge + snackbar).
- [x] **KB1:** bán snapshot 50k → đổi giá 60k → hóa đơn cũ vẫn 50k ✅
- [x] **KB2:** bán offline → xóa sản phẩm → hóa đơn vẫn đẩy OK (status=saved) ✅
- [x] **KB3:** PATCH invoice → 405, DELETE invoice → 405 ✅
- [x] Thử sửa/xóa hóa đơn đã phát sinh qua API → bị từ chối 405. ✅
- [ ] Đã merge vào `dev`.
- [ ] Chụp màn hình 3 kịch bản làm dẫn chứng phản biện.
- [ ] Cập nhật `DONE_task06.md` và `BUGS_task06.md`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code + Trinh Hai Dang
- Ngày hoàn thành thực tế: 06/06/2026
- Link PR đã merge:
- Đã merge vào `dev`: [ ]
