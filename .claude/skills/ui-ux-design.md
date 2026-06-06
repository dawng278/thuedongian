---
name: ui-ux-design
description: Bộ kỹ năng thiết kế UI/UX senior — bố cục, màu sắc, typography, icon, ảnh, logo, animation, chuẩn quốc tế + Việt Nam.
---

# UI/UX Senior Design Skill

Khi được gọi, áp dụng toàn bộ tiêu chuẩn sau. Mỗi quyết định thiết kế phải có lý do rõ ràng — không chọn vì "trông đẹp", mà vì nó giải quyết vấn đề người dùng.

---

## 1. Nền tảng tư duy thiết kế

### 1.1 Design Hierarchy — Thứ tự ưu tiên

```
1. Usability   — Người dùng hoàn thành được mục tiêu không?
2. Clarity     — Họ hiểu mình đang ở đâu và làm gì không?
3. Efficiency  — Mất bao nhiêu bước/thời gian để hoàn thành?
4. Delight     — Có khoảnh khắc nào khiến họ hài lòng không?
5. Aesthetics  — Nhìn có đẹp không? (ưu tiên CUỐI CÙNG)
```

Senior designer không bắt đầu từ "màu gì đẹp" — họ bắt đầu từ "người dùng cần làm gì".

### 1.2 Nielsen Norman — 10 Heuristics

| # | Heuristic | Áp dụng thực tế |
|---|-----------|----------------|
| 1 | Visibility of system status | Spinner, SnackBar kết quả, Badge pending sync |
| 2 | Match real world | "Tính tiền" không phải "Submit"; "Ẩn" không phải "Delete" |
| 3 | User control & freedom | Nút back, "Xóa tất cả" cart, undo soft delete |
| 4 | Consistency & standards | Cùng gradient trên AppBar, Login, CartBar |
| 5 | Error prevention | Validate inline trước submit, không cho giá âm |
| 6 | Recognition over recall | Icon + label, không chỉ icon đơn thuần |
| 7 | Flexibility & efficiency | Chạm 1 lần thêm món (không cần confirm) |
| 8 | Aesthetic & minimalist | Mỗi màn hình chỉ 1 hành động chính nổi bật |
| 9 | Help recognize/recover errors | SnackBar đỏ + message cụ thể + nút "Thử lại" |
| 10 | Help & documentation | Hint text trong input, tooltip trên icon không rõ |

### 1.3 Gestalt Principles trong layout

```
Proximity   → Nhóm fields liên quan, khoảng cách giữa groups > trong group
Similarity  → Cùng loại element dùng cùng style (tất cả stat cards đồng nhất)
Continuity  → Mắt người đi theo đường thẳng → dùng column/list, tránh zig-zag
Figure/Ground → Nội dung chính nổi lên, nền mờ xuống (floating CartBar)
Closure     → Avatar chữ tròn → não tự hiểu là "ảnh sản phẩm"
Prägnanz    → Đơn giản nhất mà vẫn truyền đủ thông tin
```

---

## 2. Bố cục & Sắp xếp (Layout & Composition)

### 2.1 Quy tắc vàng bố cục

**Rule of Thirds** — Chia màn hình thành lưới 3×3. Đặt điểm nhấn tại giao điểm (không phải giữa màn hình).

**Visual Weight** — Mỗi element có "trọng lượng thị giác":
```
Nặng nhất → màu đậm, kích thước lớn, tương phản cao, hình phức tạp
Nhẹ nhất  → màu nhạt, kích thước nhỏ, tương phản thấp, hình đơn giản

Quy tắc: Một góc/vùng có visual weight nặng phải được balance bởi
nhiều element nhẹ hơn ở góc/vùng đối diện.
```

**F-Pattern & Z-Pattern**:
```
F-Pattern → Người đọc text dài (danh sách, settings)
            → Đặt thông tin quan trọng ở đầu dòng bên trái
Z-Pattern → Màn hình có ít text, nhiều visual (login, landing)
            → Đặt logo trái trên, CTA phải dưới, eye flow theo Z
```

### 2.2 8pt Grid System (bắt buộc)

