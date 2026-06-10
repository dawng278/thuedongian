# TaxEasy — Đánh giá cạnh tranh & Kịch bản Demo

> Tài liệu nội bộ chuẩn bị cho IT Solution Challenge 2026. Cập nhật 09/06/2026.

---

## Phần 1 — Đánh giá so với đối thủ

### Vị thế hiện tại

Dự án **đã cân sức** ở hạng mục "sản phẩm thật, dùng được". Điểm phân biệt mạnh nhất so với
các đội thi sinh viên thông thường:

| Yếu tố | Đa số đội thi | TaxEasy |
|---|---|---|
| Offline | Hô khẩu hiệu, không chạy thật | UUID client + transaction Serializable + retry chống trùng — **chạy thật** |
| Hóa đơn điện tử | Bỏ qua hoặc giả lập | Xuất XML đúng TT 78/2021 |
| Tính thuế | Hardcode 1 con số | Đúng luật 2026 (ngưỡng 200tr, bỏ môn bài), tách theo loại hình HKD |
| Bảo mật | Để JWT secret trong code | Fail-fast, bcrypt, rate-limit từng route, check ownership |
| Test | Gần như không có | 31 test (sync, tax, auth, XML) |

### "Điểm nhấn" nên cân nhắc thêm (nếu còn thời gian)

Xếp theo tỉ lệ **ấn tượng / công sức**:

1. **🟢 Quét QR để nhập hàng nhanh** (1-2 ngày) — dùng camera quét mã vạch sản phẩm khi nhập kho.
   Demo rất "wow", công nghệ sẵn có (`mobile_scanner`).

2. **🟢 Gợi ý giá/cảnh báo bằng AI nhẹ** (1 ngày) — ví dụ: "Tháng này doanh thu sắp chạm ngưỡng
   chịu thuế, cân nhắc tách hóa đơn" hoặc "Món X bán chạy nhất, cân nhắc tăng tồn". Chỉ cần
   rule-based + 1 câu gọi Claude API là đủ tạo cảm giác thông minh.

3. **🟡 Báo cáo thuế xuất PDF sẵn để nộp** (1 ngày) — tờ khai mẫu 01/CNKD điền sẵn số liệu.
   Giải quyết đúng "nỗi đau" thật của hộ kinh doanh.

4. **🟡 Đa ngôn ngữ / giọng nói** (0.5 ngày) — nhập món bằng giọng nói khi tay bận bán hàng.

