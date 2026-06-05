# TaxEasy — API Contract

> Version: 1.0 · Base URL: `http://localhost:3000`  
> Tất cả request (trừ `/auth/login` và `/auth/register`) cần header: `Authorization: Bearer <access_token>`  
> Tất cả response body dùng JSON. Lỗi trả về `{ "statusCode": number, "message": string }`.

---

## 1. Auth — `/auth`

### POST `/auth/register`
Đăng ký tài khoản mới.

**Request:**
```json
{
  "email": "owner@example.com",
  "password": "password123",
  "name": "Nguyễn Văn A"
}
```
**Response 201:**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": { "id": "uuid", "email": "owner@example.com", "name": "Nguyễn Văn A" }
}
```
**Lỗi:** 409 email đã tồn tại.

---

### POST `/auth/login`
Đăng nhập.

**Request:**
```json
{ "email": "owner@example.com", "password": "password123" }
```
**Response 200:**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": { "id": "uuid", "email": "owner@example.com", "name": "Nguyễn Văn A" }
}
```
**Lỗi:** 401 sai credentials.

---

### POST `/auth/refresh`
Làm mới access token.

**Request:**
```json
{ "refresh_token": "eyJ..." }
```
**Response 200:**
```json
{ "access_token": "eyJ...", "refresh_token": "eyJ..." }
```
**Lỗi:** 401 refresh token hết hạn/invalid.

---

## 2. Stores — `/stores`

### GET `/stores/me`
Lấy thông tin cửa hàng của user đang đăng nhập.

**Response 200:**
```json
{
  "id": "uuid",
  "name": "Quán Ăn Demo",
  "tax_id": "0123456789",
  "address": "123 Đường Láng, Hà Nội",
  "phone": "0901234567"
}
```

---

### PATCH `/stores/me`
Cập nhật thông tin cửa hàng.

**Request (partial):**
```json
{
  "name": "Tên mới",
  "tax_id": "0123456789",
  "address": "Địa chỉ mới",
  "phone": "0901234567"
}
```
**Response 200:** Trả về store đã cập nhật (cùng cấu trúc GET).

---

## 3. Products — `/products`

### GET `/products`
Lấy danh sách sản phẩm đang hoạt động của cửa hàng.

**Query params:** `?include_inactive=true` (tùy chọn, lấy cả sản phẩm đã ẩn)

**Response 200:**
```json
[
  {
    "id": "uuid",
    "name": "Phở bò tái",
    "price": 50000,
    "unit": "bát",
    "is_active": true,
    "updated_at": "2026-06-07T00:00:00.000Z"
  }
]
```

---

### POST `/products`
Thêm sản phẩm mới.

**Request:**
```json
{
  "name": "Phở bò tái",
  "price": 50000,
  "unit": "bát"
}
```
**Response 201:** Trả về product vừa tạo.  
**Lỗi:** 400 thiếu name/price.

---

### PATCH `/products/:id`
Sửa thông tin sản phẩm.

**Request (partial):**
```json
{ "price": 55000 }
```
**Response 200:** Trả về product đã cập nhật.  
**Lỗi:** 404 không tìm thấy.

---

### DELETE `/products/:id`
Soft delete — set `is_active = false`.

**Response 200:** `{ "success": true }`  
**Lỗi:** 404 không tìm thấy.

---

## 4. Invoices — `/invoices`

### POST `/invoices`
Tạo hóa đơn. **id sinh ở CLIENT** (UUID v4).

**Request:**
```json
{
  "id": "client-generated-uuid",
  "created_at": "2026-06-07T10:30:00.000Z",
  "note": "Bàn 5",
  "items": [
    {
      "product_id": "uuid-or-null",
      "product_name": "Phở bò tái",
      "price": 50000,
      "quantity": 2
    }
  ]
}
```
**Response 201:**
```json
{
  "id": "client-generated-uuid",
  "total_amount": 100000,
  "created_at": "2026-06-07T10:30:00.000Z",
  "synced_at": "2026-06-07T10:30:01.000Z",
  "items": [ /* ... */ ]
}
```
**Lỗi:** 409 id đã tồn tại (duplicate sync).

---

### GET `/invoices`
Lấy lịch sử hóa đơn.

**Query params:**
- `?from=2026-06-01` (ISO date)
- `?to=2026-06-07`
- `?page=1&limit=20`

