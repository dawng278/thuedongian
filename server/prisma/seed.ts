import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import * as bcrypt from 'bcrypt';

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! });
const prisma = new PrismaClient({ adapter });

/**
 * Sinh số đơn cho 365 ngày gần đây (đủ cho biểu đồ tuần/tháng/năm) với
 * biến động thực tế:
 * - Cuối tuần (T7/CN) đông hơn ~40%
 * - Xu hướng tăng trưởng dần theo tháng (quán làm ăn khấm khá lên)
 * - Mùa vụ: cao điểm cuối năm (T11–T12), thấp điểm giữa năm
 * - Vài ngày spike (lễ/KM) và ngày ế gần đây để 7-ngày cũng rõ nhịp
 * Deterministic (không random) để seed lặp lại giống nhau.
 *
 * @param basePerDay số đơn nền/ngày ở thời điểm hiện tại
 * @param days số ngày sinh (mặc định 365)
 */
function genDailyOrders(
  basePerDay: number,
  days = 365,
): Array<{ daysAgo: number; count: number }> {
  const today = new Date();
  const out: Array<{ daysAgo: number; count: number }> = [];
  for (let daysAgo = days - 1; daysAgo >= 0; daysAgo--) {
    const d = new Date(
      today.getFullYear(),
      today.getMonth(),
      today.getDate() - daysAgo,
    );
    const dow = d.getDay(); // 0=CN, 6=T7
    const weekendBoost = dow === 0 || dow === 6 ? 1.4 : 1;
    // Tăng trưởng: cách đây 1 năm ~60% so với hiện tại, tăng dần tới nay.
    const growth = 0.6 + 0.4 * ((days - daysAgo) / days);
    // Mùa vụ theo tháng: T12 cao nhất (+30%), T6 thấp nhất (−15%).
    const month = d.getMonth(); // 0=T1
    const seasonal = 1 + 0.22 * Math.sin(((month - 5) / 12) * 2 * Math.PI);
    // Sóng ngắn theo ngày để đường biểu đồ gợn tự nhiên.
    const wave = 1 + 0.18 * Math.sin(daysAgo / 2.5);
    let count = Math.round(basePerDay * weekendBoost * growth * seasonal * wave);
    // Điểm nhấn gần đây (cho biểu đồ 7 ngày / 30 ngày).
    if (daysAgo === 12 || daysAgo === 5) count = Math.round(count * 1.8); // spike
    if (daysAgo === 18 || daysAgo === 8) count = Math.round(count * 0.4); // ế
    out.push({ daysAgo, count: Math.max(1, count) });
  }
  return out;
}

type ProductSeed = {
  id: string;
  name: string;
  price: number;
  cost_price?: number; // giá vốn — để tính lợi nhuận
  stock?: number; // tồn kho — null nếu không theo dõi
  unit: string;
  category: string;
  image_url?: string;
};

type StoreSeed = {
  id: string;
  name: string;
  tax_id: string;
  address: string;
  phone: string;
  business_type: 'goods' | 'food_beverage' | 'services';
  products: ProductSeed[];
  // Số đơn mỗi ngày trong N ngày gần đây (daysAgo: 0 = hôm nay)
  dailyOrders: Array<{ daysAgo: number; count: number }>;
};