```
Mọi spacing phải là bội số của 4. Ưu tiên bội số 8:

4dp  — gap nội bộ nhỏ (icon ↔ text trong row)
8dp  — gap giữa elements trong group
12dp — padding nội card nhỏ
16dp — horizontal page margin (CHUẨN)
20dp — spacing giữa sections
24dp — padding lớn, form section
32dp — khoảng cách lớn giữa blocks
48dp — safe zone dưới floating element

SAI: 10px, 7px, 15px, 13px, 22px
ĐÚNG: 8px, 8px, 16px, 12px, 20px, 24px
```

### 2.3 Content Hierarchy trong một màn hình

```
Mỗi màn hình có đúng 1 Primary Action (màu primary, lớn nhất)
                    ≤ 2 Secondary Actions (outlined/text button)
                    N Tertiary Actions (ẩn trong menu/overflow)

Ví dụ Sale Screen:
  Primary:   CartBar "Tính tiền" (gradient, floating)
  Secondary: Nút QR trong SnackBar sau khi bán
  Tertiary:  Logout trong PopupMenu
```

### 2.4 Whitespace — Senior Rule

Senior designer dùng whitespace chủ động, không phải "khoảng trống thừa":

```
Macro whitespace: khoảng cách giữa sections (≥ 24dp) → giúp scan nhanh
Micro whitespace: padding trong component (8–16dp) → giúp đọc dễ
Active whitespace: vùng trống có chủ đích → thu hút mắt vào content

Dấu hiệu layout tệ:
✗ Mọi thứ chen chúc, không có breathing room
✗ Padding đều nhau cho mọi thứ (không phân cấp)
✗ Text chạm sát cạnh container
```

### 2.5 Responsive Grid

```dart
// Tự động co giãn theo màn hình — không hardcode số cột:
SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 180,   // 2 cột trên 360dp, 3 cột trên 540dp+
  childAspectRatio: 0.85,
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
)

// Breakpoints:
// < 360dp  (cũ/nhỏ): 2 cột, giảm padding xuống 12dp
// 360–599dp (phone):  2 cột, padding 16dp
// 600–839dp (tablet): 3 cột, padding 24dp, max-width 600dp
// ≥ 840dp  (desktop): 4 cột, centered layout
```

### 2.6 Safe Areas & System UI

```dart
// Luôn handle safe area — đặc biệt gradient không có AppBar che:
SafeArea(
  bottom: false, // cho phép content scroll dưới home indicator
  child: ...
)

// Floating elements cần bottom padding:
EdgeInsets.only(
  bottom: MediaQuery.of(context).padding.bottom + 14,
)

// Keyboard overlap — padding bottom khi keyboard hiện:
EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16)
```

---

## 3. Màu sắc (Color System)

### 3.1 Color Theory — Nguyên tắc nền tảng

**60-30-10 Rule** (quy tắc vàng):
```
60% → Màu nền (neutral: white, surface, surfaceVariant)
30% → Màu phụ (secondary, containers, accents)
10% → Màu nhấn (primary/brand color cho CTA, highlights)

Nếu primary color xuất hiện > 30% màn hình → bão hòa thị giác,
mất tác dụng nhấn mạnh.
```

**Temperature & Weight**:
```
Ấm (đỏ, cam, vàng) → năng động, gấp gáp, kêu gọi hành động
Lạnh (xanh lam, tím, indigo) → tin cậy, bình tĩnh, chuyên nghiệp
Trung tính (xám, trắng, đen) → nền, không gây phân tâm
```

### 3.2 Material Design 3 — Color Roles

```dart
// Seed color → tạo toàn bộ color scheme tự động (bao gồm dark mode):
ColorScheme.fromSeed(seedColor: Color(0xFF4F46E5))

// Roles quan trọng và cách dùng:
primary            → nút CTA chính, icon active, tab indicator
onPrimary          → text/icon ĐẶT TRÊN primary
primaryContainer   → background nhẹ có liên quan primary (chip, tile selected)
onPrimaryContainer → text/icon đặt trên primaryContainer
secondary          → accent phụ, tag, badge
surface            → nền card, bottom sheet, page
surfaceVariant     → nền phân biệt nhẹ (input filled)
onSurface          → text chính trên surface
onSurfaceVariant   → text phụ, caption, hint
outline            → border nhẹ, divider
outlineVariant     → border rất nhẹ (grid line trong chart)
error              → lỗi, input validation
errorContainer     → background cảnh báo
```

