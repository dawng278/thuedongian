# DONE — Task 09: Thuế ước tính & Nhắc hạn

- **Ngày:** 10 (15/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 09`.

## Tiến độ
> Cập nhật thủ công: ____ / ____ mục đã xong.

## Checklist mục tiêu

- [ ] Tra cứu cách tính thuế cho hộ kinh doanh theo **quy định hiện hành** (tỷ lệ % trên doanh thu theo ngành nghề, ngưỡng doanh thu chịu thuế).
- [ ] Ghi rõ nguồn vào báo cáo. KHÔNG dùng số tự nghĩ.
- [ ] API `GET /tax/estimate?period` → tổng doanh thu kỳ + thuế ước tính theo tỷ lệ ngành nghề.
- [ ] Cấu hình tỷ lệ thuế theo `business_type` (lấy từ quy định).
- [ ] API `GET /tax/deadlines` → các mốc hạn kê khai/nộp sắp tới.
- [ ] Khu vực "Thuế" trong chế độ Quản lý: doanh thu kỳ, thuế ước tính, ngày đến hạn.
- [ ] Cảnh báo nổi bật khi gần đến hạn.
- [ ] Ghi rõ trên màn hình: "Số liệu **ước tính tham khảo**, không thay thế tư vấn thuế chính thức."
- [ ] Doanh thu kỳ = tổng hóa đơn trong kỳ → khớp màn hình Quản lý.
- [ ] Thuế ước tính = doanh thu × tỷ lệ ngành → đúng công thức đã tra cứu.
- [ ] Đổi `business_type` → tỷ lệ thuế đổi theo.
- [ ] Sắp đến hạn → hiện cảnh báo trong app.
- [ ] Đã merge vào `dev`.
- [ ] Cập nhật `DONE_task09.md` và `BUGS_task09.md`.

## Ghi chú khi xong
- Người hoàn thành:
- Ngày hoàn thành thực tế:
- Link PR đã merge:
- Đã merge vào `dev`: [ ]
