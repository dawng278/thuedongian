# TASK 09 — Thuế ước tính & Nhắc hạn kê khai

- **Ngày:** 10 (15/06/2026)
- **Chủ trì:** B (backend), A ghép kết quả vào chế độ Quản lý của app
- **Nhánh:** `feat/api-tax`, `feat/app-tax`
- **Mục tiêu:** Tự tổng hợp doanh thu chịu thuế, ước tính thuế, nhắc hạn kê khai — hiển thị ngay trong app.

---

## ⚠️ NGHIÊN CỨU TRƯỚC

- [ ] Tra cứu cách tính thuế cho hộ kinh doanh theo **quy định hiện hành** (tỷ lệ % trên doanh thu theo ngành nghề, ngưỡng doanh thu chịu thuế).
- [ ] Ghi rõ nguồn vào báo cáo. KHÔNG dùng số tự nghĩ.

---

## VIỆC CẦN LÀM

### Thành viên B — Backend
- [ ] API `GET /tax/estimate?period` → tổng doanh thu kỳ + thuế ước tính theo tỷ lệ ngành nghề.
- [ ] Cấu hình tỷ lệ thuế theo `business_type` (lấy từ quy định).
- [ ] API `GET /tax/deadlines` → các mốc hạn kê khai/nộp sắp tới.

### Thành viên A — App (ghép vào chế độ Quản lý)
- [ ] Khu vực "Thuế" trong chế độ Quản lý: doanh thu kỳ, thuế ước tính, ngày đến hạn.
- [ ] Cảnh báo nổi bật khi gần đến hạn.
- [ ] Ghi rõ trên màn hình: "Số liệu **ước tính tham khảo**, không thay thế tư vấn thuế chính thức."

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
# B
git checkout -b feat/api-tax && cd server && npm run start:dev
# A
git checkout -b feat/app-tax && cd app && flutter run
```

---

## TEST PLAN

- [ ] Doanh thu kỳ = tổng hóa đơn trong kỳ → khớp màn hình Quản lý.
- [ ] Thuế ước tính = doanh thu × tỷ lệ ngành → đúng công thức đã tra cứu.
- [ ] Đổi `business_type` → tỷ lệ thuế đổi theo.
- [ ] Sắp đến hạn → hiện cảnh báo trong app.

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "feat(api): tinh thue uoc tinh + nhac han ke khai"
git add . && git commit -m "feat(app): khu vuc thue trong che do quan ly"
git pull origin dev --rebase && git push origin feat/<scope>-...
```

- [ ] Đã merge vào `dev`.
- [ ] Cập nhật `DONE_task09.md` và `BUGS_task09.md`.