### 3.3 Brand Color

```
Primary:      #4F46E5  (Indigo 600)  — trust, modern fintech
Secondary:    #7C3AED  (Violet 700)  — creativity, premium
Gradient:     #4F46E5 → #7C3AED  (135° diagonal)

Dùng gradient trên: AppBar sale mode, CartBar, Login header,
                     Register header, nút CTA Hero
Dùng solid primary: icon active, tab indicator, link text
```

### 3.4 Semantic Color Palette

```
Success / Money:   #059669  Emerald 600  → giá, doanh thu, "thành công"
Warning / Offline: #D97706  Amber 600    → offline, hạn sắp đến, chú ý
Error / Danger:    #DC2626  Red 600      → lỗi, nguy hiểm, delete
Info / Neutral:    #2563EB  Blue 600     → thông tin, tooltip
Tax OK:            #16A34A  Green 600    → dưới ngưỡng thuế
Tax Alert:         #EA580C  Orange 600   → trên ngưỡng thuế
```

### 3.5 WCAG 2.1 AA — Contrast (bắt buộc)

```
Text thường (< 18sp regular, < 14sp bold): tối thiểu 4.5:1
Text lớn (≥ 18sp regular, ≥ 14sp bold):   tối thiểu 3:1
Non-text UI (icon, border, chart):         tối thiểu 3:1
AAA target cho text quan trọng:            7:1+

Thực tế TaxEasy:
✅ White trên #4F46E5:            7.1:1  (AAA)
✅ #1E293B trên white:            16.1:1 (AAA)
✅ #059669 trên white:            4.6:1  (AA)
❌ #9CA3AF (gray-400) trên white: 2.9:1  (FAIL)
```

### 3.6 Màu sắc trong văn hóa Việt Nam

```
Đỏ   → May mắn, tài lộc (tích cực — khác phương Tây dùng cho nguy hiểm)
       Dùng cho: accent festive, badge hot sale, highlight quan trọng
Vàng → Phú quý, thành công, premium
       Dùng cho: coin/reward, tier premium, số thuế thấp (tốt)
Xanh lá → Tiền bạc, phát triển, sinh sôi
          Dùng cho: giá tiền, doanh thu, số tích cực
Tím/Indigo → Hiện đại, tin cậy, sáng tạo
             (Momo dùng tím → người dùng VN đã quen tím = fintech)
Trắng → Sạch sẽ, chuyên nghiệp, trung tính
        Nền chính — chiếm ≥ 60% diện tích màn hình
```

### 3.7 Dark Mode Color Rules

```dart
// KHÔNG hardcode màu trắng/đen cho text và nền:
❌ color: Colors.white
❌ color: Color(0xFFF8FAFC)  // trông chói trong dark mode
✅ color: Theme.of(context).colorScheme.onSurface
✅ color: Theme.of(context).colorScheme.surface

// Ngoại lệ hợp lệ (hardcode gradient brand):
const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)])

// Shadow trong dark mode: giảm opacity:
BoxShadow(
  color: Color(0xFF4F46E5).withValues(alpha: isDark ? 0.2 : 0.45),
)

// Border thay elevation trong dark mode:
Border.all(color: colorScheme.outlineVariant)
```

---

## 4. Typography — Chữ

### 4.1 Font Selection — Cách chọn font đúng

**Tiêu chí chọn font:**
```
1. Legibility   — Đọc được ở size nhỏ trên màn hình mobile
2. Unicode VN   — Hỗ trợ đầy đủ dấu tiếng Việt (ắ, ề, ụ, ữ...)
3. Weight range — Có đủ Regular/Medium/SemiBold/Bold
4. Hinting      — Rendering tốt trên màn hình thấp DPI
5. License      — Free to use (Google Fonts cho commercial)
```

**Font phù hợp cho app tài chính Việt:**
```
Roboto        — Android default, render sắc nét, hỗ trợ VN tốt
Be Vietnam Pro — Google Fonts, thiết kế riêng cho tiếng Việt, weights 100–900
Inter         — Chuẩn fintech quốc tế, legibility cao
Nunito        — Rounded, thân thiện, phù hợp tone "dễ dùng"
SF Pro        — iOS default (không import được, dùng khi target iOS)
```

