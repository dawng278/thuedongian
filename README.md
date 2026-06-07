# ThueDonGian / TaxEasy

Ứng dụng Flutter cho hộ kinh doanh: bán hàng nhanh, quản lý nhiều quán, hóa đơn, doanh thu, ước tính thuế và xuất báo cáo PDF/CSV.

## Kiến trúc

```text
ThueDonGian/
├── app/        # Flutter app: Sale mode + Manage mode
├── server/     # NestJS + Prisma + PostgreSQL
├── shared/     # API contract
├── docs/       # UI/UX, báo cáo, mẫu XML
└── task-plan/  # Kế hoạch task nội bộ
```

## Chạy server

Yêu cầu: Node.js 20+, PostgreSQL, `DATABASE_URL` hợp lệ.

```bash
cd server
npm install
cp .env.example .env
npx prisma migrate dev
npm run seed
npm run start:dev
```

Server chạy tại `http://localhost:3000`. Tài khoản seed:

```text
Email: owner@taxeasy.vn
Password: password123
```

Seed tạo nhiều quán mẫu để kiểm tra store switcher, revenue/tax theo từng quán và báo cáo.

## Chạy app Flutter

Yêu cầu: Flutter 3.32+, Android SDK nếu build/chạy Android.

Linux desktop smoke test:

```bash
cd app
flutter pub get
flutter run -d linux --dart-define=API_BASE_URL=http://localhost:3000
```

Android emulator:

```bash
cd app
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Điện thoại Android thật: máy tính và điện thoại phải cùng Wi-Fi. Lấy IP máy tính bằng `ip addr` hoặc `hostname -I`, ví dụ `192.168.1.23`.

```bash
cd app
flutter devices
flutter run -d <device-id> --dart-define=API_BASE_URL=http://192.168.1.23:3000
```

Build APK release:

```bash
cd app
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.23:3000
```

## Kiểm tra trước demo

Server:

```bash
cd server
npm run build
npm test -- --runInBand
npm run test:e2e -- --runInBand
npx eslint "{src,apps,libs,test}/**/*.ts" --max-warnings=0
```

App:

```bash
cd app
flutter analyze
flutter test
flutter build linux
flutter build apk --release --dart-define=API_BASE_URL=http://<LAN-IP>:3000
```

## Luồng demo chính

1. Đăng nhập bằng tài khoản seed.
2. Mở store switcher trên AppBar, đổi giữa các quán.
3. Kiểm tra sản phẩm, bán hàng, tạo hóa đơn và QR.
4. Sang Quản lý, xem doanh thu/thuế thay đổi theo quán đang chọn.
5. Tab Hóa đơn, xuất báo cáo PDF/CSV; PDF có watermark `ThueDonGian`.

## Lưu ý Git

Không commit file local/generated như `.claude/settings.local.json`, `app/android/local.properties`, `.iml`, build output, env file. Các tài liệu trong `docs/`, gồm `docs/design/` nếu có, được giữ lại để nộp/chia sẻ.
