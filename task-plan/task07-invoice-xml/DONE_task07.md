# DONE — Task 07: QR & Xuất XML hóa đơn

- **Ngày:** 8 (13/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 07`.

## Tiến độ
> Cập nhật thủ công: ____ / ____ mục đã xong.

## Checklist mục tiêu

- [ ] Tải **quy chuẩn định dạng XML hóa đơn điện tử hiện hành** từ nguồn chính thống (Thông tư + phụ lục cấu trúc của Tổng cục Thuế).
- [ ] Liệt kê trường BẮT BUỘC: ký hiệu mẫu số, ký hiệu hóa đơn, số hóa đơn, MST người bán, thông tin người bán, danh sách hàng hóa/dịch vụ, thuế suất, tiền thuế, tổng tiền, vùng chữ ký số (để trống).
- [ ] Map các trường này vào schema DB hiện có (bổ sung nếu thiếu).
- [ ] Module xuất 1 hóa đơn ra **file XML đúng cấu trúc chuẩn** (đủ trường bắt buộc, để trống ký số).
- [ ] API `GET /invoices/:id/xml` trả file XML.
- [ ] Validate XML đủ trường bắt buộc trước khi xuất.
- [ ] Khách yêu cầu hóa đơn → sinh & hiển thị **QR** (link/mã tra cứu hóa đơn).
- [ ] Mặc định đơn lẻ không cần nhập thông tin khách (chỉ hiện QR khi khách yêu cầu).
- [ ] `GET /invoices/:id/xml` → tải file XML mở được, đúng cấu trúc.
- [ ] XML đủ: mẫu số, ký hiệu, số HĐ, MST, dòng hàng, thuế suất, tổng.
- [ ] Thiếu trường bắt buộc → validate báo lỗi (không xuất XML sai chuẩn).
- [ ] App: khách yêu cầu → hiện QR → quét ra thông tin hóa đơn.
- [ ] Đã merge vào `dev`.
- [ ] Lưu 1 file XML mẫu vào `docs/` làm dẫn chứng phản biện.
- [ ] Cập nhật `DONE_task07.md` và `BUGS_task07.md`.

## Ghi chú khi xong
- Người hoàn thành:
- Ngày hoàn thành thực tế:
- Link PR đã merge:
- Đã merge vào `dev`: [ ]
