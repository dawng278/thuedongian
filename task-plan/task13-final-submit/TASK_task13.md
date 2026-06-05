# TASK 13 — Hoàn thiện Báo cáo/Slide & Nộp bài

- **Ngày:** 14 (19/06/2026) — nộp trước hạn 20/06
- **Chủ trì:** Cả hai
- **Nhánh:** `docs/final`
- **Mục tiêu:** Hoàn thiện toàn bộ hồ sơ dự thi và nộp đúng cấu trúc.

---

## HỒ SƠ DỰ THI CẦN NỘP (theo thể lệ)

- [ ] **Báo cáo kỹ thuật** (tối đa 20 trang): mô tả bài toán, mục tiêu, dữ liệu, phương pháp, kiến trúc hệ thống, kết quả, hướng phát triển.
- [ ] **Mã nguồn** đầy đủ + tài liệu hướng dẫn cài đặt/sử dụng (README).
- [ ] **Video demo** 3–5 phút.
- [ ] **Slide trình bày** (PowerPoint hoặc PDF).

---

## VIỆC CẦN LÀM

### Thành viên B
- [ ] Hoàn thiện báo cáo kỹ thuật (chèn sơ đồ kiến trúc + ảnh chụp màn hình app).
- [ ] README hướng dẫn cài đặt & chạy (app + server) rõ ràng.
- [ ] Rà mã nguồn: xóa secret, đảm bảo clone về chạy được.

### Thành viên A
- [ ] Hoàn thiện slide (vấn đề → giải pháp → demo → thị trường/mô hình KD → đội ngũ).
- [ ] **Giải trình lựa chọn "chỉ một app":** "khách hàng cốt lõi là hộ một mình dùng điện thoại, nên một app là thiết kế đúng — đơn giản, gọn, không bắt họ chuyển thiết bị. Phần quản lý/báo cáo nằm ngay trong app." (biến việc không có web thành lựa chọn có chủ đích)
- [ ] Nhúng dẫn chứng phỏng vấn hộ KD + số liệu tốc độ.
- [ ] **Luyện thuyết trình + phản biện** (3 câu hỏi hội đồng đã chuẩn bị).

---

## CHECKLIST CHẤT LƯỢNG TRƯỚC KHI NỘP

- [ ] Báo cáo ≤ 20 trang, đủ mục theo thể lệ.
- [ ] Nêu rõ phạm vi: "tạo XML đúng chuẩn, KHÔNG ký số/tích hợp thật cơ quan thuế".
- [ ] Giải trình lý do chọn một app (đề phòng giám khảo hỏi về web).
- [ ] Mọi số liệu thuế/cấu trúc XML đã trích nguồn chính thống.
- [ ] Source clone về máy sạch → chạy được theo README.
- [ ] Video 3–5 phút, nghe rõ, thấy rõ thao tác (nhấn mạnh 1 app làm tất cả).

---

## CẤU TRÚC THƯ MỤC NỘP

```
ITS2026_TenDoi_TaxEasy/
├── BaoCao_KyThuat.pdf
├── Slide.pdf            (hoặc .pptx)
├── VideoDemo.mp4        (hoặc link)
├── SourceCode/
│   ├── app/
│   ├── server/
│   └── README.md
└── README.md
```

> Link nộp bài: https://forms.gle/ncbCiyNrmD1EJZTE6

---

## LỆNH BASH

```bash
git checkout dev && git pull origin dev
git checkout -b docs/final
git add . && git commit -m "docs(final): bao cao + slide + README huong dan"
git pull origin dev --rebase && git push origin docs/final
git checkout main && git merge dev && git push origin main
```

- [ ] Đã nộp đầy đủ qua form.
- [ ] Cập nhật `DONE_task13.md` và `BUGS_task13.md`.

---

## SAU KHI NỘP — CHUẨN BỊ CHUNG KẾT (26/06)

- [ ] Luyện demo trực tiếp nhiều lần (cả 2 chế độ app).
- [ ] Chuẩn bị máy + thiết bị dự phòng + bản demo offline.
- [ ] Ôn kịch bản phản biện, đặc biệt câu "vì sao không có web".
