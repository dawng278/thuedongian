# TASK 06 — Đồng bộ & Xử lý xung đột (Conflict Resolution)

- **Ngày:** 7 (12/06/2026)
- **Chủ trì:** B (api) chủ đạo, A (app) phối hợp test
- **Nhánh:** `feat/api-conflict`, `feat/app-conflict`
- **Mục tiêu:** Xử lý đúng tình huống danh mục bị sửa/xóa song song khi đang có hóa đơn offline → báo cáo thuế không sai.

---

## VIỆC CẦN LÀM

### Thành viên B — Backend
- [ ] Xác nhận hóa đơn **immutable**: không endpoint nào cho sửa/xóa hóa đơn đã phát sinh.
- [ ] Xung đột danh mục — sửa giá: dùng `updated_at`, **last-write-wins** theo thời điểm sửa thực tế.
- [ ] Xóa món đang dùng → giữ **soft delete**, hóa đơn offline tham chiếu vẫn lưu hợp lệ.
- [ ] Doanh thu/thuế luôn tính từ **giá snapshot trong hóa đơn**, không từ bảng giá hiện hành.

### Thành viên A — App
- [ ] Đồng bộ khi món đã bị xóa trên server (soft delete) → hóa đơn vẫn đẩy thành công nhờ snapshot.
- [ ] Hiển thị trạng thái đồng bộ rõ ràng.

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
git checkout -b feat/api-conflict && cd server && npm run start:dev
# A
git checkout -b feat/app-conflict && cd app && flutter run
```

---

## TEST PLAN (đúng câu phản biện của hội đồng)

- [ ] **KB1:** App offline bán "Phở 50k" → sửa giá thành 55k ở chế độ Quản lý → app đồng bộ → hóa đơn vẫn 50k. ✅
- [ ] **KB2:** App offline bán "Phở" → xóa "Phở" ở chế độ Quản lý → app đồng bộ → hóa đơn vẫn hợp lệ, "Phở" chỉ ẩn ở đơn tương lai. ✅
- [ ] **KB3:** Tổng doanh thu = tổng hóa đơn theo giá snapshot (không lệch khi đổi giá). ✅
- [ ] Thử sửa/xóa hóa đơn đã phát sinh qua API → bị từ chối. ✅

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "feat(api): conflict resolution (immutable invoice, soft delete, LWW)"
git pull origin dev --rebase && git push origin feat/api-conflict
```

- [ ] Đã merge vào `dev`.
- [ ] Chụp màn hình 3 kịch bản làm dẫn chứng phản biện.
- [ ] Cập nhật `DONE_task06.md` và `BUGS_task06.md`.
