# TASK 08 — Chế độ Quản lý trong App

- **Ngày:** 9 (14/06/2026)
- **Chủ trì:** A (app) — đây là điểm cốt lõi của kiến trúc "một app cho hộ một mình"
- **Nhánh:** `feat/app-manage`
- **Mục tiêu:** Thêm chế độ Quản lý ngay trong app, chuyển bằng một nút — gói toàn bộ quản lý vào app.

---

## BỐI CẢNH (vì sao có task này)

Khách hàng cốt lõi là **hộ một mình** (vừa chủ vừa bán). Họ chỉ dùng điện thoại. Vì vậy mọi thứ "quản lý" (doanh thu, thuế, báo cáo) phải nằm **ngay trong app**, chuyển chế độ bằng một nút, tất cả trên điện thoại.

---

## VIỆC CẦN LÀM

### Thành viên A — App
- [ ] Nút chuyển đổi **Bán hàng ⇄ Quản lý** (rõ ràng, dễ thấy).
- [ ] Màn hình Quản lý — Doanh thu:
  - [ ] Doanh thu hôm nay / tháng này.
  - [ ] Số hóa đơn đã xuất.
  - [ ] Món bán chạy (danh sách đơn giản).
  - [ ] Biểu đồ doanh thu theo ngày (gói chart Flutter, ví dụ `fl_chart`).
- [ ] Màn hình Quản lý — Quản lý món (thêm/sửa/ẩn) — gom phần đã làm ở Task 03.
- [ ] Lịch sử hóa đơn (danh sách, xem chi tiết, mở QR/XML).

### Thành viên B — hỗ trợ
- [ ] Đảm bảo API `GET /reports/revenue` và `GET /invoices` trả đủ dữ liệu app cần.

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
git checkout -b feat/app-manage
cd app && flutter pub add fl_chart && flutter run
```

---

## TEST PLAN

- [ ] Bấm nút → chuyển mượt giữa Bán hàng và Quản lý.
- [ ] Bán vài đơn → vào Quản lý thấy doanh thu cập nhật đúng.
- [ ] Biểu đồ theo ngày hiển thị đúng.
- [ ] Mở lịch sử hóa đơn → xem chi tiết + QR.
- [ ] Toàn bộ thao tác này làm được **chỉ trên một điện thoại**.

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "feat(app): che do quan ly (doanh thu, bieu do, lich su HD)"
git pull origin dev --rebase && git push origin feat/app-manage
```

- [ ] Đã merge vào `dev`.
- [ ] Cập nhật `DONE_task08.md` và `BUGS_task08.md`.
