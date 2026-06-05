# TASK 07 — QR & Xuất XML hóa đơn đúng cấu trúc

- **Ngày:** 8 (13/06/2026)
- **Chủ trì:** A (QR trên app) + B (XML trên server)
- **Nhánh:** `feat/app-qr`, `feat/api-invoice-xml`
- **Mục tiêu:** Xuất file XML hóa đơn đúng cấu trúc chuẩn (chưa ký số) — trả lời câu phản biện về tính hợp chuẩn.

---

## ⚠️ NGHIÊN CỨU TRƯỚC (bắt buộc, cùng nhau)

- [ ] Tải **quy chuẩn định dạng XML hóa đơn điện tử hiện hành** từ nguồn chính thống (Thông tư + phụ lục cấu trúc của Tổng cục Thuế).
- [ ] Liệt kê trường BẮT BUỘC: ký hiệu mẫu số, ký hiệu hóa đơn, số hóa đơn, MST người bán, thông tin người bán, danh sách hàng hóa/dịch vụ, thuế suất, tiền thuế, tổng tiền, vùng chữ ký số (để trống).
- [ ] Map các trường này vào schema DB hiện có (bổ sung nếu thiếu).

> Không tự bịa cấu trúc. Lấy từ văn bản gốc để giải trình trước hội đồng.

---

## VIỆC CẦN LÀM

### Thành viên B — Backend
- [ ] Module xuất 1 hóa đơn ra **file XML đúng cấu trúc chuẩn** (đủ trường bắt buộc, để trống ký số).
- [ ] API `GET /invoices/:id/xml` trả file XML.
- [ ] Validate XML đủ trường bắt buộc trước khi xuất.

### Thành viên A — App
- [ ] Khách yêu cầu hóa đơn → sinh & hiển thị **QR** (link/mã tra cứu hóa đơn).
- [ ] Mặc định đơn lẻ không cần nhập thông tin khách (chỉ hiện QR khi khách yêu cầu).

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
# B
git checkout -b feat/api-invoice-xml && cd server && npm i xmlbuilder2 && npm run start:dev
# A
git checkout -b feat/app-qr && cd app && flutter run
```

---

## TEST PLAN

- [ ] `GET /invoices/:id/xml` → tải file XML mở được, đúng cấu trúc.
- [ ] XML đủ: mẫu số, ký hiệu, số HĐ, MST, dòng hàng, thuế suất, tổng.
- [ ] Thiếu trường bắt buộc → validate báo lỗi (không xuất XML sai chuẩn).
- [ ] App: khách yêu cầu → hiện QR → quét ra thông tin hóa đơn.

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "feat(api): xuat XML hoa don dung cau truc chuan"
git add . && git commit -m "feat(app): sinh QR hoa don cho khach"
git pull origin dev --rebase && git push origin feat/<scope>-...
```

- [ ] Đã merge vào `dev`.
- [ ] Lưu 1 file XML mẫu vào `docs/` làm dẫn chứng phản biện.
- [ ] Cập nhật `DONE_task07.md` và `BUGS_task07.md`.
