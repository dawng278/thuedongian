# DONE — Task 11: Tích hợp End-to-End

- **Ngày:** 12 (17/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 11`.

## Tiến độ
> Cập nhật thủ công: 5 / 10 mục đã xong.

## Checklist mục tiêu

- [ ] Chạy **trọn kịch bản demo** end-to-end (cần chạy trực tiếp trên thiết bị).
- [ ] Sửa mọi bug trong file BUGS các task trước (ưu tiên bug chặn demo).
- [x] Dữ liệu mẫu đẹp cho demo — seed `prisma/seed.ts` cập nhật: tên quán thực tế + 74 hóa đơn demo 7 ngày gần đây.
- [x] App trỏ đúng server (default `http://localhost:3000` — đổi thành IP thiết bị khi test thật).
- [x] Dọn code — xóa `_RevenueStub`, không còn TODO/stub trong main flow.
- [ ] Chạy đủ 8 bước Definition of Done liên tiếp, không lỗi.
- [ ] Lặp lại 2 lần để chắc chắn ổn định.
- [ ] Test trên đúng thiết bị sẽ dùng demo.
- [x] `shared/api-contract.md` cập nhật đầy đủ tất cả endpoint (v2.0).
- [ ] Đã merge vào `dev`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code + Trinh Hai Dang
- Ngày hoàn thành thực tế: 06/06/2026 (cần hoàn thành test thực tế)
- Đã merge vào `dev`: [ ]

## Lệnh chạy demo

```bash
# 1. Start PostgreSQL (Docker)
docker run -d --name taxeasy-pg -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:16

# 2. Start server
cd server
cp .env.example .env  # chỉnh DATABASE_URL + JWT_SECRET
npm install
npx prisma migrate deploy
npx prisma generate
npx prisma db seed
npm run start:dev

# 3. Chạy app (đổi IP trong main.dart nếu test trên thiết bị vật lý)
cd app
flutter pub get
flutter run

# Tài khoản demo: owner@taxeasy.vn / password123
```

## Kịch bản demo (8 bước)

1. Đăng nhập → vào cửa hàng "Quán Ăn Ngon" với 15 món sẵn
2. Chạm 2 món → "Tính tiền" → "Xác nhận bán" < 3 giây → snackbar xanh
3. Bấm "Xem QR" → màn hình QR + chi tiết hóa đơn
4. Tắt WiFi → bán thêm đơn → snackbar cam (offline) → bật WiFi → sync badge → tap để sync
5. Bấm nút "Quản lý" → tab Doanh thu → biểu đồ 7 ngày + top món
6. Tab Thuế → thuế ước tính tháng/quý + hạn kê khai + disclaimer
7. Tab Hóa đơn → lọc theo ngày → xem chi tiết → nút QR → xuất CSV
8. Server: `GET /invoices/<id>/xml` → file XML đúng cấu trúc TT78
