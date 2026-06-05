# TASK 02 — Xác thực (Auth) & Cửa hàng (Store)

- **Ngày:** 3 (08/06/2026)
- **Chủ trì:** A (app) + B (api) song song
- **Nhánh:** `feat/api-auth`, `feat/app-auth`
- **Mục tiêu:** Đăng nhập bằng JWT; người dùng vào được cửa hàng của mình.

---

## VIỆC CẦN LÀM

### Thành viên B — Backend
- [ ] API `POST /auth/register` (tạo user owner + tạo store).
- [ ] API `POST /auth/login` → trả JWT.
- [ ] Guard xác thực JWT cho route cần bảo vệ.
- [ ] API `GET /stores/me`.

### Thành viên A — App
- [ ] Màn hình Đăng nhập (số điện thoại + mật khẩu).
- [ ] Màn hình Đăng ký (tạo cửa hàng: tên quán, loại hình kinh doanh).
- [ ] Lưu token vào secure storage local.
- [ ] Sau đăng nhập → tải cửa hàng → vào màn hình chính (mặc định chế độ Bán hàng).

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
# B
git checkout -b feat/api-auth && cd server && npm run start:dev
# A
git checkout -b feat/app-auth && cd app && flutter run
```

---

## TEST PLAN

- [ ] Đăng ký user mới → tạo được store.
- [ ] Đăng nhập sai mật khẩu → báo lỗi đúng.
- [ ] Đăng nhập đúng → nhận token, gọi `/stores/me` thành công.
- [ ] App: đăng nhập → vào màn hình chính có tên cửa hàng.
- [ ] Token hết hạn/giả → API trả 401, app yêu cầu đăng nhập lại.

---

## KẾT THÚC TASK (Git)

```bash
git add . && git commit -m "feat(<scope>): auth + store"
git pull origin dev --rebase && git push origin feat/<scope>-auth
# PR vào dev → review chéo → merge
```

- [ ] 2 nhánh đã merge vào `dev`.
- [ ] Cập nhật `DONE_task02.md` và `BUGS_task02.md`.
