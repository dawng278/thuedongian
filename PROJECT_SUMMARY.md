# ThueDonGian Project Overview

## 1. Mục tiêu dự án

`ThueDonGian` là hệ thống quản lý bán hàng và hóa đơn điện tử cho hộ kinh doanh, gồm:
- App Flutter cho bán hàng offline và chế độ quản lý.
- Backend NestJS + Prisma + PostgreSQL cho auth, sản phẩm, hóa đơn, đồng bộ và báo cáo.
- Shared contract giữa mobile và server.

Dự án hướng đến:
- Bán hàng nhanh trên thiết bị di động.
- Hoạt động offline, lưu hóa đơn cục bộ, tự động đồng bộ khi có mạng.
- Quản lý doanh thu, thuế ước tính, lịch nhắc nộp thuế.
- Xuất báo cáo và XML hóa đơn / XML báo cáo.

## 2. Kiến trúc chính

### 2.1. App client (`app/`)
- Flutter app duy nhất.
- State management: `provider`.
- Local storage: `sqflite`.
- Offline queue: lưu hóa đơn chờ đồng bộ.
- QR Invoice: `qr_flutter`.
- UI gồm 2 chế độ:
  - `Bán hàng` (Sale mode)
  - `Quản lý` (Management mode)

### 2.2. Backend (`server/`)
- Framework: NestJS.
- ORM: Prisma + PostgreSQL.
- Auth: JWT.
- Modules chính:
  - `auth`
  - `stores`
  - `products`
  - `invoices`
  - `sync`
  - `reports`
  - `tax`

### 2.3. Shared contract (`shared/`)
- `shared/api-contract.md` chứa định nghĩa API giữa app và backend.

## 3. Cấu trúc thư mục chính

```
ThueDonGian/
├── app/
│   ├── lib/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── assets/
│   └── pubspec.yaml
├── server/
│   ├── src/
│   │   ├── auth/
│   │   ├── invoices/
│   │   ├── reports/
│   │   ├── sync/
│   │   ├── tax/
│   │   └── prisma/
│   ├── package.json
│   └── prisma/
│       ├── schema.prisma
│       └── seed.ts
├── shared/
│   └── api-contract.md
├── docs/
├── task-plan/
└── RULEBASE.md
```

## 4. App client quan trọng

### 4.1. Tính năng bán hàng
- `app/lib/screens/sale/sale_screen.dart`
  - Hiển thị lưới sản phẩm.
  - Thêm/xóa món.
  - Tính tổng.
- `app/lib/providers/invoices_provider.dart`
  - Tạo invoice, lưu local, đồng bộ ngay nếu online.
  - Poll internet mỗi 10 giây để tự động sync khi có pending.
- `app/lib/services/local_db.dart`
  - Lưu `LocalInvoice` vào SQLite.
  - Quản lý trạng thái `pending` / `synced`.
- `app/lib/screens/sale/pending_sync_screen.dart`
  - Hiển thị danh sách hóa đơn chờ đồng bộ.
  - Cho phép đồng bộ thủ công.

### 4.2. Quản lý / báo cáo
- `app/lib/screens/manage/invoice_history_screen.dart`
  - Lịch sử hóa đơn.
  - Chi tiết hóa đơn.
  - Xuất XML hóa đơn.
- `app/lib/screens/manage/tax_screen.dart`
  - Ước tính thuế theo kỳ tháng/quý/năm.
  - Báo cáo ngưỡng miễn thuế.
  - Link tới lịch nộp thuế.
- `app/lib/screens/manage/store_settings_screen.dart`
  - Nhập Mã số thuế cho cửa hàng.

### 4.3. API client
- `app/lib/services/http_api_service.dart`
  - Gọi backend cho login, stores, products, invoices, sync, tax, reports.
- `app/lib/services/api_service.dart`
  - Interface chung cho mọi implementation.
- `app/lib/services/mock_api_service.dart`
  - Mock implementation dùng cho demo và test.

## 5. Backend quan trọng

### 5.1. Đồng bộ hóa invoice
- `server/src/sync/sync.service.ts`
  - Nhận batch invoice từ client.
  - Check duplicate theo `id`.
  - Lưu atomic bằng `createInvoiceAtomic`.
- `server/src/sync/sync.controller.ts`
  - Route `POST /sync/invoices`.

### 5.2. Hóa đơn và XML
- `server/src/invoices/invoice-xml.service.ts`
  - Sinh XML hóa đơn điện tử theo mẫu nội bộ.
  - Validate MST và escape ký tự XML.
- `server/src/invoices/invoices.controller.ts`
  - Route `GET /invoices/:id/xml`.

### 5.3. Báo cáo và XML báo cáo
- `server/src/reports/reports.service.ts`
  - Tính doanh thu, nhóm top sản phẩm.
  - Tính ước lượng thuế từ `computeTax`.
- `server/src/reports/reports.controller.ts`
  - Route `GET /reports/period`
  - Route `GET /reports/period/xml`

### 5.4. Tax rules
- `server/src/tax/tax-rules.ts`
  - Quy tắc thuế GTGT / TNCN theo loại hình kinh doanh.
  - Hàm `computeTax` dùng để ước tính.

### 5.5. Xây dựng kiến trúc export XML mới
- `server/src/reports/internal-tax-report.ts`
- `server/src/reports/export-options.ts`
- `server/src/reports/tax-schema-version.ts`
- `server/src/reports/xml-builder.service.ts`
- `server/src/reports/xml-validator.service.ts`
- `server/src/reports/vietnam-tax-xml-exporter.ts`

Nội dung mới này tách riêng:
- Mô hình nội bộ `InternalTaxReport`
- Exporter chịu mapping sang XML
- Builder/validator riêng để hỗ trợ mở rộng lên chuẩn XSD sau này

## 6. Shared / API contract

- `shared/api-contract.md` xác định endpoint mobile-server.
- Các tính năng API chính: auth, stores, products, invoices, sync, tax, reports.

## 7. Lệnh thường dùng

### App Flutter
```bash
cd app
flutter pub get
flutter run
flutter test
flutter build apk
```

### Server NestJS
```bash
cd server
npm install
npm run start:dev
npm run build
npm run test
npm run test:e2e
npx prisma migrate dev
npx prisma studio
npx prisma db seed
```

## 8. Các file quan trọng để đọc nhanh

- `CLAUDE.md` — tổng quan dự án, kiến trúc, task plan.
- `RULEBASE.md` — quy tắc làm việc và nhánh.
- `docs/KichBan_Video_Demo.md` — kịch bản demo.
- `app/lib/screens/home/home_screen.dart` — điều phối chế độ Bán hàng / Quản lý.
- `app/lib/providers/invoices_provider.dart` — logic lưu & sync hóa đơn offline.
- `server/src/reports/reports.service.ts` — tổng hợp dữ liệu báo cáo.
- `server/src/reports/vietnam-tax-xml-exporter.ts` — layer export XML mới.

## 9. Ghi chú hiện tại

- Dự án đã hỗ trợ offline sale với pending queue.
- Có export XML nội bộ cho báo cáo; đang refactor thành kiến trúc export riêng.
- Mục tiêu tiếp theo: sẵn sàng cho mapping XML theo XSD Thuế Việt Nam mà không sửa business logic.

## 10. Branch và repo

- Repository: `dawng278/thuedongian`
- Branch hiện tại: `main`
