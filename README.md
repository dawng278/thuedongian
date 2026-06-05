# TaxEasy

> Nền tảng hỗ trợ hộ kinh doanh tuân thủ Hóa đơn điện tử & Thuế  
> IT Solution Challenge 2026 · 2 thành viên · 06/06–20/06/2026

## Kiến trúc

**MỘT app điện thoại duy nhất** (2 chế độ: Bán hàng / Quản lý) + Backend NestJS. Không có web.

```
taxeasy/
├── app/        # Flutter — Sản phẩm chính (Thành viên A)
├── server/     # NestJS + Prisma + PostgreSQL (Thành viên B)
├── shared/     # API contract dùng chung
├── docs/       # Báo cáo, sơ đồ, ghi chú
└── task-plan/  # Bộ task (TASK/DONE/BUGS)
```

## Bắt đầu nhanh

### App (Flutter)

> Yêu cầu: Flutter SDK ≥ 3.0, Android Studio / Xcode

```bash
cd app
flutter pub get
flutter run
```

### Server (NestJS)

> Yêu cầu: Node.js ≥ 20, PostgreSQL đang chạy

```bash
cd server
cp .env.example .env   # Điền DATABASE_URL và JWT_SECRET
npm install
npx prisma migrate dev --name init
npm run start:dev
```

Server chạy tại `http://localhost:3000`.

## Phân vai

| Thành viên | Trách nhiệm |
|---|---|
| A | App Flutter: Bán hàng, Quản lý, offline, QR, biểu đồ, xuất file |
| B | Backend NestJS: API, hóa đơn/XML, thuế, đồng bộ |

## Quy tắc làm việc

Xem [RULEBASE.md](RULEBASE.md) — Git branching, chống conflict, quy ước commit.
