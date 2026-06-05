# DONE — Task 06: Đồng bộ & Xử lý xung đột

- **Ngày:** 7 (12/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 06`.

## Tiến độ
> Cập nhật thủ công: ____ / ____ mục đã xong.

## Checklist mục tiêu

- [ ] Xác nhận hóa đơn **immutable**: không endpoint nào cho sửa/xóa hóa đơn đã phát sinh.
- [ ] Xung đột danh mục — sửa giá: dùng `updated_at`, **last-write-wins** theo thời điểm sửa thực tế.
- [ ] Xóa món đang dùng → giữ **soft delete**, hóa đơn offline tham chiếu vẫn lưu hợp lệ.
- [ ] Doanh thu/thuế luôn tính từ **giá snapshot trong hóa đơn**, không từ bảng giá hiện hành.
- [ ] Đồng bộ khi món đã bị xóa trên server (soft delete) → hóa đơn vẫn đẩy thành công nhờ snapshot.
- [ ] Hiển thị trạng thái đồng bộ rõ ràng.
- [ ] **KB1:** App offline bán "Phở 50k" → sửa giá thành 55k ở chế độ Quản lý → app đồng bộ → hóa đơn vẫn 50k. ✅
- [ ] **KB2:** App offline bán "Phở" → xóa "Phở" ở chế độ Quản lý → app đồng bộ → hóa đơn vẫn hợp lệ, "Phở" chỉ ẩn ở đơn tương lai. ✅
- [ ] **KB3:** Tổng doanh thu = tổng hóa đơn theo giá snapshot (không lệch khi đổi giá). ✅
- [ ] Thử sửa/xóa hóa đơn đã phát sinh qua API → bị từ chối. ✅
- [ ] Đã merge vào `dev`.
- [ ] Chụp màn hình 3 kịch bản làm dẫn chứng phản biện.
- [ ] Cập nhật `DONE_task06.md` và `BUGS_task06.md`.

## Ghi chú khi xong
- Người hoàn thành:
- Ngày hoàn thành thực tế:
- Link PR đã merge:
- Đã merge vào `dev`: [ ]