> **Khuyến nghị:** Với ~10 ngày còn lại, KHÔNG nên ôm hết. Chọn **đúng 1 điểm nhấn** (đề xuất #1
> hoặc #2) làm cho chỉn chu, còn lại dồn sức vào demo mượt + slide thuyết phục. Một tính năng "wow"
> chạy mượt ăn đứt ba tính năng nửa vời.

### Rủi ro cần phòng

- **Câu hỏi "test coverage?"** → đã có 31 test, chỉ rõ vùng sync/thuế/auth/XML. Trả lời tự tin.
- **Câu hỏi "có chạy offline thật không?"** → demo tắt mạng ngay tại chỗ (xem kịch bản).
- **Câu hỏi "số liệu thuế lấy đâu?"** → trích dẫn TT 18/2026, Luật TNCN sửa đổi 2025, NQ 198/2025/QH15.

---

## Phần 2 — Kịch bản Demo (chạy trọn chuỗi, ~4 phút)

> Mục tiêu: chứng minh "definition of done" không vấp. Chuẩn bị **2 thiết bị** nếu có (1 trình chiếu,
> 1 dự phòng). Server chạy sẵn, có sẵn 1 tài khoản demo + vài sản phẩm.

### Chuẩn bị trước (làm xong trước khi lên sân khấu)

- [ ] Server chạy: `cd server && npm run start:dev` — kiểm tra log "đang chạy tại..."
- [ ] App đã cài, đã đăng nhập sẵn 1 lần (token còn hạn) để khỏi gõ lại mật khẩu trên sân khấu
- [ ] Có sẵn ≥6 sản phẩm với giá + 1 sản phẩm có giá vốn (để khoe lợi nhuận)
- [ ] Cửa hàng đã nhập **MST hợp lệ** (10 số) — nếu không sẽ không xuất được XML
- [ ] Wifi/4G bật sẵn, biết cách tắt nhanh (gạt chế độ máy bay)

### Kịch bản (lời thoại + thao tác)

**1. Mở màn (15s)**
> "Hộ kinh doanh ở Việt Nam đang phải tự kê khai thuế từ 2026, nhưng họ không có công cụ.
> TaxEasy giải quyết: bán hàng — quản lý — thuế, trong một app, chạy được cả khi mất mạng."

**2. Đăng nhập (10s)** — mở app, đã ở màn Bán hàng. *(Nếu cần login: gõ tài khoản demo)*

**3. Bán hàng nhanh (30s)**
- Chạm 3-4 món → giỏ hàng cộng dồn
- Chọn "Tiền mặt", nhập tiền khách đưa → app tính tiền thối
- Bấm thanh toán → **hiện QR ngay** → "Khách quét QR là có thông tin hóa đơn"

**4. Offline — điểm nhấn kỹ thuật (40s)**
> "Giờ tôi tắt mạng — như khi quán ở chỗ sóng yếu."
- **Gạt chế độ máy bay**
- Bán thêm 2-3 đơn → vẫn mượt, vẫn ra hóa đơn
- Mở màn "Chờ đồng bộ" → chỉ vào số đơn đang chờ
> "Dữ liệu đã lưu an toàn trong máy. Không mất đơn nào."

**5. Bật mạng — tự đồng bộ (20s)**
- **Tắt chế độ máy bay**
- Đợi vài giây → số "chờ đồng bộ" về 0
> "Mạng về là tự đẩy lên server, không trùng số hóa đơn — kể cả bấm bán cùng lúc trên 2 máy."

**6. Chế độ Quản lý (40s)**
- Chuyển sang Quản lý → màn Doanh thu
- Chỉ: doanh thu hôm nay (tách tiền mặt/chuyển khoản), biểu đồ tuần/tháng/năm, top món bán chạy, lợi nhuận
- Mở màn Thuế → "Hệ thống tự ước tính thuế GTGT + TNCN theo đúng luật 2026, cảnh báo khi gần ngưỡng 200 triệu, nhắc hạn nộp tờ khai quý"

**7. Xuất hóa đơn điện tử (25s)**
- Vào Lịch sử hóa đơn → chọn 1 hóa đơn → Xuất XML
> "File XML đúng chuẩn Thông tư 78/2021 của Tổng cục Thuế — nộp được lên hệ thống hóa đơn điện tử."
- *(Nếu có)* mở file XML cho thấy cấu trúc

**8. Chốt (15s)**
> "Một app, một luồng: bán — quản lý — thuế. Offline-first, đúng luật, xuất hóa đơn chuẩn nhà nước.
> Đó là TaxEasy."

### Phương án dự phòng khi sự cố

| Sự cố | Xử lý |
|---|---|
| Mạng sân khấu chập chờn | Server chạy LAN, app trỏ IP nội bộ — đã hỗ trợ (`API_BASE_URL`) |
| App crash khi demo | Có thiết bị thứ 2 mở sẵn cùng trạng thái |
| Xuất XML báo thiếu MST | Đã kiểm tra trước ở checklist — nhưng nếu lỗi, mở file XML mẫu trong `docs/sample-invoice.xml` |
| Sync không về 0 | Bấm nút đồng bộ thủ công ở màn "Chờ đồng bộ" |

---

## Phần 3 — Việc đã làm hôm nay (09/06)

- ✅ Cập nhật luật thuế 2026: ngưỡng 200tr, bỏ lệ phí môn bài, đổi nguồn sang TT 18/2026
- ✅ Vá: validate MST (10 số / 10-3), `console.error` → Logger, `current_password` min length
- ✅ Thêm 16 test mới (auth flow + XML export) → tổng 31 test, tất cả pass
- ⬜ Chọn & làm 1 điểm nhấn (xem Phần 1)
- ⬜ Tập demo theo kịch bản Phần 2
