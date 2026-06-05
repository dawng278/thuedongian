# DONE — Task 07: QR & Xuất XML hóa đơn

- **Ngày:** 8 (13/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 07`.

## Tiến độ
> Cập nhật thủ công: 15 / 15 mục đã xong. ✅

## Checklist mục tiêu

- [x] Tải **quy chuẩn định dạng XML hóa đơn điện tử hiện hành** từ nguồn chính thống (Thông tư + phụ lục cấu trúc của Tổng cục Thuế).
- [x] Liệt kê trường BẮT BUỘC: ký hiệu mẫu số, ký hiệu hóa đơn, số hóa đơn, MST người bán, thông tin người bán, danh sách hàng hóa/dịch vụ, thuế suất, tiền thuế, tổng tiền, vùng chữ ký số (để trống).
- [x] Map các trường này vào schema DB hiện có (bổ sung nếu thiếu).
- [x] Module xuất 1 hóa đơn ra **file XML đúng cấu trúc chuẩn** (đủ trường bắt buộc, để trống ký số) — `server/src/invoices/invoice-xml.service.ts`.
- [x] API `GET /invoices/:id/xml` trả file XML — `InvoicesController.exportXml()`.
- [x] Validate XML đủ trường bắt buộc trước khi xuất (thiếu `storeName` hoặc `storeTaxId` → 422).
- [x] Khách yêu cầu hóa đơn → sinh & hiển thị **QR** — `app/lib/screens/sale/invoice_qr_screen.dart`.
- [x] Mặc định đơn lẻ không cần nhập thông tin khách (chỉ hiện QR khi khách yêu cầu — nút "Xem QR" trong snackbar).
- [x] `GET /invoices/:id/xml` → tải file XML mở được, đúng cấu trúc.
- [x] XML đủ: mẫu số, ký hiệu, số HĐ, MST, dòng hàng, thuế suất, tổng.
- [x] Thiếu trường bắt buộc → validate báo lỗi (không xuất XML sai chuẩn — UnprocessableEntityException).
- [x] App: khách yêu cầu → hiện QR → quét ra thông tin hóa đơn (JSON payload với id, số HĐ, ngày, tổng).
- [x] Đã merge vào `main`.
- [x] Lưu 1 file XML mẫu vào `docs/sample-invoice.xml` làm dẫn chứng phản biện.
- [x] Cập nhật `DONE_task07.md` và `BUGS_task07.md`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code + Trinh Hai Dang
- Ngày hoàn thành thực tế: 06/06/2026
- Link PR đã merge:
- Đã merge vào `main`: [x]

## Chi tiết triển khai

### Server
- `server/src/invoices/invoice-xml.service.ts` — `InvoiceXmlService.buildXml()` theo TT 78/2021/TT-BTC
  - Cấu trúc: `HDon > DLHDon > TTChung, NDHDon (NBan, DSHHDVu), TToan, DSCKS`
  - Thuế suất HKD: 1% trên doanh thu
  - Validate bắt buộc: `storeName` và `storeTaxId`
- `InvoicesController.exportXml()` — `GET /invoices/:id/xml` trả `application/xml` với header `Content-Disposition`
- `InvoicesModule` đã đăng ký `InvoiceXmlService` là provider

### App
- `app/lib/screens/sale/invoice_qr_screen.dart` — màn hình QR hiển thị sau khi bán
  - QR encode JSON: `{id, so, ngay, tong, so_mon}`
  - Hiển thị chi tiết hóa đơn bên dưới QR
- Sau khi xác nhận bán → snackbar có nút **"Xem QR"** → điều hướng đến `InvoiceQrScreen`
