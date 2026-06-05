# DONE — Task 08: Chế độ Quản lý trong App

- **Ngày:** 9 (14/06)
- **Cách dùng:** Tick `[x]` mỗi khi hoàn thành một mục. Commit cùng code: `docs(task): cap nhat tien do task 08`.

## Tiến độ
> Cập nhật thủ công: 13 / 15 mục đã xong.

## Checklist mục tiêu

- [x] Nút chuyển đổi **Bán hàng ⇄ Quản lý** (rõ ràng, dễ thấy) — `_ModeToggle` widget trong `home_screen.dart`.
- [x] Màn hình Quản lý — Doanh thu:
- [x] Doanh thu hôm nay / tháng này — `RevenueScreen` + `_StatCard`.
- [x] Số hóa đơn đã xuất (tháng này).
- [x] Món bán chạy (danh sách đơn giản) — top 5 theo doanh thu tháng.
- [x] Biểu đồ doanh thu theo ngày (`fl_chart` LineChart).
- [x] Màn hình Quản lý — Quản lý món (tab "Sản phẩm" = `ProductManageScreen`).
- [x] Lịch sử hóa đơn — `InvoiceHistoryScreen` với infinite scroll + bottom sheet chi tiết + nút QR.
- [x] Đảm bảo API `GET /reports/revenue` trả đủ dữ liệu — `ReportsService.getRevenue()`.
- [x] Bấm nút → chuyển mượt giữa Bán hàng và Quản lý.
- [x] Bán vài đơn → vào Quản lý thấy doanh thu cập nhật đúng.
- [x] Biểu đồ theo ngày hiển thị đúng.
- [x] Mở lịch sử hóa đơn → xem chi tiết + QR.
- [ ] Toàn bộ thao tác này làm được **chỉ trên một điện thoại** (cần test thực tế).
- [ ] Đã merge vào `dev`.
- [ ] Cập nhật `DONE_task08.md` và `BUGS_task08.md`.

## Ghi chú khi xong
- Người hoàn thành: Claude Code + Trinh Hai Dang
- Ngày hoàn thành thực tế: 06/06/2026
- Link PR đã merge:
- Đã merge vào `dev`: [ ]

## Chi tiết triển khai

### Server
- `server/src/reports/reports.service.ts` — `GET /reports/revenue?from=&to=`
  - trả `today_revenue`, `month_revenue`, `month_invoice_count`, `daily[]`, `top_products[]`
  - `daily[]`: group hóa đơn theo ngày trong khoảng `from–to`
  - `top_products[]`: top 5 món theo `subtotal` tháng này (dùng `invoiceItem.groupBy`)
- `ReportsModule` đăng ký vào `AppModule`

### App
- `RevenueProvider` — gọi `GET /reports/revenue`, parse `RevenueData`
- `RevenueScreen` — stat cards + `fl_chart` LineChart + top products list
- `InvoiceHistoryScreen` — infinite scroll list, bottom sheet chi tiết, nút "Xem QR"
- `HomeScreen` — 3 tabs trong chế độ Quản lý: Doanh thu / Sản phẩm / Hóa đơn
- `main.dart` — thêm `Provider<ApiService>` + `RevenueProvider` vào MultiProvider
