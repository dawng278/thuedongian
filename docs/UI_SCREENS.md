# Tài liệu Thiết kế Giao diện - TaxEasy 2026

> Blueprint UI/UX cho ứng dụng bán hàng và quản lý thuế hộ kinh doanh.  
> Design system: **Material 3 Expressive-inspired · White-first UI · Trust Blue · Adaptive POS · 8pt Grid**  
> Cập nhật: 06/06/2026

---

## Tinh thần thiết kế 2026

TaxEasy là công cụ làm việc hằng ngày, không phải landing page. Giao diện cần nhanh, rõ, ít gây mệt mắt, nhưng vẫn có cảm giác hiện đại qua màu, chuyển động, shape và các khoảnh khắc xác nhận.

| Nguyên tắc | Cách áp dụng |
|-----------|--------------|
| Rõ trước đẹp | Mỗi màn hình chỉ có 1 hành động chính thật nổi bật. |
| POS dùng một tay | Sale mode ưu tiên chạm nhanh, vùng chạm lớn, CartBar luôn trong tầm ngón cái. |
| Quản lý dùng để quét số | Manage mode dùng dashboard bento, số lớn, nhãn ngắn, chart ít nhiễu. |
| Sáng, sạch, dễ tin | Nền mặc định là trắng/surface sáng; màu brand chỉ dùng để dẫn hướng và nhấn CTA. |
| Biểu cảm có kiểm soát | Dùng motion, shape morph, ảnh và gradient ở điểm then chốt, không phủ màu toàn app. |
| Tin cậy tài chính | Màu semantic nhất quán, số tiền căn phải, trạng thái offline/sync luôn rõ. |
| Adaptive density | Phone nhỏ: compact; phone thường: comfortable; tablet/desktop: split view hoặc max-width. |
| Multi-store first | Một tài khoản có thể sở hữu nhiều quán; đăng ký tài khoản tách khỏi tạo/chọn quán. |

---

## Design Tokens Toàn Cục

### Color System

Ưu tiên `ColorScheme` của Material 3. Hex dưới đây là brand anchor; khi code nên lấy qua `Theme.of(context).colorScheme` và chỉ dùng hex cho custom gradient/semantic.

| Token | Hex / Role | Dùng cho |
|-------|------------|----------|
| Brand Primary | `#2563EB` Blue 600 | CTA chính, active icon, tab indicator, link |
| Brand Tone Light | `#EFF6FF` Blue 50 | Nền chip, selected subtle, hero card nhẹ |
| Brand Tone Soft | `#DBEAFE` Blue 100 | Border/tonal surface liên quan brand |
| Brand Tone Strong | `#1D4ED8` Blue 700 | Pressed state, active AppBar text/icon |
| Brand Gradient | `#2563EB -> #38BDF8` 135deg | Auth visual, Sale AppBar accent line, CartBar, hero metric |
| Success / Money | `#059669` Emerald 600 | Giá tiền, doanh thu, SnackBar thành công |
| Warning / Offline | `#D97706` Amber 600 | Offline, hạn sắp tới, sync chưa xong |
| Error / Urgent | `#DC2626` Red 600 | Lỗi, xóa, hạn gấp |
| Tax OK | `#16A34A` Green 600 | Dưới ngưỡng thuế |
| Tax Alert | `#EA580C` Orange 600 | Trên ngưỡng thuế |
| Surface Base | `#FFFFFF` | Nền mặc định toàn app |
| Surface Card | `#FFFFFF` / `cs.surface` | Card, sheet, list row |
| Surface Subtle | `#F8FAFC` / `cs.surfaceContainerHighest` | Input fill, filter bar, disabled surface |
| Surface Blue Tint | `#F5F9FF` | Band/header rất nhẹ, dashboard background |
| Text Primary | `#172033` | Tiêu đề, số tiền, nội dung chính |
| Text Secondary | `#64748B` / `cs.onSurfaceVariant` | Caption, hint, meta |
| Stroke Subtle | `#D9E2EC` / `cs.outlineVariant` | Border, divider, chart grid |

**Quy tắc 60-30-10:**

```text
75% white / neutral surfaces
15% blue tint surfaces
10% primary, gradient, semantic accents
```

Nền mặc định là trắng. Gradient chỉ dùng cho vùng có tính "hero" hoặc hành động cuối: auth visual, Sale AppBar accent line, CartBar, nút xác nhận quan trọng. Màn quản lý dùng surface trắng, border nhẹ và semantic colors để tránh mỏi mắt.

### Light / Dark Mode

| Thành phần | Light | Dark |
|------------|-------|------|
| Page bg | `#FFFFFF` hoặc `#F8FAFC` cho màn có nhiều card | `#0B1120` |
| Card bg | `#FFFFFF` | `#111827` |
| Elevated bg | `#FFFFFF` + stroke | `#172033` + stroke `#263247` |
| Primary text | `#172033` | `#E5E7EB` |
| Secondary text | `#64748B` | `#94A3B8` |
| Gradient overlay | blue gradient alpha 100% | alpha 85%, không làm lóa text |

Dark mode không đảo toàn bộ bằng opacity tùy tiện. Dùng `ColorScheme.fromSeed` hoặc scheme tĩnh đã kiểm contrast.

### Visual Assets & Gradients

Ứng dụng vẫn white-first, nhưng cần ảnh/gradient ở đúng vị trí để tránh cảm giác khô. Ảnh nên liên quan thật tới ngữ cảnh bán hàng nhỏ: quầy thu ngân, hóa đơn, món ăn, cửa hàng, không dùng stock tối/blur nặng.

| Vị trí | Visual | Quy tắc |
|--------|--------|---------|
| Login/Register | Ảnh hoặc generated bitmap quầy bán hàng sáng, phủ Brand Gradient 70-85% | Text đặt trực tiếp trên vùng ảnh/gradient, không đặt trong card nổi |
| Store onboarding | Illustration/ảnh storefront tối giản, nền trắng + blue tint | Giúp người dùng hiểu đây là tạo workspace/quán |
| Sale empty state | Illustration nhỏ `inventory/empty shelf` hoặc ảnh placeholder sáng | Không chiếm quá 35% chiều cao màn hình |
| Revenue hero card | Gradient xanh nhẹ + pattern line chart 6% alpha | Không làm khó đọc số tiền |
| Tax screen | Không dùng ảnh; dùng progress, icon và semantic cards | Thuế cần cảm giác tin cậy, không trang trí quá nhiều |
| Product tile | Ưu tiên ảnh món nếu có; fallback avatar chữ/hash màu | Ảnh bo góc 14dp, aspect ratio ổn định |

**Gradient chuẩn:** `LinearGradient([#2563EB, #38BDF8], begin: topLeft, end: bottomRight)`. Không dùng gradient tím/cầu vồng. Nếu màn hình đã có nhiều dữ liệu, chuyển gradient thành blue tint `#EFF6FF` để giữ độ đọc.

### Layout Composition

White-first không có nghĩa là trống trải. Mỗi màn hình cần có vùng chính rõ, nhịp spacing ổn định và điểm nhấn vừa đủ.

| Màn hình | Bố cục khuyến nghị |
|----------|--------------------|
| Auth | Visual header 32-38% chiều cao + form trắng 62-68%, CTA ở cuối form |
| Store onboarding | Centered column, max width 520dp, illustration 120-160dp, form ngay dưới |
| Sale | AppBar trắng + grid full screen + CartBar nổi; không thêm card bọc toàn bộ grid |
| Manage dashboard | ListView nền trắng/`#F8FAFC`, card bento tách bằng gap 12-16dp |
| History/detail | Ledger/list rõ ràng, amount nổi bật, filter sticky phía trên |
| Bottom sheet | Header sticky + content scroll + footer sticky nếu có CTA/tổng tiền |

**Quy tắc bố cục:**

```text
Page background: #FFFFFF cho form/list đơn giản, #F8FAFC cho dashboard nhiều card
Content max width: 420dp auth, 680dp phone/tablet portrait, 1180dp desktop
Page padding: 16dp phone, 24dp tablet
Section gap: 20-24dp
Card gap: 12dp
Primary CTA: đặt cuối vùng thao tác, không đặt nhiều CTA xanh cạnh nhau
Visual: chỉ chiếm 20-38% màn hình, không che nội dung làm việc
```

Không dùng card lồng card. Section là layout phẳng; card chỉ dành cho item lặp, metric, bottom sheet hoặc panel thực sự cần frame.

### Typography

Khuyến nghị font: **Inter Variable** hoặc **Roboto Flex**; fallback `Roboto`, `Noto Sans`. Tiếng Việt phải đặt `height >= 1.45`.

| Role | Size / Weight | Dùng cho |
|------|---------------|----------|
| displaySmall | 32sp / 700 | Logo auth, hero number duy nhất |
| headlineMedium | 28sp / 700 | Tổng tiền, doanh thu nổi bật |
| headlineSmall | 24sp / 700 | Modal title, form title |
| titleLarge | 22sp / 650 | AppBar, bottom sheet title |
| titleMedium | 16sp / 650 | Section title, card value |
| bodyLarge | 16sp / 400 | Nội dung chính, input text |
| bodyMedium | 14sp / 400 | List item, subtitle |
| bodySmall | 12sp / 400 | Meta, caption, timestamp |
| labelLarge | 14sp / 650 | Button, chip |
| labelSmall | 11sp / 500 | Badge, tooltip, mini label |
| numeral | 28-36sp / 750 | Số tiền lớn, không dùng cho câu dài |

**Số tiền:** dùng tabular numerals nếu font hỗ trợ. Căn phải trong invoice/detail, căn trái trong card hero.

### Spacing

```text
4dp   - icon/text gap nhỏ
8dp   - gap trong cùng group
12dp  - row/card padding compact
16dp  - page margin phone, card padding chuẩn
20dp  - gap giữa sections
24dp  - form padding, sheet content padding
32dp  - hero/form separation
48dp  - safe zone dưới floating controls
64dp  - empty state visual block
```

### Shape

Material 3 Expressive-inspired nhưng vẫn dễ code bằng Flutter `BorderRadius`.

