# DONE — Task 04: Bán hàng & Tạo hóa đơn (App)

- **Ngày:** 5 (10/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 04`.

## Tiến độ
> Cập nhật thủ công: 13 / 16 mục đã xong.

## Checklist mục tiêu

- [x] Chạm món trên lưới → cộng dồn vào giỏ hiện tại.
- [x] Hiển thị tổng tiền realtime.
- [x] Nút "Hoàn tất" → tạo hóa đơn với UUID client + snapshot name/price.
- [x] Đo thời gian thao tác — mục tiêu **< 3 giây** cho đơn điển hình. (~1-2s khi có mạng LAN)
- [x] API `POST /invoices` nhận hóa đơn (kèm UUID client).
- [x] Logic **sinh số hóa đơn tuần tự** theo store (không trùng, không nhảy cóc).
- [x] Lưu hóa đơn + dòng item (immutable).
- [x] API `GET /invoices` (lọc theo ngày).
- [x] Tạo đơn "1 phở + 1 trà đá" → tổng tiền đúng.
- [x] Hoàn tất → hóa đơn lưu được, có số tuần tự.
- [x] 2 hóa đơn liên tiếp → số tăng đúng, không trùng.
- [x] **Sửa giá món sau khi bán** → hóa đơn cũ giữ giá cũ (snapshot OK).
- [x] App hiển thị snackbar "Hóa đơn #N — Xđ" sau khi tạo thành công.
- [ ] Đã merge vào `dev`.
- [ ] Ghi số giây đo được vào `DONE_task04.md`. (~1.5s đo thực tế)
- [ ] Cập nhật `BUGS_task04.md`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code + Trinh Hai Dang
- Ngày hoàn thành thực tế: 05/06/2026
- Thời gian tạo đơn: ~1–2 giây (dưới mục tiêu 3 giây)
- Link PR đã merge:
- Đã merge vào `dev`: [ ]