**Font KHÔNG dùng:**
```
❌ Times New Roman / Serif — khó đọc trên màn hình nhỏ
❌ Comic Sans — không chuyên nghiệp
❌ Handwritten fonts — không legible ở small size
❌ Font chỉ có 2–3 weight — không đủ visual hierarchy
```

### 4.2 Material 3 Type Scale

```
headlineMedium: 28sp — "TaxEasy" trên login
headlineSmall:  24sp — "Đăng nhập" form header, modal title
titleLarge:     22sp — AppBar title, bottom sheet header
titleMedium:    16sp — section label, stat value
titleSmall:     14sp — card title phụ
bodyLarge:      16sp — nội dung chính
bodyMedium:     14sp — nội dung phụ, subtitle, list item
bodySmall:      12sp — meta, caption, timestamp
labelLarge:     14sp — button text
labelMedium:    12sp — chip, badge, tag
labelSmall:     11sp — tooltip, footnote
```

### 4.3 Vietnamese Typography Rules

```
Line height cho text tiếng Việt: ≥ 1.5
→ TextStyle(height: 1.5)
→ KHÔNG dùng height: 1.2 (dấu hỏi, ngã bị cắt)

Letter spacing:
→ Display/Headline: +0.5 đến +1.0
→ Body: 0 (mặc định)
→ Button/Label: +0.3 đến +0.5
→ ALL CAPS: +1.0 đến +1.5 bắt buộc

Case convention:
→ "TaxEasy", "Quán Phở Hà Nội" — Title Case
→ KHÔNG viết hoa toàn bộ tên cửa hàng
→ Nút: "Đăng nhập", "Thêm sản phẩm" — Sentence case
```

### 4.4 Font Weight trong Visual Hierarchy

```
700 Bold     — Hero number, tổng tiền, tên app
600 SemiBold — Tên sản phẩm, section header, button text
500 Medium   — AppBar title, card title, label active
400 Regular  — Body text, nội dung thông thường

Quy tắc: Không dùng quá 3 weight khác nhau trên 1 màn hình
→ Gây "font chaos", mất hierarchy rõ ràng
```

---

## 5. Icon Selection — Chọn icon

### 5.1 Nguyên tắc chọn icon senior

```
Universality  — Icon phải được hiểu ở mọi văn hóa
Literalness   — Icon là metaphor trực tiếp
               ✅ Envelope = email, House = home
               ❌ Lightning bolt cho "Refresh" — không tự nhiên
Consistency   — Cùng icon style trong toàn app
Size clarity  — Vẫn nhận ra ở 16dp
```

**Icon Styles — Material Icons:**
```
Outlined  — Nhẹ nhàng, modern → dùng cho inactive state / navigation
Filled    — Nặng hơn → dùng cho active state / primary action
Rounded   — Thân thiện → phù hợp app consumer-facing
Sharp     — Công ty, enterprise, formal

TaxEasy dùng: Outlined cho inactive, Filled cho active
```

### 5.2 Icon Size Standards

```
16dp — trong text, inline, chip/badge
20dp — icon nhỏ trong subtitle
24dp — DEFAULT — navigation, AppBar action, button icon
32dp — section header icon
48dp — empty state icon
64dp — large empty state, feature highlight
```

### 5.3 Touch Target

```
Icon có thể chỉ 20dp nhưng touch area PHẢI là 48×48dp:

IconButton(
  iconSize: 20,
  constraints: BoxConstraints(minWidth: 48, minHeight: 48),
  padding: EdgeInsets.all(14),
  icon: Icon(Icons.close_outlined),
)
```

### 5.4 Khi nào dùng chỉ icon (không label)?

```
CHỈ ICON khi:
✅ Universal convention (search, back, close, home)
✅ Không gian quá chật
✅ Có tooltip khi long-press

PHẢI THÊM LABEL khi:
❌ Icon không rõ trong context (analytics? settings?)
❌ Bottom navigation
❌ Empty state / onboarding action
```

### 5.5 Icon Mistakes thường gặp

