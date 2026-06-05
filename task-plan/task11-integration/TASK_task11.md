# TASK 11 — Tích hợp End-to-End

- **Ngày:** 12 (17/06/2026)
- **Chủ trì:** Cả hai (pair)
- **Nhánh:** `fix/integration`
- **Mục tiêu:** Chạy trọn chuỗi demo không lỗi, vá mọi điểm gãy giữa app ↔ server.

---

## VIỆC CẦN LÀM (cùng nhau)

- [ ] Chạy **trọn kịch bản demo** end-to-end (xem Definition of Done).
- [ ] Sửa mọi bug trong file BUGS các task trước (ưu tiên bug chặn demo).
- [ ] Dữ liệu mẫu đẹp cho demo (tên quán, món ăn thực tế).
- [ ] App trỏ đúng server đã deploy (hoặc server local ổn định).
- [ ] Dọn code, xóa log thừa, xóa file rác.

---

## ĐỊNH NGHĨA HOÀN THÀNH (chạy không lỗi)

Tất cả trên **một app điện thoại**:
1. [ ] Đăng nhập → vào cửa hàng có sẵn món (mặc định chế độ Bán hàng).
2. [ ] Chạm món → tạo đơn **< 3 giây**.
3. [ ] **Tắt mạng** → vẫn bán được, vào hàng đợi.
4. [ ] **Bật mạng** → tự đồng bộ, không trùng, không mất.
5. [ ] Khách yêu cầu → hiện QR hóa đơn.
6. [ ] Bấm nút → sang **chế độ Quản lý**: doanh thu + biểu đồ + thuế ước tính + nhắc hạn.
7. [ ] Xem **lịch sử hóa đơn** + xuất **XML hóa đơn đúng cấu trúc** + xuất báo cáo kỳ.
8. [ ] 3 kịch bản xung đột (Task 06) chạy đúng.

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
git checkout -b fix/integration
# terminal 1: cd server && npm run start:dev
# terminal 2: cd app && flutter run
```

---

## TEST PLAN

- [ ] Chạy đủ 8 bước Definition of Done liên tiếp, không lỗi.
- [ ] Lặp lại 2 lần để chắc chắn ổn định (yêu cầu "hoạt động ổn định khi trình diễn").
- [ ] Test trên đúng thiết bị sẽ dùng demo.

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "fix(integration): va loi end-to-end, on dinh luong demo"
git pull origin dev --rebase && git push origin fix/integration
git checkout main && git merge dev && git push origin main
```

- [ ] `main` đã ở trạng thái demo được.
- [ ] Cập nhật `DONE_task11.md` và `BUGS_task11.md` (đóng bug đã fix).
