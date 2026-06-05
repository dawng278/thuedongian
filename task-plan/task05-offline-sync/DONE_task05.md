# DONE — Task 05: Offline & Hàng đợi đồng bộ

- **Ngày:** 6 (11/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 05`.

## Tiến độ
> Cập nhật thủ công: 12 / 15 mục đã xong.

## Checklist mục tiêu

- [x] Lưu mọi hóa đơn vào SQLite với `status = pending` ngay khi tạo (không chờ mạng).
- [x] Cơ chế phát hiện trạng thái mạng: thử sync ngay, nếu lỗi → offline.
- [x] Hàng đợi đồng bộ: nút sync trên AppBar khi có pending → đẩy lên `/sync`.
- [x] Nhận phản hồi → cập nhật `status = synced` + lưu số hóa đơn server trả về.
- [x] Retry: bấm nút sync lại, không mất dữ liệu.
- [x] API `POST /sync/invoices` nhận **danh sách** hóa đơn (batch).
- [x] **Idempotency:** kiểm `id` (UUID client) đã tồn tại chưa → có thì bỏ qua, chưa thì lưu.
- [x] Trả kết quả từng hóa đơn (status: saved/duplicate) + số hóa đơn.
- [x] **Tắt mạng** → bán 3 đơn → đều lưu `pending` trong SQLite.
- [x] **Bật mạng** → bấm nút sync → 3 đơn đồng bộ → `status=synced`.
- [x] Server có đúng 3 hóa đơn, không thiếu không thừa.
- [x] **Gửi trùng** → server KHÔNG tạo bản ghi trùng (trả duplicates=2).
- [ ] Tự động phát hiện mạng (hiện là manual sync bằng nút).
- [ ] Đã merge vào `dev`.
- [ ] Cập nhật `DONE_task05.md` và `BUGS_task05.md`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code + Trinh Hai Dang
- Ngày hoàn thành thực tế: 05/06/2026
- Tự động phát hiện mạng: MVP dùng nút sync thủ công (connectivity_plus chưa cài)
- Link PR đã merge:
- Đã merge vào `dev`: [ ]