| Shape | Radius | Dùng cho |
|-------|--------|----------|
| XS | 8dp | Chip nhỏ, chart tooltip |
| SM | 12dp | Input, icon container, row action |
| MD | 16dp | Card, product tile |
| LG | 20dp | Floating bar, segmented toggle |
| XL | 28dp | Bottom sheet top corners |
| Hero | 32dp | Auth panel, large dashboard card |

Shape morph chỉ dùng cho selected product tile, mode toggle, bottom sheet expansion. Không dùng shape lạ cho dữ liệu cần đọc nhanh.

### Elevation & Glass

| Layer | Spec |
|-------|------|
| Flat | Không shadow, dùng border `Stroke Subtle` |
| Raised | shadow black 6%, blur 16, y 6 |
| Floating | shadow primary 18%, blur 24, y 10 |
| Glass-lite | blur 16, white 14%, border white 30%, chỉ trên gradient/dark hero |

Card quản lý nên dùng border + tonal background thay vì shadow nặng. Glass không dùng trong list dày.

### Motion

| Token | Duration | Curve | Dùng cho |
|-------|----------|-------|----------|
| Micro | 140ms | `Curves.easeOut` | press, hover, icon state |
| State | 220ms | `Curves.easeOutCubic` | selected tile, mode toggle, chip |
| Sheet | 320ms | `Curves.easeOutCubic` | bottom sheet, CartBar entrance |
| Route | 420ms | `Curves.easeInOutCubic` | auth/home, QR screen |

Motion phải có chức năng: xác nhận, định hướng, hoặc giảm nhảy layout. Không animate số tiền từng frame nếu làm khó đọc. Tôn trọng `MediaQuery.disableAnimations`.

### Iconography

| Ngữ cảnh | Style |
|----------|-------|
| Inactive | `_outlined` |
| Active / selected | filled hoặc solid color |
| Destructive | icon red + text red, không chỉ đổi icon |
| Unknown action | luôn có tooltip |

Kích thước icon chuẩn: 20dp trong row, 24dp trong button, 32-48dp cho empty state.

### Accessibility

| Hạng mục | Chuẩn TaxEasy |
|----------|---------------|
| Touch target | Visual có thể 32-40dp, hit area tối thiểu 48x48dp trên mobile |
| WCAG minimum | Không control nào nhỏ hơn 24x24 CSS px khi build web/desktop |
| Contrast | Text thường >= 4.5:1, UI non-text >= 3:1 |
| Focus | Focus ring 2dp `cs.primary`, offset 2dp, không bị che bởi AppBar/CartBar |
| Text scale | Hỗ trợ 1.3x không vỡ layout; 1.5x cho form và invoice |
| Auth | Cho phép password manager, copy/paste, autofill; không dùng câu đố/captcha thị giác nếu không cần |
| Gesture | Mọi swipe/drag có button thay thế |

---

## Component Patterns

### AppBar

| Mode | Style |
|------|-------|
| Sale | Surface AppBar trắng, current store switcher, mode toggle blue tonal, sync badge, overflow, accent line xanh |
| Manage | Surface AppBar, current store switcher, segmented mode toggle, TabBar hoặc NavigationRail trên tablet |
| Detail | Surface AppBar, title ngắn, action icons có tooltip |

AppBar mặc định là surface trắng. Brand moment nằm ở CartBar, auth visual, hero metric và accent line, không phủ màu toàn thanh điều hướng.

### Store Context

TaxEasy dùng mô hình **1 người dùng -> nhiều quán**. Auth chỉ xác thực danh tính; dữ liệu bán hàng, sản phẩm, hóa đơn và thuế luôn nằm trong `currentStore`.

| Trường hợp | UI |
|------------|----|
| User chưa có quán | Điều hướng tới `StoreOnboardingScreen` để tạo quán đầu tiên |
| User có 1 quán | Vào Home với quán đó làm `currentStore` |
| User có nhiều quán | Vào quán dùng gần nhất; AppBar title là button mở store switcher |
| Đổi quán | Bottom sheet "Chọn quán" với list quán + action "Tạo quán mới" |
| Tạo thêm quán trong app | Có trong store switcher và màn `Cấu hình & Quản lý Quán`; form chỉ hỏi thông tin quán |

**Store switcher:** title AppBar hiển thị tên quán hiện tại + icon `keyboard_arrow_down`. Tap mở bottom sheet chọn quán. Khi đổi quán, reload products, invoices, revenue, tax summary, reports và clear cart để tránh bán nhầm quán.

**Thống kê theo quán:** mọi số liệu trong Doanh thu, Thuế, Hóa đơn, Xuất báo cáo, Sync queue và XML đều tính theo `currentStore`. Không hiển thị tổng nhiều quán trong MVP để tránh hiểu nhầm số thuế/báo cáo; nếu sau này cần tổng hợp toàn bộ, tạo màn riêng "Tổng quan tất cả quán".

### Buttons

| Loại | Spec |
|------|------|
| Primary | Filled Trust Blue hoặc gradient cùng họ xanh, height 52dp, radius 14-16dp |
| Secondary | OutlinedButton, border `Stroke Subtle`, radius 14dp |
| Tertiary | TextButton, chỉ dùng cho hành động phụ |
| Destructive | TextButton/Filled tonal red, luôn có xác nhận nếu mất dữ liệu |
| Loading | Spinner 20-22dp, disable double tap, giữ nguyên width button |

### Inputs

```dart
InputDecoration(
  filled: true,
  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: strokeSubtle, width: 1.2),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: cs.primary, width: 2),
  ),
)
```

Label rõ, hint là ví dụ cụ thể, error text đặt ngay dưới field. Không dùng placeholder thay label.

### Bottom Sheets

| Thuộc tính | Spec |
|------------|------|
| Corner | top radius 28dp |
| Handle | 44x4dp, radius 2dp, `cs.outlineVariant` |
| Snap | `0.45`, `0.65`, `0.92` tùy nội dung |
| Header | sticky khi sheet cao |
| Footer | sticky cho tổng tiền / submit |
| Keyboard | padding bottom `viewInsets.bottom + 16` |

### SnackBar / Toast

| State | Màu | Copy |
|-------|-----|------|
| Success | `#059669` | "Đã tạo hóa đơn #42 - 150.000đ" |
| Offline | `#D97706` | "Đã lưu offline hóa đơn #42 - chờ đồng bộ" |
| Error | `#DC2626` | "Không tạo được hóa đơn. Thử lại." |
| Info | `#2563EB` | "Đã xuất báo cáo" |

Snackbar có action tối đa 1 nút. Với lỗi có thể recover, action là "Thử lại".

### Empty / Loading / Error

Empty state gồm icon 56-64dp, title 16sp/650, body 14sp, action nếu có. Loading dữ liệu dài dùng skeleton cards thay vì spinner trống toàn màn hình.

---

## Mục Lục Màn Hình

