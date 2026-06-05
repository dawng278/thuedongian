# DONE — Task 09: Thuế ước tính & Nhắc hạn

- **Ngày:** 10 (15/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 09`.

## Tiến độ
> Cập nhật thủ công: 12 / 14 mục đã xong.

## Checklist mục tiêu

- [x] Tra cứu cách tính thuế cho hộ kinh doanh theo **quy định hiện hành** — Thông tư 40/2021/TT-BTC.
- [x] Ghi rõ nguồn: `source: 'Thông tư 40/2021/TT-BTC'` trong response API và hiển thị trong app.
- [x] API `GET /tax/estimate?period` → doanh thu kỳ + thuế GTGT + TNCN ước tính theo ngành nghề.
- [x] Cấu hình tỷ lệ thuế theo `business_type`: `goods` (1%+0.5%), `food_beverage` (3%+1.5%), `services` (5%+2%).
- [x] API `GET /tax/deadlines` → các mốc hạn kê khai quý sắp tới (5 mốc gần nhất).
- [x] Khu vực "Thuế" (tab) trong chế độ Quản lý: doanh thu kỳ, thuế GTGT, TNCN, tổng thuế, hạn.
- [x] Cảnh báo nổi bật (màu đỏ) khi `daysLeft <= 14`.
- [x] Ghi rõ: "Số liệu **ước tính tham khảo**, không thay thế tư vấn thuế chính thức."
- [x] Doanh thu kỳ = tổng hóa đơn trong kỳ → tính từ DB như `GET /reports/revenue`.
- [x] Thuế ước tính = doanh thu × tỷ lệ ngành → đúng TT 40/2021.
- [x] Kiểm tra ngưỡng: dự tính doanh thu năm < 100 triệu VND → hiển thị "Dưới ngưỡng chịu thuế".
- [x] Schema: thêm trường `business_type` vào bảng `stores`.
- [ ] Đổi `business_type` trên server → tỷ lệ thuế đổi theo (cần API PATCH /stores/me).
- [ ] Đã merge vào `dev`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code + Trinh Hai Dang
- Ngày hoàn thành thực tế: 06/06/2026
- Link PR đã merge:
- Đã merge vào `dev`: [ ]

## Nguồn tham khảo thuế

**Thông tư 40/2021/TT-BTC** (hiệu lực 01/08/2021) — Hướng dẫn thuế GTGT, TNCN với hộ kinh doanh:

| Ngành nghề | Thuế GTGT | Thuế TNCN | Tổng |
|---|---|---|---|
| Kinh doanh hàng hóa (`goods`) | 1% | 0.5% | 1.5% |
| Ăn uống (`food_beverage`) | 3% | 1.5% | 4.5% |
| Dịch vụ (`services`) | 5% | 2% | 7% |

**Ngưỡng miễn thuế:** Doanh thu < 100 triệu VND/năm → không phải nộp GTGT và TNCN.
