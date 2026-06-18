# Kịch bản Video Demo — TaxEasy

> Mục tiêu: video 3–5 phút (mục 6.3 thể lệ). Chứng minh "definition of done" chạy trọn chuỗi
> không vấp, làm bật 3 USP: **offline thật / thuế đúng luật / XML chuẩn nhà nước**.
> Tổng thời lượng mục tiêu: **~4 phút 20 giây** (an toàn trong 3–5 phút).

---

## 0. Chuẩn bị TRƯỚC khi quay (bắt buộc làm xong hết)

### Server & dữ liệu
- [ ] Server chạy: `cd server && npm run start:dev` — thấy log "đang chạy tại http://localhost:3000"
- [ ] Đã `npm run seed` — có quán **Mì Cay Seoul**, ≥6 sản phẩm có giá, ≥1 sản phẩm có **giá vốn** (để khoe lợi nhuận), 12k+ hóa đơn lịch sử (để biểu đồ + thuế đẹp)
- [ ] Cửa hàng đã nhập **MST hợp lệ 10 số** (nếu thiếu sẽ không xuất được XML — điểm nhấn #7 hỏng)
- [ ] Có sẵn ≥1 sản phẩm **sắp hết kho** để trợ lý AI bật cảnh báo (điểm nhấn AI)

### Thiết bị quay
- [ ] App đã đăng nhập sẵn 1 lần (token còn hạn) — tránh gõ mật khẩu trên video
- [ ] Bật **quay màn hình điện thoại** (screen record) + mic rõ, hoặc quay ngoài bằng chân máy
- [ ] Wifi/4G bật, biết cách gạt **chế độ máy bay** nhanh
- [ ] Tắt thông báo (Do Not Disturb) để không có popup chen ngang khi quay
- [ ] Pin >50%, độ sáng màn hình cao

### Cách quay (khuyến nghị)
- Quay **screen recording** của điện thoại cho rõ nét → lồng tiếng (voice-over) sau theo lời thoại bên dưới.
- Hoặc quay 1 lần liền mạch nếu tự tin. Cắt ghép tối thiểu để giữ tính "thật".
- Thêm **phụ đề** (caption) các câu chốt — giám khảo xem không tiếng vẫn hiểu.

---

## 1. Mở màn — nêu vấn đề (0:00 – 0:25)

**Hình:** Logo TaxEasy / slide bìa, rồi cắt sang màn hình điện thoại đang ở chế độ Bán hàng.

**Lời thoại:**
> "Từ 2026, hàng triệu hộ kinh doanh ở Việt Nam phải tự kê khai thuế khi bỏ thuế khoán —
> nhưng họ không có công cụ phù hợp, và thường bán hàng ở nơi sóng yếu.
> **TaxEasy** giải quyết cả ba việc trong một app: bán hàng — quản lý — thuế, **chạy được cả khi mất mạng**."

---

## 2. Bán hàng nhanh (0:25 – 1:00)

**Hình:** Lưới món ở chế độ Bán hàng.

**Thao tác + lời thoại:**
- Chạm 3–4 món → giỏ hàng cộng dồn tức thì.
  > "Chạm là bán. Mỗi đơn dưới 3 giây."
- Chọn **Tiền mặt** → nhập tiền khách đưa → app tính **tiền thối**.
- Bấm Thanh toán → **hiện QR ngay**.
  > "Khách quét QR là thấy thông tin hóa đơn. Hóa đơn đã lưu, bất biến."

---

## 3. Offline — điểm nhấn kỹ thuật (1:00 – 1:50)  ⭐ ĐINH

**Hình:** Gạt chế độ máy bay (cho thấy icon máy bay sáng lên — bằng chứng mất mạng thật).

**Lời thoại:**
> "Giờ tôi **tắt mạng hoàn toàn** — mô phỏng quán ở chỗ sóng yếu."
- Bán thêm 2–3 đơn → **vẫn mượt, vẫn ra hóa đơn, vẫn có số**.
  > "Không hề khựng. Dữ liệu lưu an toàn ngay trong máy."
- Mở màn **"Chờ đồng bộ"** → chỉ vào số đơn đang chờ.
  > "Mỗi đơn có một mã định danh sinh ngay trên máy — đây là chìa khóa chống trùng khi đồng bộ."

---

## 4. Bật mạng — tự đồng bộ không trùng (1:50 – 2:20)  ⭐ ĐINH

**Hình:** Tắt chế độ máy bay → đợi vài giây.

**Lời thoại:**
- Số "chờ đồng bộ" **tự về 0**.
  > "Mạng về là tự đẩy lên server. Nhờ mã định danh sinh ở máy cộng với giao dịch khóa chặt phía server,
  > **không bao giờ trùng số hóa đơn** — kể cả khi hai máy cùng bán một lúc.
  > Đây là điểm nhiều giải pháp 'hô offline' nhưng không làm được."

---

## 5. Trợ lý thông minh + Chế độ Quản lý (2:20 – 3:20)

**Hình:** Bấm nút chuyển sang chế độ **Quản lý** → màn Doanh thu.

**Thao tác + lời thoại:**
- Chỉ **bong bóng trợ lý AI** đang cảnh báo (vd "X món sắp hết kho" / "gần ngưỡng thuế").
  > "Trợ lý phân tích ngay trên máy, dưới một mili-giây, không cần internet —
  > nhắc đúng việc cần làm: sắp hết hàng, doanh thu giảm, hay sắp chạm ngưỡng chịu thuế."
- Màn Doanh thu: tách **tiền mặt / chuyển khoản**, **biểu đồ** tuần/tháng/năm, **top món bán chạy**, **lợi nhuận**.
  > "Toàn cảnh kinh doanh trong một màn."
- Mở màn **Thuế**:
  > "Hệ thống tự ước tính thuế GTGT và TNCN **đúng luật 2026** — ngưỡng miễn 200 triệu một năm,
  > tỷ lệ theo từng loại hình kinh doanh — và **nhắc hạn nộp tờ khai theo quý**."

---

## 6. Hóa đơn điện tử — xuất XML chuẩn (3:20 – 4:00)  ⭐ ĐINH

**Hình:** Vào **Lịch sử hóa đơn** → chọn 1 hóa đơn → **Xuất XML**.

**Lời thoại:**
> "Mỗi hóa đơn xuất được ra file XML **đúng chuẩn Thông tư 78/2021 của Tổng cục Thuế** —
> nộp thẳng lên hệ thống hóa đơn điện tử quốc gia."
- *(Nếu quay được)* mở file XML cho thấy cấu trúc HDon / DLHDon / NDHDon / TToan.

---

## 7. Chốt (4:00 – 4:20)

**Hình:** Quay lại slide tagline hoặc màn hình tổng.

**Lời thoại:**
> "Một app, một luồng liền mạch: **bán — quản lý — thuế**.
> Offline-first chạy thật, đúng luật, xuất hóa đơn chuẩn nhà nước.
> Được kiểm chứng bằng **111 bài test tự động**. Đó là **TaxEasy** — đơn giản hóa thuế cho hộ kinh doanh Việt."

---

## Bảng phân bổ thời lượng (kiểm soát ≤5 phút)

| Phân đoạn | Thời lượng | Cộng dồn |
|---|---|---|
| 1. Mở màn (vấn đề) | 0:25 | 0:25 |
| 2. Bán hàng nhanh | 0:35 | 1:00 |
| 3. Offline ⭐ | 0:50 | 1:50 |
| 4. Tự đồng bộ ⭐ | 0:30 | 2:20 |
| 5. AI + Quản lý + Thuế | 1:00 | 3:20 |
| 6. Xuất XML ⭐ | 0:40 | 4:00 |
| 7. Chốt | 0:20 | 4:20 |

> Nếu bị quá giờ: cắt bớt phần 5 (nói nhanh hơn), giữ nguyên 3 đoạn ⭐ đinh.

---

## Mẹo ăn điểm khi quay

- **Đoạn offline (3+4) phải thật rõ ràng** — cho thấy icon máy bay bật/tắt. Đây là thứ phân biệt bạn với 90% đội thi.
- Nói **con số cụ thể** (dưới 3 giây / dưới 1 mili-giây / 111 test / ngưỡng 200 triệu) — tạo cảm giác chắc chắn, chuyên nghiệp.
- Giữ nhịp **đau → giải pháp → bằng chứng**: đừng chỉ "đi tour tính năng", hãy kể chuyện một chủ quán.
- Lồng tiếng rõ, chậm vừa phải. Thêm phụ đề cho câu chốt mỗi đoạn.

## Phương án dự phòng (nếu quay gặp sự cố — ghi để khỏi loay hoay)

| Sự cố | Xử lý |
|---|---|
| Mạng chập chờn khi quay | Server chạy LAN, app trỏ IP nội bộ (`API_BASE_URL`) |
| Xuất XML báo thiếu MST | Đã kiểm ở checklist; nếu lỗi, mở `docs/sample-invoice.xml` minh họa |
| Sync không về 0 | Bấm nút đồng bộ thủ công ở màn "Chờ đồng bộ" |
| Biểu đồ trống | Kiểm tra seed đã chạy (12k+ hóa đơn) trước khi quay |
