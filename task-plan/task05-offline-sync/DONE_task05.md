# DONE — Task 05: Offline & Hàng đợi đồng bộ

- **Ngày:** 6 (11/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 05`.

## Tiến độ
> Cập nhật thủ công: ____ / ____ mục đã xong.

## Checklist mục tiêu

- [ ] Lưu mọi hóa đơn vào SQLite với `status = pending` ngay khi tạo (không chờ mạng).
- [ ] Cơ chế phát hiện trạng thái mạng (online/offline).
- [ ] Hàng đợi đồng bộ: có mạng → lần lượt đẩy hóa đơn `pending` lên `/sync`.
- [ ] Nhận phản hồi → cập nhật `status = synced` + lưu số hóa đơn server trả về.
- [ ] Retry khi mạng chập chờn.
- [ ] API `POST /sync` nhận **danh sách** hóa đơn (batch).
- [ ] **Idempotency:** kiểm `id` (UUID client) đã tồn tại chưa → có thì bỏ qua, chưa thì lưu.
- [ ] Trả kết quả từng hóa đơn (đã lưu / đã tồn tại) + số hóa đơn.
- [ ] **Tắt mạng** (máy bay) → bán 3 đơn → đều lưu `pending`.
- [ ] **Bật mạng** → 3 đơn tự đồng bộ → `status=synced`.
- [ ] Server có đúng 3 hóa đơn, không thiếu không thừa.
- [ ] **Gửi trùng** (đẩy lại cùng UUID) → server KHÔNG tạo bản ghi trùng.
- [ ] Mạng chập chờn giữa chừng → retry thành công, không mất đơn.
- [ ] Đã merge vào `dev`.
- [ ] Cập nhật `DONE_task05.md` và `BUGS_task05.md`.

## Ghi chú khi xong
- Người hoàn thành:
- Ngày hoàn thành thực tế:
- Link PR đã merge:
- Đã merge vào `dev`: [ ]