// ── Quán của tài khoản demo chính (owner@taxeasy.vn) ──────────────────────
const demoStores: StoreSeed[] = [
  {
    // Chuỗi Mì Cay Seoul — menu thực tế, lượng khách ổn định để demo AI đủ nét
    id: 'store-demo-seoul',
    name: 'Mì Cay Seoul',
    tax_id: '0109990001',
    address: '23 Nguyễn Văn Cừ, Quận 5, TP.HCM',
    phone: '0901234567',
    business_type: 'food_beverage',
    products: [
      // ── Mì cay (mặn hàng đầu) ──────────────────────────────────────────
      {
        id: 'seoul-p01',
        name: 'Mì cay cấp độ 1',
        price: 59000,
        cost_price: 28000,
        unit: 'tô',
        category: 'Mì cay',
        image_url:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=640&q=80',
      },
      {
        id: 'seoul-p02',
        name: 'Mì cay cấp độ 3',
        price: 65000,
        cost_price: 31000,
        unit: 'tô',
        category: 'Mì cay',
        image_url:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=640&q=80',
      },
      {
        id: 'seoul-p03',
        name: 'Mì cay cấp độ 5',
        price: 69000,
        cost_price: 33000,
        unit: 'tô',
        category: 'Mì cay',
        image_url:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=640&q=80',
      },
      {
        id: 'seoul-p04',
        name: 'Mì cay cấp độ 7',
        price: 75000,
        cost_price: 36000,
        unit: 'tô',
        category: 'Mì cay',
        image_url:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=640&q=80',
      },
      {
        id: 'seoul-p05',
        name: 'Mì cay cấp độ 9 (thách thức)',
        price: 85000,
        cost_price: 40000,
        unit: 'tô',
        category: 'Mì cay',
        image_url:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=640&q=80',
      },
      // ── Topping / thêm ──────────────────────────────────────────────────
      {
        id: 'seoul-p06',
        name: 'Thêm trứng gà lòng đào',
        price: 10000,
        cost_price: 4000,
        unit: 'quả',
        category: 'Topping',
        image_url:
          'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=640&q=80',
      },
      {
        id: 'seoul-p07',
        name: 'Thêm phô mai que',
        price: 15000,
        cost_price: 7000,
        unit: 'cái',
        category: 'Topping',
        image_url:
          'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=640&q=80',
      },
      {
        id: 'seoul-p08',
        name: 'Thêm mì (sợi)',
        price: 10000,
        cost_price: 3500,
        unit: 'phần',
        category: 'Topping',
        image_url:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=640&q=80',
      },
      // ── Khai vị / ăn kèm ────────────────────────────────────────────────
      {
        id: 'seoul-p09',
        name: 'Bánh tteokbokki chiên',
        price: 39000,
        cost_price: 18000,
        unit: 'đĩa',
        category: 'Ăn kèm',
        image_url:
          'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=640&q=80',
      },
      {
        id: 'seoul-p10',
        name: 'Gà chiên Hàn Quốc',
        price: 75000,
        cost_price: 40000,
        unit: 'phần',
        category: 'Ăn kèm',
        image_url:
          'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=640&q=80',
      },
      {
        id: 'seoul-p11',
        name: 'Kimbap cuộn rong biển',
        price: 45000,
        cost_price: 22000,
        unit: 'đĩa',
        category: 'Ăn kèm',
        image_url:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=640&q=80',
      },
      {
        id: 'seoul-p12',
        name: 'Kimchi tươi',
        price: 25000,
        cost_price: 10000,
        unit: 'đĩa',
        category: 'Ăn kèm',
        image_url:
          'https://images.unsplash.com/photo-1583187832534-e82e0e832cce?w=640&q=80',
      },
      // ── Đồ uống ─────────────────────────────────────────────────────────
      {
        id: 'seoul-p13',
        name: 'Soju đào Chum Churum',
        price: 89000,
        cost_price: 52000,
        unit: 'chai',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1608270586620-248524c67de9?w=640&q=80',
      },
      {
        id: 'seoul-p14',
        name: 'Nước suối lạnh',
        price: 10000,
        cost_price: 4000,
        unit: 'chai',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=640&q=80',
      },
      {
        id: 'seoul-p15',
        name: 'Trà barley Hàn Quốc',
        price: 15000,
        cost_price: 5000,
        unit: 'ly',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=640&q=80',
      },
    ],
    // ~40 đơn/ngày → doanh thu tháng ≈ 80–100tr → gần ngưỡng 200tr/năm, đủ
    // để AI hiện cảnh báo thuế, top-product, low-stock, insight đa dạng.
    dailyOrders: genDailyOrders(40),
  },
  {
    id: 'store-demo-cafe',
    name: 'Cafe Sáng',
    tax_id: '0109990002',
    address: '12 Nguyễn Trãi, Thanh Xuân, Hà Nội',
    phone: '0912345678',
    business_type: 'food_beverage',
    products: [
      {
        id: 'cafe-p01',
        name: 'Cà phê đen đá',
        price: 25000,
        unit: 'ly',
        category: 'Cà phê',
        image_url:
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=640&q=80',
      },
      {
        id: 'cafe-p02',
        name: 'Cà phê sữa đá',
        price: 30000,
        unit: 'ly',
        category: 'Cà phê',
        image_url:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=640&q=80',
      },
      {
        id: 'cafe-p03',
        name: 'Bạc xỉu',
        price: 35000,
        unit: 'ly',
        category: 'Cà phê',
        image_url:
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=640&q=80',
      },
      {
        id: 'cafe-p04',
        name: 'Trà đào cam sả',
        price: 42000,
        unit: 'ly',
        category: 'Trà',
        image_url:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=640&q=80',
      },
      {
        id: 'cafe-p05',
        name: 'Matcha latte',
        price: 48000,
        unit: 'ly',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=640&q=80',
      },
      {
        id: 'cafe-p06',
        name: 'Croissant bơ',
        price: 38000,
        unit: 'cái',
        category: 'Bánh',
        image_url:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=640&q=80',
      },
    ],
    dailyOrders: genDailyOrders(20),
  },
  {
    id: 'store-demo-goods',
    name: 'Tạp Hóa Minh Anh',
    tax_id: '0109990003',
    address: '88 Lê Lợi, Hà Đông, Hà Nội',
    phone: '0987654321',
    business_type: 'goods',
    products: [
      {
        id: 'goods-p01',
        name: 'Nước suối 500ml',
        price: 7000,
        unit: 'chai',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=640&q=80',
      },
      {
        id: 'goods-p02',
        name: 'Mì gói bò',
        price: 5000,
        unit: 'gói',
        category: 'Thực phẩm',
        image_url:
          'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=640&q=80',
      },
      {
        id: 'goods-p03',
        name: 'Sữa tươi 180ml',
        price: 9000,
        unit: 'hộp',
        category: 'Sữa',
        image_url:
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=640&q=80',
      },
      {
        id: 'goods-p04',
        name: 'Bánh quy bơ',
        price: 28000,
        unit: 'hộp',
        category: 'Bánh kẹo',
        image_url:
          'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=640&q=80',
      },
      {
        id: 'goods-p05',
        name: 'Nước rửa chén',
        price: 32000,
        unit: 'chai',
        category: 'Gia dụng',
        image_url:
          'https://images.unsplash.com/photo-1585814226773-e8f67e2ae0f2?w=640&q=80',
      },
      {
        id: 'goods-p06',
        name: 'Khăn giấy',
        price: 18000,
        unit: 'gói',
        category: 'Gia dụng',
        image_url:
          'https://images.unsplash.com/photo-1583845112203-29329902332e?w=640&q=80',
      },
    ],
    // Quán nhỏ — doanh thu năm dưới ngưỡng 100tr → demo trạng thái MIỄN thuế.
    dailyOrders: genDailyOrders(5),
  },
  {
    id: 'store-demo-bun',
    name: 'Bún Đậu Mắm Tôm Cô Ba',
    tax_id: '0109990004',
    address: '17 Kim Mã, Ba Đình, Hà Nội',
    phone: '0903456789',
    business_type: 'food_beverage',
    products: [
      {
        id: 'bun-p01',
        name: 'Bún đậu mắm tôm',
        price: 65000,
        cost_price: 38000,
        unit: 'suất',
        category: 'Món chính',
        image_url:
          'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=640&q=80',
      },
      {
        id: 'bun-p02',
        name: 'Nem chua rán',
        price: 45000,
        cost_price: 25000,
        unit: 'đĩa',
        category: 'Khai vị',
        image_url:
          'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=640&q=80',
      },
      {
        id: 'bun-p03',
        name: 'Chả cốm',
        price: 50000,
        cost_price: 28000,
        unit: 'đĩa',
        category: 'Khai vị',
        image_url:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=640&q=80',
      },
      {
        id: 'bun-p04',
        name: 'Nộm đu đủ',
        price: 40000,
        cost_price: 20000,
        unit: 'đĩa',
        category: 'Khai vị',
        image_url:
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=640&q=80',
      },
      {
        id: 'bun-p05',
        name: 'Trà chanh',
        price: 20000,
        cost_price: 8000,
        unit: 'ly',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=640&q=80',
      },
    ],
    dailyOrders: genDailyOrders(18),
  },
  {
    id: 'store-demo-com',
    name: 'Cơm Văn Phòng Dì Tám',
    tax_id: '0109990005',
    address: '33 Đinh Lễ, Hoàn Kiếm, Hà Nội',
    phone: '0921122334',
    business_type: 'food_beverage',
    products: [
      {
        id: 'com-p01',
        name: 'Cơm thịt kho trứng',
        price: 45000,
        cost_price: 26000,
        unit: 'suất',
        category: 'Cơm',
        image_url:
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=640&q=80',
      },
      {
        id: 'com-p02',
        name: 'Cơm gà xối mỡ',
        price: 55000,
        cost_price: 33000,
        unit: 'suất',
        category: 'Cơm',
        image_url:
          'https://images.unsplash.com/photo-1567982047351-76b6f93e38ee?w=640&q=80',
      },
      {
        id: 'com-p03',
        name: 'Cơm tấm sườn bì',
        price: 60000,
        cost_price: 36000,
        unit: 'suất',
        category: 'Cơm',
        image_url:
          'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=640&q=80',
      },
      {
        id: 'com-p04',
        name: 'Canh cải nấu tôm',
        price: 20000,
        cost_price: 10000,
        unit: 'tô',
        category: 'Canh',
        image_url:
          'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=640&q=80',
      },
      {
        id: 'com-p05',
        name: 'Nước suối',
        price: 7000,
        cost_price: 3500,
        unit: 'chai',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=640&q=80',
      },
      {
        id: 'com-p06',
        name: 'Trà đá tự do',
        price: 5000,
        cost_price: 1000,
        unit: 'ly',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=640&q=80',
      },
    ],
    // Cơm văn phòng — đông khách trưa, base cao để doanh thu tháng > 8.5tr → vượt 100tr/năm
    dailyOrders: genDailyOrders(30),
  },
];

