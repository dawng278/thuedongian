# TASK 12 — Đánh bóng, Quay Demo & Deploy

- **Ngày:** 13 (18/06/2026)
- **Chủ trì:** Cả hai
- **Nhánh:** `chore/release`, `docs/demo`
- **Mục tiêu:** Sản phẩm sẵn sàng trình diễn; có video demo; deploy backend ổn định; phỏng vấn hộ KD lấy dẫn chứng.

---

## VIỆC CẦN LÀM

### Thành viên A
- [ ] Build APK bản release, test trên điện thoại thật.
- [ ] Quay **video demo 3–5 phút** — kể câu chuyện "một app cho hộ một mình": bán hàng nhanh → tắt mạng vẫn bán → chuyển sang quản lý xem doanh thu + thuế ngay trên điện thoại.
- [ ] **Phỏng vấn 1–2 hộ kinh doanh thật** → ghi nhận xét + đo tốc độ trước/sau → đưa vào slide.

### Thành viên B
- [ ] Deploy server + DB (Railway/Render) — kiểm tra ổn định.
- [ ] App release trỏ về server đã deploy.
- [ ] Chuẩn bị **bản demo dự phòng offline** + dữ liệu mẫu (phòng mạng hội trường lỗi).

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
git checkout -b chore/release
# A: build APK
cd app && flutter build apk --release
# file: build/app/outputs/flutter-apk/app-release.apk
# B: deploy server
cd server && # cấu hình deploy Railway/Render
```

---

## TEST PLAN

- [ ] APK cài trên máy thật → chạy đủ luồng demo (cả 2 chế độ).
- [ ] Server deploy → app trỏ về chạy được từ mạng ngoài.
- [ ] Diễn thử video demo theo kịch bản, bấm giờ 3–5 phút.
- [ ] Bản dự phòng offline hoạt động độc lập mạng.

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "chore(release): build APK + deploy server"
git add . && git commit -m "docs(demo): video demo + ghi chu phong van ho KD"
git pull origin dev --rebase && git push origin chore/release
git checkout main && git merge dev && git push origin main
```

- [ ] Có APK + link server demo + video demo.
- [ ] Cập nhật `DONE_task12.md` và `BUGS_task12.md`.