1. [Màn hình Đăng nhập](#1-màn-hình-đăng-nhập)
2. [Màn hình Đăng ký](#2-màn-hình-đăng-ký)
2.1. [Onboarding Tạo / Chọn Quán](#21-onboarding-tạo--chọn-quán)
3. [Màn hình Chính Home](#3-màn-hình-chính-home)
4. [Chế độ Bán hàng - Lưới món](#4-chế-độ-bán-hàng---lưới-món)
5. [Giỏ hàng Bottom Sheet](#5-giỏ-hàng-bottom-sheet)
6. [Màn hình QR Hóa đơn](#6-màn-hình-qr-hóa-đơn)
7. [Quản lý - Tab Doanh thu](#7-quản-lý---tab-doanh-thu)
8. [Quản lý - Tab Thuế](#8-quản-lý---tab-thuế)
9. [Quản lý - Tab Sản phẩm](#9-quản-lý---tab-sản-phẩm)
10. [Quản lý - Tab Hóa đơn](#10-quản-lý---tab-hóa-đơn)
11. [Chi tiết Hóa đơn Bottom Sheet](#11-chi-tiết-hóa-đơn-bottom-sheet)
12. [Form Thêm / Sửa Sản phẩm Bottom Sheet](#12-form-thêm--sửa-sản-phẩm-bottom-sheet)
13. [Trung tâm Đồng bộ Offline](#13-trung-tâm-đồng-bộ-offline)
14. [Cấu hình & Quản lý Quán](#14-cấu-hình--quản-lý-quán)
15. [Xuất Báo cáo Kỳ PDF / CSV](#15-xuất-báo-cáo-kỳ-pdf--csv)
16. [Minh chứng Xung đột & Snapshot](#16-minh-chứng-xung-đột--snapshot)
17. [Chế độ Demo & Dữ liệu mẫu](#17-chế-độ-demo--dữ-liệu-mẫu)

---

## 1. Màn hình Đăng nhập

**File:** `app/lib/screens/auth/login_screen.dart`  
**Trigger:** Mặc định khi chưa đăng nhập  
**Pattern:** Brand hero + form bottom panel, tối ưu một tay

### Layout

```text
┌─────────────────────────────────────┐
│ BRAND VISUAL HERO                   │
│ SafeArea                            │
│ [receipt logo glass]                │
│ TaxEasy                             │
│ Bán hàng rõ ràng. Thuế nhẹ đầu.     │
│                                     │
├──────── rounded top 32dp ───────────┤
│ FORM SURFACE                        │
│ Đăng nhập                           │
│ Tiếp tục quản lý các quán của bạn   │
│ [ Email                         ]   │
│ [ Mật khẩu                    eye]  │
│ [ Đăng nhập                    ->]  │
│ Chưa có tài khoản? Đăng ký          │
└─────────────────────────────────────┘
```

### Hero

| Thành phần | Spec |
|------------|------|
| Background | Ảnh/quầy bán hàng sáng + Brand Gradient overlay 75%, hoặc gradient xanh nếu chưa có ảnh |
| Logo | 64dp circle white 18% glass-lite, icon `receipt_long`, 32dp white |
| Wordmark | displaySmall 700 white, letterSpacing 0 |
| Tagline | bodyMedium white 86%, max 2 dòng |
| Padding | `EdgeInsets.fromLTRB(24, 28, 24, 36)` |
| Decorative | Có thể dùng pattern hóa đơn rất mờ 4-6% alpha, không dùng blob/orb |

### Form

| Thành phần | Spec |
|------------|------|
| Container | `cs.surface`, top radius 32dp, min height 48% viewport |
| Padding | `fromLTRB(24, 32, 24, 24)`; tablet max width 420dp |
| Title | headlineSmall 700 `Text Primary` |
| Subtitle | bodyMedium `Text Secondary`, height 1.5 |
| Fields | input pattern toàn cục, gap 14dp |
| CTA | Filled Trust Blue hoặc Brand Gradient height 52dp, radius 16dp, icon `login` |
| Register link | TextButton, labelLarge primary |

### States

| State | Mô tả |
|-------|------|
| Loading | CTA giữ nguyên chiều cao, spinner trắng 22dp |
| Error | SnackBar đỏ + message cụ thể từ server |
| Offline | Nếu app cần mạng để đăng nhập: inline banner amber trên form |
| Success | Fetch stores; nếu rỗng -> StoreOnboardingScreen, nếu có -> HomeScreen |

---

## 2. Màn hình Đăng ký

**File:** `app/lib/screens/auth/register_screen.dart`  
**Trigger:** Từ LoginScreen  
**Pattern:** Account-first registration, không tạo quán tại bước đăng ký

**Nguyên tắc:** RegisterScreen chỉ tạo tài khoản người dùng. Không hỏi `Tên cửa hàng` tại đây, vì một người dùng có thể sở hữu nhiều quán. Sau khi đăng ký thành công, app kiểm tra danh sách quán:

| Kết quả | Điều hướng |
|---------|------------|
| Chưa có quán | `StoreOnboardingScreen` |
| Có quán | `HomeScreen` với quán dùng gần nhất |

### Layout

```text
┌─────────────────────────────────────┐
│ BRAND VISUAL HEADER                 │
│ <- Tạo tài khoản                    │
│ Tạo tài khoản chủ quán              │
├──────── rounded top 32dp ───────────┤
│ FORM SURFACE scroll                 │
│ Thông tin tài khoản                 │
│ [ Họ và tên                    ]    │
│ [ Email                        ]    │
│ [ Mật khẩu                    eye]  │
│ [ Đăng ký tài khoản            ->]  │
│ Bạn có thể tạo nhiều quán sau đó    │
└─────────────────────────────────────┘
```

### Header

| Thành phần | Spec |
|------------|------|
| Back button | 48dp hit area, icon `arrow_back_ios_new`, white |
| Title | headlineSmall 700 white |
| Helper copy | bodyMedium white 82%: "Tạo tài khoản trước, thêm quán sau" |
| Background | Ảnh/gradient xanh như Login nhưng thấp hơn; ưu tiên vùng trắng cho form |

### Section Label

| Thành phần | Spec |
|------------|------|
| Accent | 4x20dp rounded bar `Brand Primary` |
| Text | titleMedium 650 `Text Primary` |
| Gap | label -> first field 14dp |

### Field Order

| Field | Icon | Validate | Autofill |
|-------|------|----------|----------|
| Họ và tên | `person_outline` | Không rỗng | `name` |
| Email | `email_outlined` | Email hợp lệ | `email` |
| Mật khẩu | `lock_outline` | >= 6 ký tự | `newPassword` |

### Secondary Copy

Đặt dưới CTA, bodySmall `Text Secondary`: "Sau khi đăng ký, bạn có thể tạo quán đầu tiên hoặc tham gia quán được mời." Copy này giúp người dùng hiểu vì sao chưa nhập tên quán.

### States

| State | Mô tả |
|-------|------|
| Field error | Error dưới field, không chỉ SnackBar |
| Loading | Disable toàn form, CTA spinner |
| Success | Fetch stores; nếu rỗng -> StoreOnboardingScreen, nếu có -> HomeScreen |

---

## 2.1 Onboarding Tạo / Chọn Quán

**File đề xuất:** `app/lib/screens/store/store_onboarding_screen.dart`  
**Trigger:** Sau đăng nhập/đăng ký khi user chưa có `currentStore`, hoặc từ store switcher chọn "Tạo quán mới"  
**Pattern:** Workspace setup tối giản

### Layout

```text
AppBar: Thiết lập quán

┌─────────────────────────────────────┐
│ storefront image/illustration       │
│ Tạo quán đầu tiên                   │
│ Mỗi quán có sản phẩm, hóa đơn       │
│ và báo cáo riêng.                   │
│ [ Tên quán *                   ]    │
│ [ Loại hình kinh doanh         v]   │
│ [ Tạo quán và bắt đầu bán      ->]  │
└─────────────────────────────────────┘
```

### Fields

| Field | Icon | Validate | Ghi chú |
|-------|------|----------|---------|
| Tên quán | `storefront_outlined` | Không rỗng | Ví dụ: "Quán Phở Hà Nội" |
| Loại hình kinh doanh | `category_outlined` | Có default | Hàng hóa / Ăn uống / Dịch vụ, dùng cho thuế suất |

**Visual:** dùng nền trắng, một illustration/ảnh cửa hàng sáng ở đầu màn hình cao 120-160dp, đặt trong container blue tint `#EFF6FF`, radius 28dp. Không dùng full-screen gradient ở onboarding để form tạo quán vẫn rõ.

### Store Switcher Sheet

```text
┌── handle ───────────────────────────┐
│ Chọn quán                           │
│ ✓ Quán Phở Hà Nội                   │
│   Cafe Sáng                         │
│   Bún Bò Cô Ba                      │
│ [Tạo quán mới                  +]   │
└─────────────────────────────────────┘
```

| Thành phần | Spec |
|------------|------|
| Current store | leading check circle primary |
| Store row | min height 56dp, subtitle optional: địa chỉ / ngành |
| Create action | Sticky bottom ListTile/FilledButton `add_business_outlined` + "Tạo thêm quán" |
| Switch behavior | Đóng sheet, clear cart, reload dữ liệu theo store |
| After create | Chuyển `currentStore` sang quán mới, vào Sale mode với empty product state |

---

## 3. Màn hình Chính Home

**File:** `app/lib/screens/home/home_screen.dart`  
**Trigger:** Sau đăng nhập và đã có `currentStore`  
**Pattern:** 2 workspaces: Sale và Manage

### AppBar - Sale Mode

```text
┌────────────────────────────────────────────┐
│ WHITE AppBar                               │
│ Quán Phở Hà Nội v     [Bán hàng] [sync] [⋮]│
│ blue gradient accent line 3dp              │
└────────────────────────────────────────────┘
```

| Thành phần | Spec |
|------------|------|
| Background | `cs.surface` / white |
| Accent | bottom line 3dp Brand Gradient, radius 999 |
| Title | titleLarge 700 `Text Primary`, maxLines 1, tap mở store switcher |
| Subtitle optional | bodySmall `Text Secondary`: "Sẵn sàng bán hàng" nếu có chỗ |
| Foreground | `Text Primary` |
| Elevation | 0, bottom border `Stroke Subtle` |

### AppBar - Manage Mode

```text
┌────────────────────────────────────────────┐
│ Surface AppBar                             │
│ Quán Phở Hà Nội v      [Quản lý] [sync] [⋮]│
├────────────────────────────────────────────┤
│ Doanh thu | Thuế | Sản phẩm | Hóa đơn      │
└────────────────────────────────────────────┘
```

| Thành phần | Spec |
|------------|------|
| Background | `cs.surface` |
| Divider | bottom 1dp `Stroke Subtle` |
| Title | titleLarge 700 `Text Primary`, tap mở store switcher |
| Tab indicator | 3dp rounded pill `cs.primary` |
| Tab label | 14sp 650 selected, 14sp 500 unselected |

### `_ModeToggle`

| State | Spec |
|-------|------|
| Sale | `Brand Tone Light`, icon/text Brand Primary |
| Manage | `cs.primaryContainer`, icon/text `cs.onPrimaryContainer` |
| Container | height 36dp, padding horizontal 12dp, radius 20dp |
| Motion | 220ms easeOutCubic, width stable |
| Tooltip | "Chuyển chế độ" |

### `_SyncBadge`

Chỉ hiện khi `pendingCount > 0`.

| Thành phần | Spec |
|------------|------|
| Icon | `cloud_upload_outlined`, 24dp |
| Badge | `Badge.count`, max label "99+" |
| Tooltip | "Đồng bộ N hóa đơn offline" |
| Tap | Sync all, show SnackBar xanh/cam/đỏ |
| Loading | Icon chuyển spinner 18dp, giữ hit area 48dp |

### Adaptive

| Width | Navigation |
|-------|------------|
| < 600dp | AppBar + TabBar |
| 600-839dp | AppBar + TabBar centered max width |
| >= 840dp | NavigationRail cho Manage tabs, nội dung max width 1180dp |

---

## 4. Chế độ Bán hàng - Lưới món

**File:** `app/lib/screens/sale/sale_screen.dart`  
**Pattern:** Product grid + bottom command bar

### Layout

```text
SaleScreen
├── Product grid / empty state
└── Animated CartBar khi cartCount > 0
```

### Grid

| Property | Phone | Tablet |
|----------|-------|--------|
| Delegate | `SliverGridDelegateWithMaxCrossAxisExtent` | same |
| maxCrossAxisExtent | 176dp | 188dp |
| childAspectRatio | 0.86 | 0.9 |
| spacing | 10dp | 12dp |
| padding | 12dp + bottom CartBar safe zone | 20dp |

### `_ProductTile`

**Chưa chọn**

```text
┌─────────────────────┐
│ [avatar chữ]        │
│ Tên sản phẩm        │
│ 45.000đ             │
└─────────────────────┘
```

| Thành phần | Spec |
|------------|------|
| Background | `cs.surface` |
| Border | 1dp `Stroke Subtle` |
| Radius | 18dp |
| Padding | 14dp |
| Avatar | 44dp, tonal color 12%, chữ 18sp 750 |
| Name | bodyMedium 650, maxLines 2, height 1.35 |
| Price | bodySmall 750 `Success / Money` |
| Press | scale 0.98 trong 100ms |

**Đã chọn**

```text
┌─────────────────────┐
│ [qty badge]         │
│ Tên sản phẩm        │
│ 45.000đ             │
│ [-]             [+] │
└─────────────────────┘
```

| Thành phần | Spec |
|------------|------|
| Background | Brand Primary solid hoặc Brand Gradient xanh cùng họ |
| Border | 1.5dp transparent |
| Shadow | primary 20%, blur 18, y 8 |
| Qty badge | 44dp circle white 18%, text white 22sp 750 |
| Text | white, price white 90% |
| Quantity controls | IconButton 40dp, visible sau khi selected |

### Avatar Palette

```text
#2563EB Blue | #0284C7 Sky | #059669 Emerald | #D97706 Amber
#1D4ED8 Deep | #0891B2 Cyan | #DB2777 Pink    | #DC2626 Red
```

Hash: `product.name.codeUnits.fold(0, (a, b) => a + b) % palette.length`.

### Product Image

| Case | UI |
|------|----|
| Có ảnh món | Hiển thị ảnh 100% width phía trên tile, height 72-88dp, radius 14dp, `BoxFit.cover` |
| Không có ảnh | Dùng avatar chữ/hash màu như trên |
| Ảnh lỗi/loading | Skeleton blue tint `#EFF6FF`, sau đó fallback avatar |

Ảnh giúp lưới bán hàng đẹp và dễ nhận diện món, nhưng tile vẫn phải giữ layout ổn định để không nhảy khi ảnh tải xong.

### CartBar

```text
┌────────────────────────────────────────────┐
│ basket  N món       150.000đ   [Tính tiền] │
└────────────────────────────────────────────┘
```

| Thành phần | Spec |
|------------|------|
| Visibility | `AnimatedSlide` + `AnimatedOpacity`, 320ms |
| Container | margin `12,0,12,bottomSafe+12`, radius 22dp |
| Background | Brand Gradient, overlay black 4% |
| Shadow | primary 22%, blur 26, y 10 |
| Left | icon `shopping_basket_outlined`, "N món" 14sp 700 |
| Total | 17sp 750, tabular numerals |
| CTA | white FilledButton.icon, fg primary, radius 14dp |
| CTA icon | `receipt_long_outlined`, 18dp |

### Empty State

```text
Icons.inventory_2_outlined 64dp
Chưa có món nào
Thêm món trong tab Sản phẩm để bắt đầu bán hàng.
[Mở quản lý sản phẩm]
```

Button chỉ hiện nếu người dùng có quyền quản lý sản phẩm.

---

## 5. Giỏ hàng Bottom Sheet

**Widget:** `_CartSheet`  
**Trigger:** Nhấn "Tính tiền" trong CartBar
**Pattern:** Checkout compact, không rời ngữ cảnh bán hàng

### Layout

```text
┌── handle ───────────────────────────┐
│ Đơn hàng                    Xóa tất │  sticky white header
│ 3 món · Quán Phở Hà Nội             │
├─────────────────────────────────────┤
│ [img/A] Phở bò                      │
│         45.000đ x 2                 │
│         [-]  2  [+]        90.000đ  │
│ ...                                 │
├ sticky footer ──────────────────────┤
│ Tổng cộng                 150.000đ  │  large, right aligned
│ [Xác nhận bán                  ->]  │
└─────────────────────────────────────┘
```

### Spec

| Thành phần | Spec |
|------------|------|
| Snap | initial 0.62, min 0.42, max 0.92 |
| Header | sticky white, padding `24,20,16`, bottom border `Stroke Subtle` |
| Store context | Subtitle bodySmall `Text Secondary`; luôn hiển thị tên quán để tránh bán nhầm |
| Row món | White row, optional thumbnail 48dp, divider inset 72dp, padding vertical 12 |
| Thumbnail | 48dp radius 12dp, ảnh món nếu có; fallback avatar chữ/hash màu |
| Qty control | Stepper compact, 40dp buttons, background `#F8FAFC`, radius 12dp |
| Clear all | TextButton red, confirm dialog nếu > 1 món |
| Footer | `cs.surface`, top border, padding 16 + safe bottom |
| Total | label bodyMedium `Text Secondary`, amount titleLarge 750 `Text Primary`, căn phải |
| CTA | Filled Trust Blue hoặc Brand Gradient full-width, height 52dp |

### Micro UX

| Tình huống | UI |
|------------|----|
| Tăng/giảm số lượng | Animate subtotal 140ms, không animate toàn row |
| Qty về 0 | Row collapse 220ms rồi remove |
| Xóa tất cả | Dialog nhẹ: "Xóa toàn bộ đơn hàng?" với nút đỏ "Xóa" |
| Đang tạo hóa đơn | Footer CTA loading, khóa stepper để tránh lệch tổng |
| Cart rỗng khi sheet mở | Đóng sheet tự động sau 220ms |

### Sau Xác Nhận Bán

| Case | SnackBar | Màu | Action |
|------|----------|-----|--------|
| Online | `Đã tạo hóa đơn #N - x.xxxđ` | Success | `Xem QR` |
| Offline | `Đã lưu offline hóa đơn #N - chờ đồng bộ` | Warning | `Xem QR` |
| Lỗi | `Không tạo được hóa đơn. Thử lại.` | Error | `Thử lại` nếu có callback |

Sau success, cart reset bằng animation 220ms, không giật layout.

---

## 6. Màn hình QR Hóa đơn

**File:** `app/lib/screens/sale/invoice_qr_screen.dart`  
**Trigger:** SnackBar "Xem QR" hoặc từ invoice detail
**Pattern:** Receipt display, ưu tiên scan QR và đọc tổng tiền

### Layout

```text
AppBar: Hóa đơn #42

┌─────────────────────────────────────┐
│ QR CARD                             │
│ [QR 240x240]                        │
│ Khách quét mã để xem hóa đơn        │
└─────────────────────────────────────┘

┌ RECEIPT SUMMARY ────────────────────┐
│ Quán Phở Hà Nội             Online  │
│ Hóa đơn #42                         │
│ 06/06/2026 14:30                    │
│ Phở bò x 2                 90.000đ  │
│ Cà phê x 1                 30.000đ  │
│ Tổng cộng                 120.000đ  │
└─────────────────────────────────────┘

[Chia sẻ] [Xong]
```

### QR

| Thành phần | Spec |
|------------|------|
| Page background | `#FFFFFF`; nếu nhiều nội dung dùng `#F8FAFC` và card trắng |
| Card | `cs.surface`, radius 24dp, border `Stroke Subtle`, padding 24dp |
| QR size | 240dp phone, 280dp tablet |
| QR contrast | data module `cs.onSurface`, eye `cs.primary`, background white |
| Caption | bodySmall `Text Secondary`, center |
| Warning | Không đặt gradient/blur sau QR |

### Receipt Summary

| Thành phần | Spec |
|------------|------|
| Card | white, radius 20dp, border `Stroke Subtle`, padding 16dp |
| Store name | titleMedium 700 `Text Primary`, maxLines 1 |
| Status chip | Online green, Offline amber, Sync error red |
| Item row | bodyMedium, amount 650, amount căn phải |
| Divider | `Stroke Subtle`, margin vertical 12 |
| Total row | titleMedium 750, amount Brand Primary hoặc `Text Primary` |
| Long receipt | Items scroll trong card max height 260dp, total sticky dưới card |

### Payload

```json
{
  "id": "uuid",
  "so": 42,
  "ngay": "2026-06-06T10:00:00.000Z",
  "tong": 150000,
  "so_mon": 3
}
```

### Actions

| Action | Spec |
|--------|------|
| Chia sẻ | OutlinedButton.icon `share_outlined`, nếu app hỗ trợ share link/image |
| Xong | FilledButton.icon `check`, primary |
| Back | AppBar back, không mất dữ liệu |

**Action layout:** phone dùng row 2 nút full-width chia `Expanded`; màn hẹp < 360dp chuyển thành column, `Xong` đặt dưới cùng.

---

## 7. Quản lý - Tab Doanh thu

**File:** `app/lib/screens/manage/revenue_screen.dart`  
**Pattern:** Bento dashboard, ưu tiên scan số

### Layout

```text
RefreshIndicator
└── ListView padding(16)
    ├── PeriodHeader "Hôm nay" [Ngày/Tháng]
    ├── HeroRevenueCard "Hôm nay"
    ├── Row: "Tháng này" | "Số hóa đơn"
    ├── ChartCard "Doanh thu theo ngày"
    └── TopProductsCard "Món bán chạy"
```

### Period Header

| Thành phần | Spec |
|------------|------|
| Container | không card, padding bottom 8dp |
| Title | titleLarge 750 `Text Primary`: "Doanh thu" |
| Subtitle | bodySmall `Text Secondary`: `currentStore.name` + kỳ dữ liệu |
| Filter | SegmentedButton compact: `Hôm nay`, `7 ngày`, `Tháng này` nếu có đủ width |
| Refresh | Pull-to-refresh; không thêm nút refresh nếu đã có gesture |

**Scope:** chỉ thống kê hóa đơn của quán đang chọn. Khi đổi quán từ AppBar, `RevenueScreen` reload toàn bộ hero metric, stat cards, chart và top products.

### `_HeroRevenueCard`

| Thành phần | Spec |
|------------|------|
| Background | white card + Brand Gradient header strip 5dp hoặc `Brand Tone Light` nếu dữ liệu dày |
| Radius | 28dp |
| Padding | 20dp |
| Label | bodyMedium `Text Secondary` |
| Value | headlineMedium/displaySmall 750 `Text Primary`, tabular |
| Delta chip | optional: `+12%` green, `-8%` red |
| Icon | `trending_up`, 28dp trong blue tint container |
| Secondary metric | bodySmall: "N hóa đơn · Trung bình xđ/đơn" |

### `_StatCard`

| Thành phần | Spec |
|------------|------|
| Background | `cs.surface`, border `Stroke Subtle` |
| Icon box | 40dp, tonal primary/blue tint |
| Label | bodySmall `Text Secondary` |
| Value | titleMedium 750 `Text Primary` |
| Radius | 18dp |
| Padding | 16dp |

### LineChart

| Property | Giá trị |
|----------|---------|
| Height | 220dp |
| Card | white, radius 20dp, border `Stroke Subtle`, padding 16dp |
| Line | `cs.primary`, width 3, curved |
| Area fill | primary 10%, fade to 0 |
| Dots | Hiện khi <= 7 điểm hoặc điểm đang touch |
| Grid | horizontal only, `Stroke Subtle` |
| X axis | ngày `dd`, bodySmall |
| Y axis | compact currency: `120k`, `1.2tr` |
| Tooltip | surface card, radius 10dp, ngày + doanh thu |
| Empty | mini empty state trong chart card |

### Top Products

Rows dense nhưng chạm được:

```text
[#1] Phở bò                  42 lần
     3.780.000đ
```

Leading dùng rank pill thay vì icon lửa cho mọi row; top 1 có accent amber.

| Thành phần | Spec |
|------------|------|
| Card | white, radius 20dp, border `Stroke Subtle`, padding 8dp |
| Rank pill | 28dp, top 1 amber tint, còn lại blue tint |
| Product name | bodyMedium 650, maxLines 1 |
| Subtitle | bodySmall `Text Secondary`: "N lần bán" |
| Amount | bodyMedium 750 `Text Primary`, căn phải |
| Empty | Illustration nhỏ + "Chưa có món bán trong kỳ này" |

### Dashboard States

| State | UI |
|-------|----|
| Loading | Skeleton hero card + 2 stat cards + chart block |
| Empty | Hero card blue tint với `0đ`, chart empty, top products empty |
| Error | Inline error card đầu list + nút "Thử lại" |
| Offline cache | Banner amber subtle: "Đang xem dữ liệu đã lưu, có thể chưa mới nhất" |

---

## 8. Quản lý - Tab Thuế

**File:** `app/lib/screens/manage/tax_screen.dart`  
**Pattern:** Compliance assistant, không gây hoảng

### Layout

```text
RefreshIndicator
└── ListView padding(16)
    ├── TaxHeader: kỳ + ngành kinh doanh
    ├── SegmentedButton: Tháng này | Quý này
    ├── TaxThresholdCard
    ├── Nếu trên ngưỡng: TaxBreakdownCard x 3
    ├── DeadlineTimeline
    └── DisclaimerBox
```

### Tax Header

| Thành phần | Spec |
|------------|------|
| Title | titleLarge 750 `Text Primary`: "Thuế ước tính" |
| Subtitle | bodySmall `Text Secondary`: `currentStore.name` + loại hình kinh doanh |
| Source | TextButton/icon info: "Theo TT 40/2021/TT-BTC" |
| Background | không card; dùng whitespace để màn thuế nhẹ và đáng tin |

**Scope:** doanh thu chịu thuế và deadline context lấy theo quán đang chọn. Đổi quán phải gọi lại `GET /tax/estimate` và `GET /tax/deadlines`.

### `TaxThresholdCard`

| State | Nền | Icon | Border | Copy |
|-------|----|------|--------|------|
| Dưới ngưỡng | green 50 | `check_circle` green | green 200 | "Đang dưới ngưỡng thuế" |
| Gần ngưỡng >= 80% | amber 50 | `info` amber | amber 200 | "Sắp chạm ngưỡng, nên theo dõi" |
| Trên ngưỡng | orange 50 | `warning_amber` orange | orange 200 | "Đã vượt ngưỡng ước tính" |

Thêm progress bar:

```text
Doanh thu kỳ này       82.000.000đ
Ngưỡng tham chiếu     100.000.000đ
[████████░░] 82%
```

| Thành phần | Spec |
|------------|------|
| Card radius | 20dp |
| Padding | 18dp |
| Revenue value | headlineSmall 750, tabular |
| Progress | height 10dp, radius 999, semantic color theo state |
| Helper text | bodySmall, giải thích ngắn: "Ngưỡng tính theo doanh thu năm/kỳ tham chiếu" |

### Thuế suất TT 40/2021/TT-BTC

| Ngành | GTGT | TNCN | Tổng |
|-------|------|------|------|
| Hàng hóa | 1% | 0.5% | 1.5% |
| Ăn uống | 3% | 1.5% | 4.5% |
| Dịch vụ | 5% | 2% | 7% |

### Tax Breakdown Cards

| Card | Style |
|------|-------|
| Thuế GTGT ước tính | surface card, icon `percent`, value primary |
| Thuế TNCN ước tính | surface card, icon `person`, value Brand Primary |
| Tổng thuế | `cs.errorContainer` hoặc orange tonal nếu chỉ là ước tính |

**Layout:** dùng grid 1 cột trên phone, 2 cột trên tablet. Tổng thuế luôn full-width ở cuối, value lớn hơn 2 card còn lại.

### Deadline Timeline

| State | Nền | Icon | Badge |
|-------|-----|------|-------|
| Bình thường | `cs.surface` | `event_outlined` primary | chip primaryContainer |
| <= 14 ngày | red 50 | `alarm` red | chip red, text white |
| Quá hạn | red 100 | `error` red | chip "Quá hạn" |

**Timeline style:** không dùng ảnh. Dùng vertical line 2dp `Stroke Subtle`, node tròn 10dp theo màu state, card trắng nhỏ bên phải.

### Disclaimer

`Container(color: cs.surfaceContainerHighest, radius: 12, padding: 12)` với icon `info_outline` 18dp. Copy ngắn: "Số thuế là ước tính theo dữ liệu bán hàng trong app. Vui lòng kiểm tra với cơ quan thuế hoặc kế toán trước khi kê khai."

### Tax States

| State | UI |
|-------|----|
| Loading | Skeleton threshold card + tax cards |
| Chưa có doanh thu | Card xanh nhẹ, progress 0%, text "Chưa phát sinh doanh thu trong kỳ" |
| Thiếu loại hình | Inline warning + action "Cập nhật loại hình" |
| Error | Error card trắng border red subtle, nút "Thử lại" |

---

## 9. Quản lý - Tab Sản phẩm

**File:** `app/lib/screens/manage/product_manage_screen.dart`  
**Pattern:** Search-first inventory list

### Layout

```text
Scaffold
├── ProductHeader "Sản phẩm" + count
├── Search/filter header sticky
├── ListView.separated
│   └── ProductRow x N
└── FAB.extended "Thêm món"
```

### Product Header

| Thành phần | Spec |
|------------|------|
| Title | titleLarge 750 `Text Primary`: "Sản phẩm" |
| Subtitle | bodySmall `Text Secondary`: "N món đang bán · M món đang ẩn" |
| Background | white, không card |
| Sort action | optional MenuButton: "Mới nhất", "Tên A-Z", "Giá cao" |

### Search / Filter Header

| Thành phần | Spec |
|------------|------|
| Container | sticky white, padding bottom 8dp, bottom border khi scroll |
| SearchBar | height 48dp, radius 16dp, icon `search`, hint "Tìm món" |
| Filter chips | optional: Tất cả, Đồ ăn, Đồ uống, Đang ẩn |
| Sticky | Có thể sticky dưới AppBar nếu list dài |

Nếu chưa implement search, vẫn chừa vùng header cho tương lai nhưng không hiển thị control rỗng.

### `_ProductRow`

```text
[img/A]  Tên sản phẩm             [⋮]
         45.000đ / tô
         Đồ ăn · Đang bán
```

| Thành phần | Spec |
|------------|------|
| Height | min 76dp |
| Leading | 52dp thumbnail radius 12dp nếu có ảnh; fallback avatar tonal hash |
| Title | bodyLarge 650 `Text Primary`, maxLines 1 |
| Subtitle | bodyMedium 650 `Success / Money` |
| Meta line | bodySmall `Text Secondary`: nhóm + trạng thái |
| Hidden state | opacity 55%, badge "Ẩn" |
| Trailing | PopupMenuButton hit area 48dp |
| Divider | inset 84dp, color `Stroke Subtle` |

### Product Image Rules

| Case | UI |
|------|----|
| Có ảnh | Thumbnail 52dp, `BoxFit.cover`, radius 12dp |
| Không ảnh | Avatar chữ/hash màu, background tint 12% |
| Ảnh lỗi | Icon `image_not_supported_outlined`, blue tint bg |
| Đang tải | Skeleton 52dp radius 12dp |

### Popup Menu

| Action | Icon | Style |
|--------|------|-------|
| Sửa | `edit_outlined` | default |
| Ẩn / Hiện lại | `visibility_off_outlined` / `visibility_outlined` | default |
| Xóa | `delete_outline` | red, chỉ khi backend hỗ trợ |

Ẩn sản phẩm nên có SnackBar "Đã ẩn món" + action "Hoàn tác".

### FAB

```dart
FloatingActionButton.extended(
  icon: Icon(Icons.add),
  label: Text('Thêm món'),
)
```

FAB dùng `cs.primaryContainer` hoặc `cs.primary`; không dùng gradient để CartBar vẫn là hành động thương mại nổi bật nhất.

### Product States

| State | UI |
|-------|----|
| Loading | Skeleton rows có thumbnail + title + price |
| Empty | Illustration kệ hàng sáng + "Chưa có sản phẩm nào" + CTA "Thêm món" |
| Search empty | "Không tìm thấy món phù hợp" + action "Xóa tìm kiếm" |
| Error | Inline error card + "Thử lại" |

---

## 10. Quản lý - Tab Hóa đơn

**File:** `app/lib/screens/manage/invoice_history_screen.dart`  
**Pattern:** Filterable ledger

### Layout

```text
Column
├── InvoiceHeader: tổng kỳ + filter summary
├── FilterBar sticky
└── RefreshIndicator
    └── Infinite invoice list
```

### Invoice Header

| Thành phần | Spec |
|------------|------|
| Title | titleLarge 750 `Text Primary`: "Hóa đơn" |
| Subtitle | bodySmall `Text Secondary`: `currentStore.name` + kỳ đang lọc |
| Summary strip | optional blue tint: "Tổng kỳ này: xđ · N hóa đơn" |
| Background | white, không shadow |

**Scope:** danh sách, filter, CSV/PDF export và detail sheet chỉ dùng hóa đơn của quán đang chọn.

### FilterBar

```text
[date_range  Lọc theo ngày] [Hôm nay] [Tháng này]        [download]
```

| Thành phần | Spec |
|------------|------|
| Container | surface, bottom border, padding `8,16` |
| Date filter | OutlinedButton.icon, radius 20dp |
| Quick chips | Hôm nay, 7 ngày, Tháng này nếu có đủ width |
| Clear | IconButton `clear`, tooltip "Xóa bộ lọc" |
| Export report | IconButton `download_outlined`, mở `_PeriodReportSheet`, disabled khi rỗng |
| Horizontal overflow | chips scroll ngang trên phone nhỏ |

### `_InvoiceTile`

```text
[#42]  150.000đ                    Online
       06/06/2026 14:30 · 3 món        >
```

| Thành phần | Spec |
|------------|------|
| Leading | 44dp tonal avatar, `#N` 12sp 700 |
| Title | titleMedium 750, amount `Text Primary`, tabular |
| Subtitle | bodySmall `Text Secondary`, date + item count + status |
| Status | Chip nhỏ: Online green, Offline amber, Sync error red |
| Trailing | `chevron_right`, `cs.outline` |
| Tap | Open `_InvoiceDetailSheet` |
| Row bg | white; pressed state `Brand Tone Light` |

### Infinite Scroll

| State | UI |
|-------|----|
| Initial loading | Skeleton invoice rows |
| Loading more | 32dp spinner centered, padding 16 |
| Empty | Empty state + clear filter nếu đang lọc |
| Error | Inline retry row cuối list |

### Export

Format cột:

```text
Số HĐ | Ngày | Tổng tiền | Trạng thái | Ghi chú | Mặt hàng (tên x số; tên x số...)
```

Nút download ở lịch sử mở `_PeriodReportSheet` để chọn `PDF` hoặc `CSV`. Sau export: SnackBar xanh "Đã tạo báo cáo" + action "Chia sẻ" nếu flow tách 2 bước.

### Invoice Empty States

| State | UI |
|-------|----|
| Không có hóa đơn | Illustration hóa đơn sáng + "Chưa có hóa đơn nào" |
| Filter rỗng | "Không có hóa đơn trong khoảng ngày này" + nút "Xóa bộ lọc" |
| Export disabled | Tooltip "Không có dữ liệu để xuất" |

---

## 11. Chi tiết Hóa đơn Bottom Sheet

**Widget:** `_InvoiceDetailSheet`  
**Trigger:** Tap `_InvoiceTile`  
**Pattern:** Receipt detail, action nhanh nhưng không chen chúc

### Layout

```text
┌── handle ───────────────────────────┐
│ Hóa đơn #42              [QR] [XML] │  sticky header
│ 06/06/2026 14:30 · Online           │
├─────────────────────────────────────┤
│ [img/A] Phở bò x 2         90.000đ  │
│ [img/A] Cà phê x 1         30.000đ  │
├─────────────────────────────────────┤
│ Tổng cộng                 120.000đ  │
│ Ghi chú: ...                        │
│ [Đóng]                              │
└─────────────────────────────────────┘
```

### Spec

| Thành phần | Spec |
|------------|------|
| Snap | initial 0.62, max 0.92 |
| Header | sticky, titleLarge 700, subtitle bodySmall |
| QR action | IconButton `qr_code`, tooltip "Xem QR", đóng sheet rồi push QR |
| XML action | IconButton `code_outlined`, tooltip "Xuất XML" |
| Item row | dense, optional thumbnail 40dp, amount title/bodyMedium 650 success |
| Total row | top divider, amount titleLarge 750 primary |
| Note | chỉ hiện nếu có, surface subtle box |
| Close | FilledButton hoặc TextButton full-width tùy chiều cao |

### Detail Layout Rules

| Thành phần | Spec |
|------------|------|
| Header | sticky white, bottom border `Stroke Subtle`, actions 48dp hit area |
| Status chip | đặt cạnh subtitle nếu đủ width, nếu hẹp đặt dưới subtitle |
| Items list | max height 320dp; scroll riêng nếu hóa đơn dài |
| Total block | sticky footer nếu item list dài |
| QR/XML actions | icon-only nhưng bắt buộc tooltip |

### XML Action Copy

Nếu chưa có export file thật: SnackBar info "XML có thể tải qua API hóa đơn" + action "Sao chép link" nếu có URL.

---

## 12. Form Thêm / Sửa Sản phẩm Bottom Sheet

**Widget:** `_ProductFormSheet`  
**Trigger:** FAB "Thêm món" hoặc PopupMenu "Sửa"  
**Pattern:** Product editor, có preview và ảnh món

### Layout

```text
┌── handle ───────────────────────────┐
│ Thêm sản phẩm                       │
│ [Ảnh món / chọn ảnh]                │
│ [ Tên món *                    ]    │
│ [ Giá bán *                   đ]    │
│ [ Đơn vị        ] [ Nhóm       ]    │
│ Preview: Phở bò · 45.000đ / tô      │
│ [Thêm món                       +]  │
└─────────────────────────────────────┘
```

### Fields

| Field | Icon | Keyboard | Validate |
|-------|------|----------|----------|
| Tên món | `fastfood_outlined` | text | Không rỗng, trim whitespace |
| Giá bán | `payments_outlined` | number | Số nguyên >= 0 |
| Đơn vị | `straighten_outlined` | text | Tùy chọn, hint "tô, ly, phần" |
| Nhóm | `category_outlined` | text | Tùy chọn, hint "Đồ ăn, Đồ uống" |
| Ảnh món | `image_outlined` | image picker | Tùy chọn, crop vuông/4:3 nếu có |

### Spec

| Thành phần | Giá trị |
|------------|---------|
| Padding | `24, 20, 24, viewInsets.bottom + 16` |
| Gap fields | 12dp |
| Row fields | chuyển thành column nếu width < 360dp hoặc text scale > 1.2 |
| Preview | surface subtle, radius 12dp, bodySmall |
| Submit | height 52dp, radius 16dp, icon theo mode |
| Loading | spinner 20dp, giữ text hoặc thay bằng "Đang lưu..." |

### Image Picker

| State | UI |
|-------|----|
| Chưa có ảnh | Blue tint upload tile 96dp high, icon `add_photo_alternate_outlined`, text "Thêm ảnh món" |
| Có ảnh | Preview 96dp high, radius 16dp, `BoxFit.cover`, action "Đổi ảnh" |
| Xóa ảnh | Small icon button `close`, tooltip "Xóa ảnh" |
| Upload lỗi | Inline error dưới image tile, không chỉ SnackBar |

### Button Modes

| Mode | Text | Icon |
|------|------|------|
| Tạo mới | "Thêm món" | `add` |
| Chỉnh sửa | "Lưu thay đổi" | `save_outlined` |

### States

| State | Mô tả |
|-------|------|
| Success | Đóng sheet, list cập nhật, SnackBar xanh ngắn |
| Error | Giữ sheet mở, show inline error nếu thuộc field; SnackBar đỏ nếu lỗi server |
| Keyboard | Sheet tự scroll để field focus không bị che |
| Unsaved changes | Khi kéo đóng/back nếu form đã sửa, hỏi "Bỏ thay đổi?" |

---

## 13. Trung tâm Đồng bộ Offline

**Widget đề xuất:** `_SyncCenterSheet`  
**Trigger:** Nhấn `_SyncBadge` trên AppBar khi có hóa đơn `pending`, hoặc từ InvoiceHistory filter trạng thái offline  
**Pattern:** Offline queue, minh bạch và có thể retry thủ công

### Layout

```text
┌── handle ───────────────────────────┐
│ Đồng bộ hóa đơn              [sync] │
│ 3 hóa đơn đang chờ · Quán Ăn Ngon   │
├─────────────────────────────────────┤
│ [amber] Offline                     │
│ Hóa đơn #local-uuid...              │
│ 06/06/2026 14:30 · 120.000đ         │
│ Chờ đồng bộ                         │
│ ...                                 │
├ sticky footer ──────────────────────┤
│ Server: http://...                  │
│ [Đồng bộ ngay]                      │
└─────────────────────────────────────┘
```

### Sync States

| State | UI |
|-------|----|
| Không có pending | Empty state nhỏ: `cloud_done_outlined`, "Tất cả hóa đơn đã đồng bộ" |
| Pending | Badge amber, row nền white, status chip "Chờ đồng bộ" |
| Syncing | Progress linear 2dp dưới header, CTA loading, row đang gửi có spinner 18dp |
| Synced | Row chuyển green tint 220ms rồi biến mất khỏi queue |
| Duplicate | Chip info blue: "Đã có trên server", vẫn tính là thành công |
| Failed | Chip red + inline reason ngắn + action "Thử lại" |

### Spec

| Thành phần | Spec |
|------------|------|
| Sheet snap | initial 0.65, max 0.92 |
| Header | sticky white, bottom border `Stroke Subtle` |
| Queue row | min height 76dp, amount tabular, UUID rút gọn `...8 ký tự cuối` |
| Footer | sticky white, safe bottom, CTA full-width Trust Blue |
| Batch result | Sau sync show SnackBar: "Đã đồng bộ N hóa đơn · M trùng bỏ qua" |
| Manual MVP | Nếu chưa có auto connectivity, copy rõ: "Bấm đồng bộ khi có mạng" |

### AppBar Badge Rules

| Count | UI |
|-------|----|
| 0 | Ẩn badge |
| 1-99 | Badge count |
| > 99 | Badge "99+" |
| Sync failed | Badge đỏ nhỏ + tooltip "Có hóa đơn đồng bộ lỗi" |

Không làm mất dữ liệu nếu sync fail. Mọi hóa đơn offline vẫn xem được trong lịch sử với status `Offline`.

---

## 14. Cấu hình & Quản lý Quán

**File đề xuất:** `app/lib/screens/store/store_settings_screen.dart` hoặc bottom sheet từ overflow menu  
**Trigger:** Popup menu `Quản lý quán`, Store switcher action "Tạo thêm quán", Tax screen warning "Cập nhật loại hình", XML export thiếu `storeTaxId`  
**Pattern:** Store management, tạo thêm quán và cấu hình thuế/XML theo từng quán

### Layout

```text
AppBar: Quản lý quán

ListView padding(16)
├── CurrentStoreCard
│   Quán đang dùng: Quán Ăn Ngon
│   [Đổi quán] [Tạo thêm quán]
├── MyStoresList
│   ✓ Quán Ăn Ngon
│     Cafe Sáng
│     Bún Bò Cô Ba
├── StoreProfileCard của currentStore
│   [Tên quán *]
│   [Mã số thuế / MST]
│   [Địa chỉ]
├── BusinessTypeCard
│   Segmented: Hàng hóa | Ăn uống | Dịch vụ
│   Thuế suất hiện tại: GTGT x% · TNCN y%
├── InvoiceXmlCard
│   Trạng thái: Đủ / Thiếu thông tin XML
│   [Lưu thay đổi]
└── Danger zone: không có xóa quán trong MVP
```

### My Stores

| Thành phần | Spec |
|------------|------|
| Current store row | leading check circle Brand Primary, bg `Brand Tone Light` |
| Other store row | white row, border bottom `Stroke Subtle`, tap chuyển quán |
| Create store CTA | FilledButton.icon `add_business_outlined`, text "Tạo thêm quán" |
| Store count | bodySmall `Text Secondary`: "Bạn đang quản lý N quán" |
| Empty impossible | Nếu chưa có quán thì không vào màn này, chuyển StoreOnboardingScreen |

### Create Store Flow

```text
Tap "Tạo thêm quán"
  -> _StoreFormSheet(mode:create)
       [Tên quán *]
       [Loại hình kinh doanh]
       [Mã số thuế]
       [Địa chỉ]
       [Tạo quán]
  -> success: set currentStore = new store
  -> reload all store-scoped data
```

| Case | UI |
|------|----|
| Creating | CTA loading, disable form |
| Success | SnackBar xanh "Đã tạo quán mới"; AppBar đổi sang tên quán mới |
| Duplicate name | Inline error dưới field tên quán |
| Cancel with input | Confirm "Bỏ thông tin quán đang nhập?" |

**Quan trọng:** tạo thêm quán không copy sản phẩm/hóa đơn từ quán cũ. Quán mới bắt đầu với danh mục rỗng và báo cáo 0đ, trừ khi sau này có flow "sao chép danh mục".

### Fields

| Field | Icon | Validate | Dùng cho |
|-------|------|----------|----------|
| Tên quán | `storefront_outlined` | Không rỗng | AppBar, XML seller name |
| Mã số thuế | `badge_outlined` | Tùy chọn trong app, bắt buộc khi xuất XML thật | XML `MST`, báo cáo |
| Địa chỉ | `location_on_outlined` | Tùy chọn | XML seller address |
| Loại hình | `category_outlined` | Bắt buộc | Thuế suất TT40 |

### Business Type

| Type | Label | GTGT | TNCN | Tổng |
|------|-------|------|------|------|
| `goods` | Hàng hóa | 1% | 0.5% | 1.5% |
| `food_beverage` | Ăn uống | 3% | 1.5% | 4.5% |
| `services` | Dịch vụ | 5% | 2% | 7% |

### XML Readiness

| State | UI |
|-------|----|
| Đủ thông tin | Green chip "Sẵn sàng xuất XML" |
| Thiếu MST | Amber card: "XML cần mã số thuế người bán" + focus button tới field MST |
| Thiếu tên quán | Red inline error dưới field |
| Server 422 khi export | Dialog/Sheet "Thiếu thông tin xuất XML" + action "Mở cài đặt quán" |

### Save Behavior

| Case | UI |
|------|----|
| Saving | CTA loading, disable fields |
| Success | SnackBar xanh "Đã lưu thông tin quán" |
| Error | Inline nếu field lỗi, SnackBar đỏ nếu server/network |
| Đổi loại hình | Tax screen refresh estimate, show SnackBar info "Thuế suất đã cập nhật" |

---

## 15. Xuất Báo cáo Kỳ PDF / CSV

**Widget đề xuất:** `_PeriodReportSheet`  
**Trigger:** Nút download trong InvoiceHistory hoặc menu "Xuất báo cáo kỳ" trong Manage mode  
**Pattern:** Date range -> store-scoped summary preview -> export PDF/CSV

### Layout

```text
┌── handle ───────────────────────────┐
│ Xuất báo cáo kỳ                     │
│ Quán: Quán Ăn Ngon                  │
│ [ Từ ngày ][ Đến ngày ]             │
│ Quick: Hôm nay | 7 ngày | Tháng này │
├─────────────────────────────────────┤
│ Preview                             │
│ Doanh thu              12.450.000đ  │
│ Số hóa đơn             74           │
│ Top món                Phở bò       │
│ Thuế ước tính          560.250đ     │
├─────────────────────────────────────┤
│ [PDF] [CSV]                         │
│ [Xuất & chia sẻ]                    │
└─────────────────────────────────────┘
```

### Report Summary

| Thành phần | Spec |
|------------|------|
| Sheet snap | initial 0.7, max 0.92 |
| Store scope | Hiển thị rõ `currentStore.name`; báo cáo chỉ lấy dữ liệu quán đang chọn |
| Date range | Outlined date fields, calendar icon, Vietnamese date format |
| Quick chips | Hôm nay, 7 ngày, Tháng này, Quý này |
| Format selector | SegmentedButton: `PDF`, `CSV`, default `PDF` |
| Preview card | white, radius 20dp, border `Stroke Subtle`, values tabular |
| CTA | Filled Trust Blue full-width, disabled khi không có dữ liệu |

### PDF Report Template

**Tên mẫu:** `Mẫu báo cáo doanh thu & thuế ước tính - ThueDonGian`  
**Khổ:** A4 portrait, margin 18mm, font fallback `Roboto/Noto Sans`, màu chính Trust Blue.

```text
┌────────────────────────────────────────────┐
│ ThueDonGian                                │
│ BÁO CÁO DOANH THU & THUẾ ƯỚC TÍNH          │
│ Quán: Quán Ăn Ngon                         │
│ Kỳ báo cáo: 01/06/2026 - 30/06/2026        │
│ Xuất lúc: 06/06/2026 14:30                 │
├────────────────────────────────────────────┤
│ 1. Tổng quan                               │
│ Doanh thu | Số hóa đơn | Giá trị TB/đơn    │
│                                            │
│ 2. Thuế ước tính                           │
│ Loại hình | GTGT | TNCN | Tổng thuế        │
│                                            │
│ 3. Món bán chạy                            │
│ # | Tên món | Số lượng | Doanh thu         │
│                                            │
│ 4. Danh sách hóa đơn                       │
│ Số HĐ | Ngày | Tổng tiền | Trạng thái      │
│                                            │
│ Disclaimer                                 │
│ Số liệu tham khảo, không thay thế tư vấn   │
│ thuế chính thức.                           │
│                  watermark: ThueDonGian    │
└────────────────────────────────────────────┘
```

### PDF Visual Rules

| Thành phần | Spec |
|------------|------|
| Header | Logo/text `ThueDonGian`, Brand Primary, line 2dp |
| Watermark | Text `ThueDonGian`, diagonal -30deg, opacity 6-8%, center mỗi trang |
| Page number | Footer phải: `Trang X/Y` |
| Store info | Tên quán, MST nếu có, địa chỉ nếu có |
| Summary cards | 3 ô ngang trên A4; nếu xuất mobile preview thì stack |
| Tables | Header blue tint `#EFF6FF`, border `#D9E2EC`, amount căn phải |
| Disclaimer | Box `#F8FAFC`, icon info, font 10-11sp |
| Signature area | Optional cuối trang: "Người lập báo cáo" để trống |

**Chuẩn báo cáo:** đây là mẫu báo cáo nội bộ/kê khai tham khảo của app, không thay thế biểu mẫu pháp lý của cơ quan thuế. Nếu cần nộp chính thức, người dùng dùng số liệu từ báo cáo để điền vào hệ thống/biểu mẫu theo quy định hiện hành.

### CSV Columns

```text
Tên quán | MST | Từ ngày | Đến ngày | Số HĐ | Ngày | Tổng tiền | Trạng thái | Ghi chú | Mặt hàng (tên x số; tên x số...)
```

### States

| State | UI |
|-------|----|
| Loading preview | Skeleton summary rows |
| Không có dữ liệu | Empty card + CTA disabled + copy "Không có hóa đơn trong kỳ này" |
| Exporting PDF | CTA loading "Đang tạo PDF..." |
| Exporting CSV | CTA loading "Đang tạo CSV..." |
| Success PDF | Share sheet hệ điều hành + SnackBar "Đã tạo báo cáo PDF" |
| Success CSV | Share sheet hệ điều hành + SnackBar "Đã tạo file CSV" |
| Error | Inline error trong sheet + "Thử lại" |

### File Naming

`thuedongian-report_<store-slug>_<yyyyMMdd>-<yyyyMMdd>.pdf`  
`thuedongian-report_<store-slug>_<yyyyMMdd>-<yyyyMMdd>.csv`

File lưu tạm bằng `path_provider`, chia sẻ bằng `share_plus`. Nếu sau này thêm package PDF, ưu tiên template cố định để xuất ra giống nhau trên mọi thiết bị.

---

## 16. Minh chứng Xung đột & Snapshot

**Widget đề xuất:** `_InvoiceIntegrityInfoSheet` trong demo/debug hoặc từ InvoiceDetail "Thông tin đồng bộ"  
**Trigger:** Tap status chip trong InvoiceDetail/InvoiceHistory, hoặc dùng khi phản biện demo Task 06  
**Pattern:** Explainability, chứng minh hóa đơn bất biến

### Layout

```text
┌── handle ───────────────────────────┐
│ Tính toàn vẹn hóa đơn               │
│ Hóa đơn #42                         │
├─────────────────────────────────────┤
│ UUID client: ...a8f9                │
│ Trạng thái: Đã đồng bộ              │
│ Giá lưu trên hóa đơn: 50.000đ       │
│ Giá hiện tại của món: 55.000đ       │
│ Kết luận: Báo cáo dùng giá snapshot │
└─────────────────────────────────────┘
```

### Evidence Cases

| Case | UI |
|------|----|
| Giá món đã đổi | Blue info card: "Hóa đơn giữ giá tại thời điểm bán" |
| Món đã ẩn/xóa mềm | Amber info card: "Món không bán mới, hóa đơn cũ vẫn hợp lệ" |
| Hóa đơn pending | Amber chip + "Đang chờ đồng bộ, dữ liệu vẫn lưu trên máy" |
| Duplicate sync | Blue chip + "Server đã có hóa đơn này, không tạo trùng" |
| PATCH/DELETE invoice | Không có action sửa/xóa trong UI; chỉ note "Hóa đơn đã phát sinh không thể sửa/xóa" |

### Spec

| Thành phần | Spec |
|------------|------|
| Sheet | white, radius 28dp, no image |
| Tone | nghiêm túc, giải thích ngắn gọn để dùng trong phản biện |
| Values | amount tabular, old/current price đặt 2 cột |
| Action | `Đã hiểu` full-width TextButton hoặc FilledButton tùy độ dài |

Phần này không cần nổi bật với người dùng thường, nhưng rất hữu ích cho demo: giải thích vì sao doanh thu/thuế không lệch khi đổi giá hoặc ẩn sản phẩm.

---

## 17. Chế độ Demo & Dữ liệu mẫu

**Mục đích:** Hỗ trợ Task 11-13: chạy demo 3-5 phút ổn định, có dữ liệu đẹp và có phương án dự phòng offline. Đây có thể là cấu hình build/debug hoặc một banner trạng thái, không nhất thiết là màn production.

### Demo Data

| Thành phần | Chuẩn |
|------------|-------|
| Tên quán | "Quán Ăn Ngon" hoặc tên thật, không dùng placeholder kỹ thuật |
| Sản phẩm | 15 món thực tế, có category và ảnh/placeholder sáng |
| Hóa đơn mẫu | Khoảng 7 ngày gần đây để chart revenue có đường đẹp |
| Tài khoản demo | Hiển thị trong README/demo script, không hiển thị trong app production |

### Demo Banner

```text
┌─────────────────────────────────────┐
│ Demo offline: dữ liệu đang lưu trên │
│ thiết bị. Bán hàng vẫn hoạt động.   │
└─────────────────────────────────────┘
```

| State | UI |
|-------|----|
| Server local | Info chip trong settings: `localhost/IP` |
| Server deploy | Green chip "Server online" |
| Offline demo | Amber banner subtle ở Home/Manage, không che CartBar |
| Seed data loaded | SnackBar info "Đã nạp dữ liệu mẫu" chỉ trong demo/debug |

### Demo Flow Checklist UI

Nếu cần màn nội bộ cho quay video, dùng checklist read-only:

```text
1. Đăng nhập
2. Bán đơn < 3 giây
3. Tắt mạng bán offline
4. Sync không trùng
5. Xem QR
6. Doanh thu + Thuế
7. Lịch sử + PDF/CSV + XML
8. Snapshot/conflict
```

**Rule:** Demo helper không xuất hiện trong bản nộp production nếu không có lý do. Nếu giữ lại, đặt sau developer flag hoặc long-press logo 5 lần.

---

## Luồng Điều Hướng Tổng Quát

```text
LoginScreen
  ├── RegisterScreen
  └── Auth success
        └── Load stores
              ├── no store -> StoreOnboardingScreen
              │     └── Create first store -> HomeScreen [Sale mode]
              └── has store -> HomeScreen [Sale mode, currentStore]
                    ├── Store switcher
                    │     ├── Switch store -> reload store data + clear cart
                    │     └── Create new store -> StoreOnboardingScreen
                    ├── Sync badge
                    │     └── SyncCenterSheet -> retry / batch sync / conflict info
                    ├── Overflow menu
                    │     ├── StoreSettingsScreen
                    │     └── Create store -> _StoreFormSheet(mode:create)
                    ├── Product grid
                    │     └── CartBar
                    │           └── CartSheet
                    │                 └── Confirm sale
                    │                       └── SnackBar action -> InvoiceQrScreen
                    └── ModeToggle -> Manage mode
                          ├── RevenueScreen
                          ├── TaxScreen
                          ├── ProductManageScreen
                          │     ├── ProductFormSheet create
                          │     └── ProductFormSheet edit
                          └── InvoiceHistoryScreen
                                ├── PeriodReportSheet -> PDF/CSV share
                                └── InvoiceDetailSheet
                                      ├── InvoiceQrScreen
                                      ├── XML action
                                      │     ├── success -> download/share XML endpoint
                                      │     └── missing info -> StoreSettingsScreen
                                      └── InvoiceIntegrityInfoSheet
```

---

## Responsive Breakpoints

| Width | Layout |
|-------|--------|
| < 360dp | Compact phone, padding 12dp, form fields full column |
| 360-599dp | Standard phone, padding 16dp |
| 600-839dp | Large phone/tablet portrait, max content width 680dp |
| 840-1199dp | Tablet landscape, Manage dùng NavigationRail |
| >= 1200dp | Desktop/web, max content width 1180dp, list-detail cho hóa đơn nếu implement |

Không scale font theo viewport width. Chỉ đổi layout, spacing và số cột.

---

## Copywriting Chuẩn TaxEasy

| Không dùng | Dùng |
|------------|------|
| Submit | Đăng nhập / Xác nhận bán / Lưu thay đổi |
| Error occurred | Không tạo được hóa đơn. Thử lại. |
| Delete product | Ẩn món / Xóa món |
| Sync failed | Chưa đồng bộ được N hóa đơn |
| Amount | Tổng tiền |

Giọng văn ngắn, rõ, không đùa trong lỗi tài chính/thuế. Dấu câu tiền Việt Nam: `150.000đ` hoặc theo `NumberFormat('#,###', 'vi_VN') + 'đ'` tùy chuẩn code hiện tại, nhưng phải thống nhất toàn app.

---

## Consistency Checklist Trước Demo

| Hạng mục | Chuẩn |
|----------|-------|
| Theme | Dùng `ColorScheme` và tokens, không hardcode màu tràn lan |
| Default surface | Màn hình mặc định nền trắng; dashboard nhiều card có thể dùng `#F8FAFC` |
| Gradient | Chỉ auth visual, Sale AppBar accent line, CartBar, hero metric hoặc CTA quan trọng |
| Visual assets | Ảnh/illustration sáng, đúng ngữ cảnh bán hàng; không dùng ảnh tối/blur nặng |
| Input | Filled subtle, radius 14dp, label thật, error inline |
| Button | 1 primary action/màn hình, loading không đổi width |
| Money | Tabular numerals, format Việt Nam, màu success/primary đúng ngữ cảnh |
| Date | `DateFormat('dd/MM/yyyy HH:mm', 'vi_VN')` |
| Product color | Hash tên -> palette ổn định |
| Touch target | Hit area >= 48dp mobile |
| Focus | Focus ring rõ, không bị sticky UI che |
| Text scale | Không overflow ở 1.3x; form/invoice chịu được 1.5x |
| Empty state | Icon 56-64dp + title + body + action nếu hữu ích |
| SnackBar | Màu semantic + message có thể hành động |
| Offline | Badge/sync rõ ở AppBar và invoice row |
| Sync queue | Pending/syncing/synced/failed/duplicate đều có trạng thái nhìn thấy |
| Multi-store | Có nơi tạo thêm quán; đổi quán reload dữ liệu và clear cart |
| Store-scoped stats | Doanh thu, thuế, hóa đơn, sync queue, PDF/CSV đều theo quán đang chọn |
| Store config | Tên quán, loại hình, MST/địa chỉ phục vụ thuế/XML có luồng cập nhật |
| XML readiness | Thiếu trường bắt buộc không xuất XML sai; dẫn về cài đặt quán |
| Report export | Chọn kỳ, preview số liệu, xuất/chia sẻ PDF hoặc CSV từ điện thoại |
| PDF watermark | Báo cáo PDF có watermark `ThueDonGian` opacity 6-8% trên mỗi trang |
| Snapshot integrity | Hóa đơn cũ dùng giá snapshot; không có UI sửa/xóa hóa đơn đã phát sinh |
| Motion | Tôn trọng reduce motion, không gây nhảy layout |
| Vietnamese | `height >= 1.45`, không cắt dấu |

---

## Migration Notes Từ Bản Cũ

| Cũ | 2026 |
|----|------|
| Indigo-violet gần như toàn app | White-first UI, một tông Trust Blue, semantic colors chỉ dùng cho trạng thái |
| Ít visual, nhiều surface phẳng | Thêm ảnh/illustration ở auth, onboarding, empty state và ảnh món nếu có |
| Card shadow nhiều | Card quản lý dùng border/tonal surface, floating action mới có shadow |
| Product tile chỉ đổi màu | Product tile selected có qty badge và stepper rõ hơn |
| Revenue stat cards ngang đơn giản | Bento dashboard với hero metric |
| Tax card chỉ xanh/cam | Thêm trạng thái gần ngưỡng và progress bar |
| Invoice list cơ bản | Thêm status, quick filters, skeleton/loading more |
| Form product thiếu preview | Thêm preview sản phẩm trước khi lưu |
| Thiếu support flows | Thêm Sync Center, Store Settings/Create Store, Period Report PDF/CSV, Snapshot Evidence, Demo helper |

---

## Token Quick Reference

| Token | Value |
|-------|-------|
| `brandPrimary` | `#2563EB` |
| `brandToneLight` | `#EFF6FF` |
| `brandToneSoft` | `#DBEAFE` |
| `brandToneStrong` | `#1D4ED8` |
| `brandGradientEnd` | `#38BDF8` |
| `successMoney` | `#059669` |
| `warningOffline` | `#D97706` |
| `errorUrgent` | `#DC2626` |
| `surfaceBase` | `#FFFFFF` |
| `surfaceSubtle` | `#F8FAFC` |
| `surfaceBlueTint` | `#F5F9FF` |
| `textPrimary` | `#172033` |
| `textSecondary` | `#64748B` |
| `strokeSubtle` | `#D9E2EC` |
| `radiusInput` | `14dp` |
| `radiusCard` | `18dp` |
| `radiusSheet` | `28dp` |
| `pagePaddingPhone` | `16dp` |
| `buttonHeight` | `52dp` |
| `touchTargetMobile` | `48dp` |