// ── Quán của tài khoản demo thứ 2 (manager@taxeasy.vn) — có 2 quán ──────────
const managerStores: StoreSeed[] = [
  {
    id: 'store-mgr-bbq',
    name: 'Nướng & Lẩu 88',
    tax_id: '0201880001',
    address: '22 Trần Duy Hưng, Cầu Giấy, Hà Nội',
    phone: '0933111222',
    business_type: 'food_beverage',
    products: [
      {
        id: 'bbq-p01',
        name: 'Thịt nướng BBQ',
        price: 85000,
        cost_price: 52000,
        unit: 'phần',
        category: 'Nướng',
        image_url:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=640&q=80',
      },
      {
        id: 'bbq-p02',
        name: 'Mực nướng sa tế',
        price: 95000,
        cost_price: 60000,
        unit: 'phần',
        category: 'Nướng',
        image_url:
          'https://images.unsplash.com/photo-1559847844-5315695dadae?w=640&q=80',
      },
      {
        id: 'bbq-p03',
        name: 'Lẩu thái hải sản',
        price: 250000,
        cost_price: 160000,
        unit: 'nồi',
        category: 'Lẩu',
        image_url:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=640&q=80',
      },
      {
        id: 'bbq-p04',
        name: 'Lẩu bò nhúng dấm',
        price: 220000,
        cost_price: 140000,
        unit: 'nồi',
        category: 'Lẩu',
        image_url:
          'https://images.unsplash.com/photo-1526318896980-cf78c088247c?w=640&q=80',
      },
      {
        id: 'bbq-p05',
        name: 'Rau cuốn thập cẩm',
        price: 45000,
        cost_price: 25000,
        unit: 'đĩa',
        category: 'Khai vị',
        image_url:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=640&q=80',
      },
      {
        id: 'bbq-p06',
        name: 'Bia Tiger lon',
        price: 30000,
        cost_price: 18000,
        unit: 'lon',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1608270586620-248524c67de9?w=640&q=80',
      },
      {
        id: 'bbq-p07',
        name: 'Nước ngọt Coke',
        price: 20000,
        cost_price: 10000,
        unit: 'lon',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1541658016709-82535e94bc69?w=640&q=80',
      },
    ],
    dailyOrders: genDailyOrders(8),
  },
  {
    id: 'store-mgr-banhmi',
    name: 'Bánh Mì Thịt Nướng Lan',
    tax_id: '0201880002',
    address: '5 Hoàng Hoa Thám, Ba Đình, Hà Nội',
    phone: '0944333444',
    business_type: 'food_beverage',
    products: [
      {
        id: 'bmi-p01',
        name: 'Bánh mì thịt nướng',
        price: 30000,
        cost_price: 16000,
        unit: 'ổ',
        category: 'Bánh mì',
        image_url:
          'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=640&q=80',
      },
      {
        id: 'bmi-p02',
        name: 'Bánh mì gà xé',
        price: 28000,
        cost_price: 15000,
        unit: 'ổ',
        category: 'Bánh mì',
        image_url:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=640&q=80',
      },
      {
        id: 'bmi-p03',
        name: 'Bánh mì pa tê trứng',
        price: 22000,
        cost_price: 10000,
        unit: 'ổ',
        category: 'Bánh mì',
        image_url:
          'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=640&q=80',
      },
      {
        id: 'bmi-p04',
        name: 'Xôi gà lá dứa',
        price: 35000,
        cost_price: 20000,
        unit: 'hộp',
        category: 'Xôi',
        image_url:
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=640&q=80',
      },
      {
        id: 'bmi-p05',
        name: 'Trà sữa trân châu',
        price: 38000,
        cost_price: 18000,
        unit: 'ly',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1558857563-b371033873b8?w=640&q=80',
      },
      {
        id: 'bmi-p06',
        name: 'Nước cam ép',
        price: 25000,
        cost_price: 12000,
        unit: 'ly',
        category: 'Đồ uống',
        image_url:
          'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=640&q=80',
      },
    ],
    // Quán bánh mì đông khách sáng sớm — base cao hơn
    dailyOrders: genDailyOrders(35),
  },
];

