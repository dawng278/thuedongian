# TASK 10 — Xuất báo cáo & Lịch sử hóa đơn (trong App)

- **Ngày:** 11 (16/06/2026)
- **Chủ trì:** A (app) + B (api), B bắt đầu soạn nội dung báo cáo
- **Nhánh:** `feat/app-report`, `feat/api-report`
- **Mục tiêu:** Hoàn thiện chế độ Quản lý: xem lịch sử hóa đơn chi tiết và xuất báo cáo kỳ — tất cả trong app (thay cho web đã bỏ).

---

## BỐI CẢNH

Vì đã bỏ web, mọi nhu cầu "xem lại và xuất báo cáo" gói vào app luôn. Hộ một mình mở app là làm được tất cả: bán hàng, quản lý, và lấy báo cáo để kê khai thuế.

---

## VIỆC CẦN LÀM

### Thành viên A — App (chế độ Quản lý)
- [ ] Màn hình **Lịch sử hóa đơn**: danh sách theo ngày, chạm vào xem chi tiết.
- [ ] Chi tiết hóa đơn: các dòng hàng, tổng tiền, mở lại QR, xuất XML hóa đơn đó.
- [ ] Nút **Xuất báo cáo kỳ**: chọn khoảng thời gian → tạo file tổng hợp (CSV/PDF) lưu/chia sẻ từ điện thoại.
- [ ] Lọc lịch sử theo khoảng thời gian.

### Thành viên B — Backend + bắt đầu báo cáo dự thi
- [ ] API `GET /reports/period?from&to` → tổng hợp doanh thu, số hóa đơn, thuế ước tính.
- [ ] Đảm bảo `GET /invoices` trả đủ dữ liệu cho màn hình lịch sử.
- [ ] Soạn nháp báo cáo: mô tả bài toán, mục tiêu, kiến trúc (dùng sơ đồ đã có).
- [ ] Chụp màn hình các tính năng app đã xong.

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
# A
git checkout -b feat/app-report && cd app && flutter run
# B
git checkout -b feat/api-report && cd server && npm run start:dev
```

---

## TEST PLAN

- [ ] Mở lịch sử → thấy danh sách hóa đơn đúng.
- [ ] Chạm 1 hóa đơn → xem chi tiết + mở QR + xuất XML.
- [ ] Xuất báo cáo kỳ → file tạo ra đúng số liệu, mở/chia sẻ được từ điện thoại.
- [ ] Lọc thời gian → danh sách & báo cáo đổi đúng.

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "feat(app): lich su hoa don + xuat bao cao ky"
git add . && git commit -m "feat(api): API tong hop bao cao ky"
git pull origin dev --rebase && git push origin feat/<scope>-...
```

- [ ] Đã merge vào `dev`.
- [ ] Cập nhật `DONE_task10.md` và `BUGS_task10.md`.
