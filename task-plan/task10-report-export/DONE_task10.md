# DONE — Task 10: Xuất báo cáo & Lịch sử hóa đơn

- **Ngày:** 11 (16/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 10`.

## Tiến độ
> Cập nhật thủ công: 12 / 14 mục đã xong. (2 mục còn lại là chụp màn hình + báo cáo, dành cho task 13)

## Checklist mục tiêu

- [x] Màn hình **Lịch sử hóa đơn**: danh sách ngược ngày, chạm vào xem chi tiết.
- [x] Chi tiết hóa đơn: các dòng hàng, tổng tiền, nút QR, nút xuất XML (hiển thị endpoint URL).
- [x] Nút **Xuất CSV**: chọn khoảng thời gian → tạo file CSV → chia sẻ từ điện thoại qua `share_plus`.
- [x] Lọc lịch sử theo khoảng thời gian (`showDateRangePicker`).
- [x] API `GET /reports/period?from&to` → tổng doanh thu, số HĐ, danh sách HĐ, top món.
- [x] `GET /invoices` trả đủ dữ liệu (items included) cho màn hình lịch sử.
- [ ] Soạn nháp báo cáo dự thi (dành cho task 13).
- [ ] Chụp màn hình các tính năng app đã xong.
- [x] Mở lịch sử → thấy danh sách hóa đơn đúng.
- [x] Chạm 1 hóa đơn → xem chi tiết + mở QR + endpoint XML.
- [x] Xuất báo cáo CSV → chia sẻ được từ điện thoại.
- [x] Lọc thời gian → danh sách đổi đúng.
- [x] Đã merge vào `main`.
- [x] Cập nhật `DONE_task10.md` và `BUGS_task10.md`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code + Trinh Hai Dang
- Ngày hoàn thành thực tế: 06/06/2026
- Link PR đã merge:
- Đã merge vào `main`: [x]

## Chi tiết triển khai

### Server
- `GET /reports/period?from=YYYY-MM-DD&to=YYYY-MM-DD` — tổng hợp doanh thu kỳ + danh sách HĐ + top 10 món

### App
- `InvoiceHistoryScreen` cập nhật:
  - Filter bar: `OutlinedButton` mở `DateRangePicker` + nút xóa bộ lọc
  - Download button: xuất CSV danh sách HĐ hiện tại → `share_plus` chia sẻ file
  - `_InvoiceDetailSheet`: nút XML (hiển thị endpoint URL), nút QR (mở `InvoiceQrScreen`)
- `pubspec.yaml`: thêm `share_plus: ^10.0.3` và `path_provider: ^2.1.5`
