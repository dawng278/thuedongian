# TaxEasy — API Contract

> Version: 2.0 · Base URL: `http://localhost:3000`  
> Tất cả request (trừ `/auth/login` và `/auth/register`) cần header: `Authorization: Bearer <access_token>`  
> Tất cả response body dùng JSON. Lỗi trả về `{ "statusCode": number, "message": string }`.

---

## 1. Auth — `/auth`

### POST `/auth/register`
Đăng ký tài khoản mới. Endpoint này **không tạo quán**; sau auth app gọi `GET /stores`, nếu rỗng thì chuyển sang màn hình tạo quán đầu tiên.

**Request:**
```json
{ "email": "owner@example.com", "password": "password123", "name": "Nguyễn Văn A" }
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

**Request:** `{ "email": "...", "password": "..." }`  
**Response 200:** xem trên.  
**Lỗi:** 401.

---

### POST `/auth/refresh`

**Request:** `{ "refresh_token": "eyJ..." }`  
**Response 200:** `{ "access_token": "eyJ...", "refresh_token": "eyJ..." }`

---

## 2. Stores — `/stores`

TaxEasy hỗ trợ mô hình **1 user -> nhiều quán**. Tất cả dữ liệu nghiệp vụ cần được scope theo `store_id` hiện tại.

### GET `/stores`
Danh sách quán thuộc user hiện tại.

**Response 200:** `StoreDto[]`

### POST `/stores`
Tạo quán mới trong app.

**Request:**
```json
{
  "name": "Quán Phở Hà Nội",
  "business_type": "food_beverage",
  "tax_id": "0109990001",
  "address": "45 Phố Huế, Hà Nội",
  "phone": "0901234567"
}
```
**Response 201:** StoreDto.

### GET `/stores/:id`
Chi tiết một quán thuộc user hiện tại.

**Response 200:** StoreDto.

### GET `/stores/me`
Thông tin quán đầu tiên của user hiện tại. Giữ để tương thích cũ; app mới nên dùng `GET /stores`.

**Response 200:**
```json
{
  "id": "uuid",
  "name": "Quán Ăn Ngon",
  "tax_id": "0123456789",
  "address": "45 Phố Huế, Hà Nội",
  "phone": "0901234567",
  "business_type": "food_beverage"
}
```

### PATCH `/stores/me`
Cập nhật quán đầu tiên của user hiện tại. Giữ để tương thích cũ.

**Request:** subset của StoreDto (bất kỳ trường nào trong `name|tax_id|address|phone|business_type`).  
**Response 200:** StoreDto cập nhật.

---

## 3. Products — `/products`

### GET `/products`
Danh sách sản phẩm đang hoạt động.

**Query params:** `?store_id=<uuid>&include_inactive=true` (mặc định chỉ trả `is_active=true`)

**Response 200:**
```json
[
  {
    "id": "uuid",
    "store_id": "uuid",
    "name": "Phở bò tái",
    "price": 55000,
    "unit": "bát",
    "category": "Món chính",
    "image_url": null,
    "is_active": true,
    "created_at": "2026-06-06T00:00:00.000Z",
    "updated_at": "2026-06-06T00:00:00.000Z"
  }
]
```

### POST `/products`
Tạo sản phẩm mới.

**Request:** `{ "store_id"?: "uuid", "name": "...", "price": 55000, "unit"?: "bát", "category"?: "Món chính" }`
Nếu thiếu `store_id`, server dùng quán đầu tiên của user để tương thích cũ.
**Response 201:** ProductDto.

### PUT `/products/:id`
Cập nhật sản phẩm (last-write-wins, xung đột dùng `updated_at`).

**Request:** subset trường cần cập nhật.  
**Response 200:** ProductDto.

### DELETE `/products/:id`
Soft delete (`is_active = false`). Hóa đơn cũ vẫn giữ snapshot giá.

**Response 204.**

---

## 4. Invoices — `/invoices`

### POST `/invoices`
Tạo hóa đơn từ server. **Thường dùng `/sync/invoices` thay thế khi có offline support.**

**Request:**
```json
{
  "id": "uuid-v4-do-client-tao",
  "store_id": "uuid",
  "created_at": "2026-06-06T10:30:00.000Z",
  "note": "bàn 5",
  "items": [
    { "product_id": "uuid", "product_name": "Phở bò tái", "price": 55000, "quantity": 2 }
  ]
}
```
**Response 201:** InvoiceDto (với `invoice_number`, `items`).  
**Lỗi:** 409 nếu UUID đã tồn tại.

### GET `/invoices`
Lịch sử hóa đơn (phân trang).

**Query params:** `?store_id=<uuid>&from=YYYY-MM-DD&to=YYYY-MM-DD&page=1&limit=20`

**Response 200:**
```json
{
  "total": 42,
  "page": 1,
  "limit": 20,
  "data": [ ... InvoiceDto[] ... ]
}
```

### GET `/invoices/:id`
Chi tiết 1 hóa đơn.

**Response 200:** InvoiceDto (kèm `items`).

### GET `/invoices/:id/xml`
Xuất hóa đơn dạng XML theo Thông tư 78/2021/TT-BTC.

**Response 200:** `Content-Type: application/xml`, file XML.  
**Lỗi:** 422 nếu cửa hàng thiếu `name` hoặc `tax_id`.

### PATCH `/invoices/:id`
**405 — hóa đơn không thể sửa sau khi tạo.**

### DELETE `/invoices/:id`
**405 — hóa đơn không thể xóa.**

---

## 5. Sync — `/sync`

### POST `/sync/invoices`
Đẩy hàng đợi offline lên server (batch, idempotent).

**Request:**
```json
{
  "invoices": [
    {
      "id": "uuid-v4",
      "store_id": "uuid",
      "created_at": "2026-06-06T10:30:00.000Z",
      "items": [ ... ]
    }
  ]
}
```
**Response 200:**
```json
{
  "saved": 2,
  "duplicates": 1,
  "results": [
    { "id": "uuid", "status": "saved", "invoice_number": 15 },
    { "id": "uuid2", "status": "duplicate", "invoice_number": 12 }
  ]
}
```

---

## 6. Tax — `/tax`

### GET `/tax/estimate`
Thuế ước tính theo kỳ. Nguồn: **Thông tư 40/2021/TT-BTC**.

**Query params:** `?store_id=<uuid>&period=month|quarter` (mặc định: `month`)

**Response 200:**
```json
{
  "period_label": "Tháng 6/2026",
  "period_start": "2026-06-01",
  "period_end": "2026-06-30",
  "period_revenue": 12000000,
  "annualised_revenue": 144000000,
  "below_threshold": false,
  "exempt_threshold": 100000000,
  "business_type": "food_beverage",
  "business_type_label": "Ăn uống",
  "vat_rate": 0.03,
  "pit_rate": 0.015,
  "vat_amount": 360000,
  "pit_amount": 180000,
  "total_tax": 540000,
  "source": "Thông tư 40/2021/TT-BTC",
  "disclaimer": "Số liệu ước tính tham khảo — không thay thế tư vấn thuế chính thức."
}
```

### GET `/tax/deadlines`
Các mốc hạn kê khai thuế sắp tới.

**Response 200:**
```json
{
  "deadlines": [
    {
      "label": "Kê khai thuế Q2 (2026)",
      "deadline": "2026-07-30",
      "daysLeft": 54,
      "urgent": false
    }
  ]
}
```

---

## 7. Reports — `/reports`

### GET `/reports/revenue`
Doanh thu tổng quan + biểu đồ theo ngày.

**Query params:** `?store_id=<uuid>&from=YYYY-MM-DD&to=YYYY-MM-DD`

**Response 200:**
```json
{
  "store": { "id": "uuid", "name": "Quán Phở Hà Nội", "business_type": "food_beverage" },
  "today_revenue": 1500000,
  "month_revenue": 18000000,
  "month_invoice_count": 120,
  "tax_estimate": {
    "business_type": "food_beverage",
    "vat_amount": 540000,
    "pit_amount": 270000,
    "total_tax": 810000
  },
  "daily": [
    { "date": "2026-06-01", "revenue": 2400000 }
  ],
  "top_products": [
    { "product_name": "Phở bò tái", "total_revenue": 5500000, "total_quantity": 100 }
  ]
}
```

### GET `/reports/period`
Tổng hợp doanh thu kỳ (dùng cho xuất báo cáo).

**Query params:** `?store_id=<uuid>&from=YYYY-MM-DD&to=YYYY-MM-DD` (bắt buộc)

**Response 200:**
```json
{
  "store": {
    "id": "uuid",
    "name": "Quán Phở Hà Nội",
    "tax_id": "0109990001",
    "address": "45 Phố Huế, Hà Nội",
    "phone": "0901234567",
    "business_type": "food_beverage"
  },
  "from": "2026-06-01",
  "to": "2026-06-30",
  "total_revenue": 18000000,
  "invoice_count": 120,
  "tax_estimate": {
    "business_type": "food_beverage",
    "vat_rate": 0.03,
    "pit_rate": 0.015,
    "vat_amount": 540000,
    "pit_amount": 270000,
    "total_tax": 810000
  },
  "invoices": [ ... InvoiceDto[] ... ],
  "top_products": [ ... ]
}
```

### GET `/reports/period/xml`
Xuất báo cáo kỳ dưới dạng XML phù hợp với yêu cầu báo cáo thuế.

**Query params:** `?store_id=<uuid>&from=YYYY-MM-DD&to=YYYY-MM-DD` (bắt buộc)

**Response 200:** `Content-Type: application/xml; charset=utf-8`, file XML.

**Lỗi:** 422 nếu cửa hàng thiếu `tax_id`.

---

## DTOs

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
{
  id: string;
  name: string;
  tax_id?: string;
  address?: string;
  phone?: string;
  business_type?: 'goods' | 'food_beverage' | 'services';
}
```

