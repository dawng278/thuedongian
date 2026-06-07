# ThueDonGian Flutter App

Ứng dụng Flutter chính cho Android/Linux. App dùng `API_BASE_URL` qua `--dart-define` để chạy được trên emulator hoặc điện thoại thật.

## Cài dependency

```bash
flutter pub get
```

## Chạy local

Linux desktop:

```bash
flutter run -d linux --dart-define=API_BASE_URL=http://localhost:3000
```

Android emulator:

```bash
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Android thật cùng Wi-Fi với máy chạy server:

```bash
flutter devices
flutter run -d <device-id> --dart-define=API_BASE_URL=http://<LAN-IP>:3000
```

## Build APK

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://<LAN-IP-or-deploy-url>:3000
```

## Kiểm tra

```bash
flutter analyze
flutter test
flutter build linux
```

Các luồng cần test tay: login/register, tạo quán đầu tiên, đổi quán, bán hàng, offline sync, QR hóa đơn, lịch sử hóa đơn, xuất PDF/CSV.