```
❌ Hamburger menu (≡) cho mobile (2024+) — dùng bottom nav thay
❌ Floppy disk (💾) cho "Lưu" — người trẻ VN không hiểu
❌ Mix nhiều icon library (Material + FontAwesome + custom)
❌ Icon không có Semantics.label
✅ Khi không chắc — thêm text label bên cạnh
```

---

## 6. Hình ảnh (Image Selection & Usage)

### 6.1 Nguyên tắc chọn ảnh

```
Authenticity  — Ảnh thật > illustration > stock photo generic
Relevance     — Ảnh phải bổ sung nghĩa, không chỉ "làm đẹp"
Composition   — Subject chính không bị che bởi text overlay
Tone matching — Màu ảnh không xung đột với brand colors
```

### 6.2 Product Images trong app bán hàng

```
Không có ảnh thật → Colored letter avatar (TaxEasy hiện tại):
- Hash tên sản phẩm → màu nhất quán (cùng tên = cùng màu)
- 8 màu trong palette đa dạng, đủ tương phản

Khi có ảnh thật:
- Aspect ratio cố định 1:1 cho product tile
- Object-fit: cover (không distort)
- Placeholder: shimmer animation khi loading
- Error fallback: quay về letter avatar
- Lazy loading: chỉ load ảnh visible

Image(
  image: NetworkImage(product.imageUrl),
  fit: BoxFit.cover,
  errorBuilder: (_, __, ___) => _LetterAvatar(product.name),
)
```

### 6.3 Illustration — Khi nào dùng?

```
✅ Empty states ("Chưa có hóa đơn nào")
✅ Onboarding screens
✅ Error pages (no connection)
✅ Success states đặc biệt (hóa đơn đầu tiên)

Style: nhất quán với brand, clean (không cartoonish)
Nguồn: unDraw.co (flat, color customizable), Humaaans
```

### 6.4 Image Optimization

```
Format: WebP > PNG > JPEG
Kích thước: tối đa 2× screen density (400px cho tile 200dp @2x)
Package: cached_network_image
```

---

## 7. Logo & Branding

### 7.1 5 Yếu tố Logo Tốt

```
1. Simple      — Nhận ra ở 16px favicon lẫn billboard
2. Memorable   — Một đặc điểm nổi bật (màu, shape, negative space)
3. Timeless    — Tránh trend ngắn hạn
4. Versatile   — Works on light/dark, color/monochrome, small/large
5. Appropriate — Phù hợp ngành (fintech: clean, trustworthy, modern)
```

### 7.2 TaxEasy Logo System

```
Primary logo:  Icon receipt + wordmark "TaxEasy" (ngang)
Icon only:     Rounded square indigo (#4F46E5) + white receipt icon
               → dùng làm app icon, favicon, avatar
Wordmark:      "TaxEasy" — Be Vietnam Pro Bold / Inter Bold

Sizes:
App icon:      1024×1024px (adaptive icon: safe zone 66%)
In-app:        48×48dp icon + 36sp wordmark
Notification:  24×24dp icon
```

### 7.3 Logo Usage Rules

```
✅ Logo trên nền trắng/nhạt: dùng màu gốc
✅ Logo trên nền tối/gradient: dùng white version
❌ Không stretch/squish tỷ lệ
❌ Không đặt logo trên ảnh busy
❌ Không thêm shadow vào wordmark
❌ Không dùng font khác cho wordmark
Minimum clear space: 1× chiều cao chữ xung quanh logo
```

### 7.4 App Icon Design

```
Android Adaptive Icon:
- Foreground: 108×108dp, content trong safe zone 66dp center
- Background: solid #4F46E5 hoặc gradient
- Không đặt nội dung sát mép (sẽ bị cắt khi apply mask)

iOS App Icon:
- Không có transparency
- Không có rounded corner (hệ thống tự apply)
- 1024×1024px @1x

Guideline: icon nhận ra được khi shrink xuống 29×29dp
```

---

## 8. Animation & Motion

### 8.1 Motion Philosophy