### ProductDto
```typescript
{
  id: string;
  store_id: string;
  name: string;
  price: number;
  unit?: string;
  category?: string;
  image_url?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}
```

### InvoiceDto
```typescript
{
  id: string;            // UUID sinh ở client
  store_id: string;
  invoice_number: number;
  total_amount: number;
  note?: string;
  created_at: string;    // ISO 8601
  synced_at?: string;
  items: InvoiceItemDto[];
}
```

### InvoiceItemDto
```typescript
{
  id: string;
  product_id?: string;
  product_name: string;  // snapshot — bất biến
  price: number;         // snapshot — bất biến
  quantity: number;
  subtotal: number;
}
```

### CreateInvoiceDto
```typescript
{
  id: string;            // UUID v4 do client tạo
  store_id: string;
  created_at: string;    // ISO 8601
  note?: string;
  items: {
    product_id?: string;
    product_name: string;
    price: number;
    quantity: number;
  }[];
}
```

---

## Quy tắc quan trọng

| Quy tắc | Mô tả |
|---|---|
| UUID client-side | `INVOICE.id` = UUID v4 sinh ở client — chống trùng khi sync offline |
| Store context | Products, invoices, reports, tax, sync phải có `store_id` hiện tại để không lẫn dữ liệu giữa các quán |
| Snapshot bất biến | `InvoiceItem.product_name` + `price` không thay đổi dù sản phẩm bị xóa/sửa giá |
| Soft delete | Xóa sản phẩm = `is_active=false`, không xóa thật |
| Hóa đơn bất biến | PATCH/DELETE `/invoices/:id` → 405 |
| Idempotency | POST `/sync/invoices` cùng UUID → `duplicate`, không lỗi |
| Tax disclaimer | Số liệu thuế là ước tính tham khảo — nguồn TT 40/2021/TT-BTC |
