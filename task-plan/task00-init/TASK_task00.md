# TASK 00 — Khởi tạo dự án & Môi trường

- **Ngày:** 1 (06/06/2026)
- **Chủ trì:** Cả hai (pair)
- **Nhánh:** `chore/init-repo`
- **Mục tiêu:** Có monorepo chạy được skeleton cho app + server, mọi người clone về build được.

---

## VIỆC CẦN LÀM

### Chung (đầu ngày)
- [ ] Tạo repo GitHub `taxeasy`, thêm cả hai làm collaborator.
- [ ] Tạo cấu trúc thư mục `app/ server/ shared/ docs/ task-plan/`.
- [ ] Tạo `main` và `dev`. Đặt `dev` làm nhánh mặc định.
- [ ] Thêm `README.md` gốc + copy `RULEBASE.md` vào repo.
- [ ] Thêm `.gitignore` cho từng phần.

### Thành viên A — `app/` (sản phẩm chính)
- [ ] Khởi tạo project Flutter, chạy được app trắng trên emulator.
- [ ] Cài package: `sqflite`/`drift`, `dio`, `qr_flutter`, `uuid`, `intl`, `fl_chart`.

### Thành viên B — `server/`
- [ ] Khởi tạo NestJS + Prisma + kết nối PostgreSQL (local hoặc Docker).

---

## LỆNH BASH

```bash
# === CHUNG ===
mkdir taxeasy && cd taxeasy
git init
mkdir app server shared docs task-plan
git checkout -b main
git add . && git commit -m "chore: khoi tao cau truc monorepo"
git branch dev
git remote add origin <URL_REPO>
git push -u origin main && git push -u origin dev

# === A: Flutter ===
cd app
flutter create .
flutter pub add sqflite path dio qr_flutter uuid intl fl_chart
flutter run

# === B: NestJS ===
cd ../server
npm i -g @nestjs/cli && nest new . --package-manager npm
npm i prisma @prisma/client @nestjs/jwt @nestjs/config
npx prisma init && npm run start:dev
```

---

## TEST PLAN

- [ ] `flutter run` → app trắng không lỗi.
- [ ] `npm run start:dev` (server) → lên cổng, không lỗi DB.
- [ ] Người kia `git clone` → build được cả app + server theo README.

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "chore(init): skeleton app/server chay duoc"
git pull origin dev --rebase
git push origin chore/init-repo
# Mở PR vào dev → review → merge
```

- [ ] Đã merge vào `dev`, `dev` build được cả app + server.
- [ ] Cập nhật `DONE_task00.md` và `BUGS_task00.md`.