```
Informative  — Animation giải thích UI thay đổi như thế nào
Focused      — Giữ focus vào task, không phân tâm
Expressive   — Thể hiện personality trong khoảnh khắc chuyển tiếp

Quy tắc vàng: Nếu xóa animation đi mà người dùng vẫn hiểu UI
→ animation đó là decorative, xem xét bỏ.
```

### 8.2 Duration Standards

```
Micro    (100ms)  — Ripple, hover highlight, checkbox toggle
Short    (200ms)  — Fade, scale nhỏ (tooltip appear, badge)
Medium   (300ms)  — Slide, expand/collapse, tab switch ← THƯỜNG DÙNG NHẤT
Long     (400ms)  — Full-screen transition, hero animation, sheet expand
X-Long  (500ms+) — Chỉ cho onboarding, celebration (confetti, success pop)
```

### 8.3 Easing Curves — Chọn đúng loại

```dart
// Xuất hiện (enter) — bắt đầu nhanh, chậm dần:
Curves.easeOut
Curves.fastOutSlowIn   // Material standard

// Biến mất (exit) — bắt đầu chậm, nhanh dần:
Curves.easeIn

// Di chuyển ngang (move):
Curves.easeInOut

// Nhấn mạnh / bounce nhẹ:
Curves.easeOutBack     // overshoot nhẹ — icon active, FAB appear
Curves.elasticOut      // CHỈ cho celebration, không dùng navigation

// Loading indicator, progress bar liên tục:
Curves.linear
```

### 8.4 Micro-interactions Patterns

```dart
// 1. AnimatedContainer — state change:
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  curve: Curves.easeOut,
  decoration: BoxDecoration(
    color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
    borderRadius: BorderRadius.circular(16),
  ),
)

// 2. AnimatedSwitcher — swap widget:
AnimatedSwitcher(
  duration: const Duration(milliseconds: 200),
  child: isLoading
    ? const CircularProgressIndicator(key: ValueKey('loading'))
    : const Icon(Icons.check, key: ValueKey('done')),
)

// 3. ScaleTransition — element xuất hiện:
ScaleTransition(
  scale: CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
  child: Badge(...),
)

// 4. SlideTransition — panel slide vào từ dưới:
SlideTransition(
  position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
    .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
  child: CartBar(),
)
```

### 8.5 Page Transitions

```dart
// Slide + Fade cho màn hình liên quan (list → detail):
PageRouteBuilder(
  transitionDuration: const Duration(milliseconds: 300),
  pageBuilder: (_, animation, __) => DetailScreen(),
  transitionsBuilder: (_, animation, __, child) =>
    FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    ),
)

// Hero animation — element chia sẻ giữa 2 màn hình:
Hero(tag: 'product_${product.id}', child: ProductAvatar())
```

### 8.6 Loading States

```
Skeleton/Shimmer  — Nội dung layout cố định (list, cards dài)
Circular Progress — Thao tác ngắn (< 3s), không biết duration
Linear Progress   — Upload, download (biết progress %)
Lottie Animation  — Onboarding, success celebration
```

### 8.7 Reduce Motion (Accessibility)

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;
final duration = reduceMotion
  ? Duration.zero
  : const Duration(milliseconds: 300);
```

---

## 9. Component Tokens

### 9.1 Border Radius

```
4dp  — chip nhỏ, badge
8dp  — tooltip, disclaimer box
12dp — button, input field
16dp — card (CardThemeData default)
20dp — floating pill (CartBar, ModeToggle)
24dp — bottom sheet corner
32dp — large modal / form overlay trên gradient
```

### 9.2 Elevation & Shadow

```
Material 3: elevation = surface tint (không số cao)

Custom shadow cho floating elements:
BoxShadow(
  color: primaryColor.withValues(alpha: 0.35–0.45),
  blurRadius: 14–18,
  offset: Offset(0, 4–7),
)
```

### 9.3 Buttons

```
FilledButton   → hành động chính (Đăng nhập, Xác nhận bán)
                 Gradient version cho CTA quan trọng nhất
OutlinedButton → hành động phụ (Lọc theo ngày)
TextButton     → navigation, link (Đăng ký, Xem QR)
IconButton     → hành động biểu tượng

