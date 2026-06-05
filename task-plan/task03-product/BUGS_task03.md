# BUGS — Task 03: Danh mục hàng hóa & Lưới món

- **Ngày:** 4 (09/06)
- **Cách dùng:** Ghi NGAY khi gặp bug. Mỗi bug 1 dòng. Cập nhật trạng thái khi xử lý xong.

| ID | Mô tả bug | Cách tái hiện | Mức độ | Người phát hiện | Trạng thái | Cách khắc phục |
|----|-----------|---------------|--------|-----------------|------------|----------------|
| B03-01 | `ValidationPipe whitelist:true` xóa sạch fields DTO không có decorator | Thêm `ValidationPipe` global → login 500 lỗi `findUnique` where rỗng | Cao | Claude Code | 🟢 Đã đóng | Thêm `@IsEmail()`, `@IsString()`, v.v. vào tất cả DTO fields |
| B03-02 | Prisma schema thiếu `category` + `image_url` trên Product | POST /products với `category` → TS2353 compile error | TB | Claude Code | 🟢 Đã đóng | Thêm fields vào schema.prisma, chạy migrate dev + generate |

## Ghi chú
- Bug chặn demo → ưu tiên cao nhất.
- Bug do conflict Git → ghi rõ ở đây (RULEBASE mục 6).
- Bug chưa kịp xử lý trước hạn → ghi vào "Hướng phát triển" trong báo cáo.