async function seedStore(ownerId: string, storeDef: StoreSeed) {
  const store = await prisma.store.upsert({
    where: { id: storeDef.id },
    update: {
      owner_id: ownerId,
      name: storeDef.name,
      tax_id: storeDef.tax_id,
      address: storeDef.address,
      phone: storeDef.phone,
      business_type: storeDef.business_type,
    },
    create: {
      id: storeDef.id,
      owner_id: ownerId,
      name: storeDef.name,
      tax_id: storeDef.tax_id,
      address: storeDef.address,
      phone: storeDef.phone,
      business_type: storeDef.business_type,
    },
  });

  for (const product of storeDef.products) {
    // Giá vốn mặc định ≈ 65% giá bán nếu không khai báo (để có lợi nhuận demo).
    const costPrice =
      product.cost_price ?? Math.round((product.price * 0.65) / 1000) * 1000;
    // Tồn kho mặc định cho hàng hóa; quán ăn/dịch vụ thường không theo dõi kho.
    const stock =
      product.stock ??
      (storeDef.business_type === 'goods' ? 50 : undefined) ??
      null;
    await prisma.product.upsert({
      where: { id: product.id },
      update: {
        store_id: store.id,
        name: product.name,
        price: product.price,
        cost_price: costPrice,
        stock,
        unit: product.unit,
        category: product.category,
        image_url: product.image_url ?? null,
        is_active: true,
      },
      create: {
        id: product.id,
        store_id: store.id,
        name: product.name,
        price: product.price,
        cost_price: costPrice,
        stock,
        unit: product.unit,
        category: product.category,
        image_url: product.image_url ?? null,
      },
    });
  }

  const existingCount = await prisma.invoice.count({
    where: { store_id: store.id },
  });
  if (existingCount > 0) {
    console.log(
      `Bỏ qua hóa đơn demo cho ${store.name} (đã có ${existingCount})`,
    );
    return { store, invoiceCount: existingCount };
  }

  let invoiceSeq = 0;
  const now = new Date();

  for (const { daysAgo, count } of storeDef.dailyOrders) {
    for (let orderIndex = 0; orderIndex < count; orderIndex++) {
      invoiceSeq += 1;
      const createdAt = new Date(
        now.getFullYear(),
        now.getMonth(),
        now.getDate() - daysAgo,
        7 + (orderIndex % 12),
        (orderIndex * 7) % 60,
        0,
      );
      const itemCount = (orderIndex % 3) + 1;
      const items = Array.from({ length: itemCount }, (_, itemIndex) => {
        const product =
          storeDef.products[
            (orderIndex + itemIndex * 2) % storeDef.products.length
          ];
        const quantity = ((orderIndex + itemIndex) % 2) + 1;
        return { product, quantity };
      });
      const total = items.reduce(
        (sum, { product, quantity }) => sum + product.price * quantity,
        0,
      );
      // ~70% tiền mặt, ~30% chuyển khoản (thực tế quán VN) — xoay theo index.
      const paymentMethod = invoiceSeq % 10 < 7 ? 'cash' : 'transfer';

      await prisma.invoice.create({
        data: {
          id: `demo-${store.id}-${invoiceSeq.toString().padStart(4, '0')}`,
          store_id: store.id,
          invoice_number: invoiceSeq,
          total_amount: total,
          payment_method: paymentMethod,
          created_at: createdAt,
          synced_at: createdAt,
          items: {
            create: items.map(({ product, quantity }) => ({
              product_id: product.id,
              product_name: product.name,
              price: product.price,
              quantity,
              subtotal: product.price * quantity,
            })),
          },
        },
      });
    }
  }

  console.log(`Đã tạo ${invoiceSeq} hóa đơn demo cho ${store.name}`);
  return { store, invoiceCount: invoiceSeq };
}