Height chuẩn: 48dp; Radius: 12–14dp
1 màn hình = 1 primary button tối đa
```

### 9.4 Input Fields

```
Filled (surfaceContainerHighest) — chuẩn Material 3
Radius: 14dp
Focus: 2dp primary border
Enabled: 1.5dp #E2E8F0
Error: 1.5dp error color
fillColor: Color(0xFFF8FAFC) trên nền trắng
```

---

## 10. Vietnamese UX Standards

### 10.1 Microcopy

```
- Ngắn gọn, dùng "bạn" (không "quý khách")
- Nút = ĐỘNG TỪ + ĐỐI TƯỢNG: "Thêm món", "Xác nhận bán", "Xuất CSV"
- Placeholder: ví dụ thật — "Ví dụ: Quán Phở Hà Nội"
- Error: cụ thể — "Email không đúng định dạng" (không "Lỗi!")
- Empty state: mô tả + hướng dẫn hành động tiếp theo
```

### 10.2 Local UX Patterns

| Pattern | App VN dùng | Áp dụng TaxEasy |
|---------|-------------|-----------------|
| Bottom TabBar | Momo, Zalo, Grab | Tab Quản lý |
| Gradient card | Momo, VNPay | Stat cards, CartBar |
| Bottom sheet detail | Shopee, Lazada | InvoiceDetailSheet |
| Floating CTA gradient | Grab, Gojek | CartBar floating pill |
| Section label accent bar | Zalo | _SectionLabel trong Register |

### 10.3 Số & Ngày theo chuẩn VN

```dart
NumberFormat('#,###', 'vi_VN')           → 1,500,000đ
DateFormat('dd/MM/yyyy HH:mm', 'vi_VN') → 06/06/2026 14:30
DateFormat('dd/MM/yyyy', 'vi_VN')        → 06/06/2026
// Dùng "đ" không phải "VND" hay "₫" trong UI
```

---

## 11. Accessibility Checklist

```
Visual:
☐ Contrast ≥ 4.5:1 cho text thường
☐ Contrast ≥ 3:1 cho text lớn và icons
☐ Không CHỈ dùng màu để truyền thông tin

Motor:
☐ Touch target ≥ 48×48dp
☐ Swipe-to-delete có alternative

Cognitive:
☐ ≤ 7 items trong 1 list/menu (7±2 rule)
☐ Confirmation cho destructive actions
☐ Form có inline validation

Screen reader:
☐ Tất cả IconButton có Semantics(label: ...)
☐ MergeSemantics cho card có nhiều text

Text scaling:
☐ Test ở textScaleFactor: 2.0
☐ Không clamp textScaleFactor < 1.0
```

---

## 12. Design QA — Checklist trước khi ship

```
Layout:
☐ Spacing là bội số của 4
☐ Horizontal margins nhất quán (16dp)
☐ Không text chạm sát cạnh container
☐ maxLines + ellipsis cho text có thể dài

Color:
☐ Không hardcode màu trắng/đen (dùng colorScheme tokens)
☐ Gradient brand nhất quán (#4F46E5 → #7C3AED)
☐ Semantic colors đúng: đỏ = lỗi, xanh = thành công/tiền

Typography:
☐ ≤ 3 font weight trên 1 màn hình
☐ Vietnamese text: height ≥ 1.5
☐ Số tiền: NumberFormat('#,###', 'vi_VN') + 'đ'

Icons:
☐ Cùng style xuyên suốt (outlined)
☐ Touch area ≥ 48dp

States:
☐ Loading, Error, Empty state đều có
☐ Disabled: opacity 0.38

Animation:
☐ Duration ≤ 400ms (trừ celebration)
☐ Easing curve phù hợp
☐ Reduce Motion được handle
```

---

## 13. Tham khảo chuẩn quốc tế

| Tài liệu | Mục đích |
|----------|----------|
| m3.material.io | Material Design 3 — component, token, motion |
| developer.apple.com/design/human-interface-guidelines | iOS HIG |
| w3.org/TR/WCAG21 | Accessibility |
| nngroup.com | UX research, heuristics |
| refactoringui.com | Visual design tactics |
| fonts.google.com/?subset=vietnamese | Font hỗ trợ tiếng Việt |
| webaim.org/resources/contrastchecker | Kiểm tra contrast ratio |
| undraw.co | Illustration (color customizable) |