**Response 200:**
```json
{
  "data": [
    {
      "id": "uuid",
      "total_amount": 100000,
      "note": "Bàn 5",
      "created_at": "2026-06-07T10:30:00.000Z",
      "items_count": 2
    }
  ],
  "total": 42,
  "page": 1,
  "limit": 20
}
```

---

### GET `/invoices/:id`
Lấy chi tiết một hóa đơn.

**Response 200:**
```json
{
  "id": "uuid",
  "total_amount": 100000,
  "note": "Bàn 5",
  "created_at": "2026-06-07T10:30:00.000Z",
  "items": [
    {
      "id": "uuid",
      "product_id": "uuid-or-null",
      "product_name": "Phở bò tái",
      "price": 50000,
      "quantity": 2,
      "subtotal": 100000
    }
  ]
}
```
**Lỗi:** 404 không tìm thấy.

---

## 5. Sync — `/sync`

### POST `/sync/invoices`
Đẩy hàng đợi offline (batch). Server bỏ qua id đã tồn tại (idempotent).

**Request:**
```json
{
  "invoices": [
    {
      "id": "uuid1",
      "created_at": "2026-06-07T08:00:00.000Z",
      "note": null,
      "items": [ /* ... */ ]
    },
    {
      "id": "uuid2",
      "created_at": "2026-06-07T08:05:00.000Z",
      "items": [ /* ... */ ]
    }
  ]
}
```
**Response 200:**
```json
{
  "synced": ["uuid1", "uuid2"],
  "skipped": [],
  "errors": []
}
```

---

## 6. Tax — `/tax`

### GET `/tax/estimate`
Tính thuế ước tính theo tháng.

**Query params:** `?year=2026&month=6`

**Response 200:**
```json
{
  "year": 2026,
  "month": 6,
  "revenue": 15000000,
  "estimated_tax": 750000,
  "rate": 0.05,
  "note": "Thuế khoán ước tính 5% doanh thu tháng"
}
```

---

### GET `/tax/deadlines`
Nhắc hạn nộp thuế.

**Response 200:**
```json
[
  {
    "title": "Thuế môn bài năm 2026",
    "due_date": "2026-01-30",
    "days_remaining": 0,
    "overdue": true
  },
  {
    "title": "Thuế khoán quý 2/2026",
    "due_date": "2026-07-30",
    "days_remaining": 53,
    "overdue": false
  }
]
```

---

## 7. Reports — `/reports`

### GET `/reports/revenue`
Doanh thu theo ngày/tuần/tháng.

**Query params:** `?period=day|week|month&from=2026-06-01&to=2026-06-07`

**Response 200:**
```json
{
  "period": "day",
  "data": [
    { "date": "2026-06-01", "revenue": 1200000, "invoice_count": 24 },
    { "date": "2026-06-02", "revenue": 980000, "invoice_count": 18 }
  ],
  "total_revenue": 2180000,
  "total_invoices": 42
}
```

---

### GET `/reports/top-products`
Top sản phẩm bán chạy.

**Query params:** `?from=2026-06-01&to=2026-06-07&limit=10`

**Response 200:**
```json
[
  { "product_name": "Phở bò tái", "quantity_sold": 120, "revenue": 6000000 },
  { "product_name": "Trà đá", "quantity_sold": 200, "revenue": 1000000 }
]
```

---

## DTOs dùng chung

### AuthResponseDto
```typescript
{ access_token: string; refresh_token: string; user: UserDto }
```

### UserDto
```typescript
{ id: string; email: string; name: string }
```

### StoreDto
```typescript
{ id: string; name: string; tax_id?: string; address?: string; phone?: string }
```

### ProductDto
```typescript
{ id: string; name: string; price: number; unit?: string; is_active: boolean; updated_at: string }
```

### InvoiceDto
```typescript
{
  id: string;           // UUID sinh ở client
  total_amount: number;
  note?: string;
  created_at: string;   // ISO 8601
  synced_at?: string;
  items?: InvoiceItemDto[];
}
```

### InvoiceItemDto
```typescript
{
  id: string;
  product_id?: string;
  product_name: string; // snapshot — bất biến
  price: number;        // snapshot — bất biến
  quantity: number;
  subtotal: number;
}
```

### CreateInvoiceDto
```typescript
{
  id: string;           // UUID do client tạo (uuid v4)
  created_at: string;
  note?: string;
  items: {
    product_id?: string;
    product_name: string;
    price: number;
    quantity: number;
  }[];
}
```
