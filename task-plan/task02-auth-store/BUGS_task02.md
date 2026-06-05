# BUGS — Task 02: Xác thực & Cửa hàng

- **Ngày:** 3 (08/06)
- **Cách dùng:** Ghi NGAY khi gặp bug. Mỗi bug 1 dòng. Cập nhật trạng thái khi xử lý xong.

| ID | Mô tả bug | Cách tái hiện | Mức độ | Người phát hiện | Trạng thái | Cách khắc phục |
|----|-----------|---------------|--------|-----------------|------------|----------------|
| B02-01 | `GET /stores/me` trả 401 dù token hợp lệ | Đăng nhập lấy token → gọi `/stores/me` với Bearer token | Cao | Claude Code | 🟢 Đã đóng | `JwtModule.register()` đánh giá `process.env.JWT_SECRET` trước khi `ConfigModule` load → secret là `undefined`. Fix: dùng `JwtModule.registerAsync()` + inject `ConfigService` vào `JwtStrategy` |

## Ghi chú
- Bug chặn demo → ưu tiên cao nhất.
- Bug do conflict Git → ghi rõ ở đây (RULEBASE mục 6).
- Bug chưa kịp xử lý trước hạn → ghi vào "Hướng phát triển" trong báo cáo.
