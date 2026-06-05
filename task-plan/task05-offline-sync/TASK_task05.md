# TASK 05 — Offline & Hàng đợi đồng bộ

- **Ngày:** 6 (11/06/2026)
- **Chủ trì:** A (app) + B (api) — phần khó nhất, làm sớm
- **Nhánh:** `feat/app-offline-sync`, `feat/api-sync`
- **Mục tiêu:** Bán được khi mất mạng; có mạng tự đẩy hàng đợi; backend idempotent (không ghi trùng).

---

## VIỆC CẦN LÀM

### Thành viên A — App
- [ ] Lưu mọi hóa đơn vào SQLite với `status = pending` ngay khi tạo (không chờ mạng).
- [ ] Cơ chế phát hiện trạng thái mạng (online/offline).
- [ ] Hàng đợi đồng bộ: có mạng → lần lượt đẩy hóa đơn `pending` lên `/sync`.
- [ ] Nhận phản hồi → cập nhật `status = synced` + lưu số hóa đơn server trả về.
- [ ] Retry khi mạng chập chờn.

### Thành viên B — Backend
- [ ] API `POST /sync` nhận **danh sách** hóa đơn (batch).
- [ ] **Idempotency:** kiểm `id` (UUID client) đã tồn tại chưa → có thì bỏ qua, chưa thì lưu.
- [ ] Trả kết quả từng hóa đơn (đã lưu / đã tồn tại) + số hóa đơn.

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
# A
git checkout -b feat/app-offline-sync && cd app && flutter run
# B
git checkout -b feat/api-sync && cd server && npm run start:dev
```

---

## TEST PLAN (kịch bản mất mạng)

- [ ] **Tắt mạng** (máy bay) → bán 3 đơn → đều lưu `pending`.
- [ ] **Bật mạng** → 3 đơn tự đồng bộ → `status=synced`.
- [ ] Server có đúng 3 hóa đơn, không thiếu không thừa.
- [ ] **Gửi trùng** (đẩy lại cùng UUID) → server KHÔNG tạo bản ghi trùng.
- [ ] Mạng chập chờn giữa chừng → retry thành công, không mất đơn.

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "feat(app): offline queue + sync khi co mang"
git add . && git commit -m "feat(api): endpoint sync + idempotency theo UUID"
git pull origin dev --rebase && git push origin feat/<scope>-...
```

- [ ] Đã merge vào `dev`.
- [ ] Cập nhật `DONE_task05.md` và `BUGS_task05.md`.

> ⚠️ Nếu trễ: hạ cấp tạm sang "đồng bộ thủ công bấm nút" cho MVP, ghi vào BUGS để xử lý sau.