async function main() {
  const passwordHash = await bcrypt.hash('password123', 10);

  // Tài khoản 1: chủ quán demo — 5 quán (phở, cafe, tạp hóa, bún đậu, cơm VP)
  const owner = await prisma.user.upsert({
    where: { email: 'owner@taxeasy.vn' },
    update: { password_hash: passwordHash, name: 'Chủ quán Demo' },
    create: {
      email: 'owner@taxeasy.vn',
      password_hash: passwordHash,
      name: 'Chủ quán Demo',
    },
  });

  let totalInvoices = 0;
  for (const storeDef of demoStores) {
    const result = await seedStore(owner.id, storeDef);
    totalInvoices += result.invoiceCount;
  }
  console.log(
    `[1] ${owner.email} | ${demoStores.length} quán | ${totalInvoices} hóa đơn`,
  );

  // Tài khoản 2: người quản lý — 2 quán (nướng lẩu, bánh mì)
  const manager = await prisma.user.upsert({
    where: { email: 'manager@taxeasy.vn' },
    update: { password_hash: passwordHash, name: 'Quản lý Demo' },
    create: {
      email: 'manager@taxeasy.vn',
      password_hash: passwordHash,
      name: 'Quản lý Demo',
    },
  });

  let mgrInvoices = 0;
  for (const storeDef of managerStores) {
    const result = await seedStore(manager.id, storeDef);
    mgrInvoices += result.invoiceCount;
  }
  console.log(
    `[2] ${manager.email} | ${managerStores.length} quán | ${mgrInvoices} hóa đơn`,
  );

  console.log('\nTài khoản demo:');
  console.log('  owner@taxeasy.vn   / password123  (5 quán — Mì Cay Seoul, Cafe Sáng, Tạp Hóa, Bún Đậu, Cơm VP)');
  console.log('  manager@taxeasy.vn / password123  (2 quán — Nướng Lẩu, Bánh Mì)');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
