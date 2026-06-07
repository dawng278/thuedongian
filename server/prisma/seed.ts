import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import * as bcrypt from 'bcrypt';

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! });
const prisma = new PrismaClient({ adapter });

type ProductSeed = {
  id: string;
  name: string;
  price: number;
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
  dailyOrders: Array<{ daysAgo: number; count: number }>;
};

const demoStores: StoreSeed[] = [
  {
    id: 'store-demo-pho',
    name: 'Quán Phở Hà Nội',
    tax_id: '0109990001',
    address: '45 Phố Huế, Hai Bà Trưng, Hà Nội',
    phone: '0901234567',
    business_type: 'food_beverage',
    products: [
      {
        id: 'pho-p01',
        name: 'Phở bò tái',
        price: 55000,
        unit: 'bát',
        category: 'Món chính',
        image_url:
          'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=640&q=80',
      },
      {
        id: 'pho-p02',
        name: 'Phở bò chín',
        price: 55000,
        unit: 'bát',
        category: 'Món chính',
      },
      {
        id: 'pho-p03',
        name: 'Phở gà',
        price: 50000,
        unit: 'bát',
        category: 'Món chính',
      },
      {
        id: 'pho-p04',
        name: 'Bún bò Huế',
        price: 60000,
        unit: 'bát',
        category: 'Món chính',
      },
      {
        id: 'pho-p05',
        name: 'Bún riêu cua',
        price: 50000,
        unit: 'bát',
        category: 'Món chính',
      },
      {
        id: 'pho-p06',
        name: 'Cà phê sữa đá',
        price: 30000,
        unit: 'ly',
        category: 'Đồ uống',
      },
      {
        id: 'pho-p07',
        name: 'Trà đá',
        price: 5000,
        unit: 'ly',
        category: 'Đồ uống',
      },
      {
        id: 'pho-p08',
        name: 'Chè thập cẩm',
        price: 30000,
        unit: 'chén',
        category: 'Tráng miệng',
      },
    ],
    dailyOrders: [
      { daysAgo: 6, count: 8 },
      { daysAgo: 5, count: 12 },
      { daysAgo: 4, count: 10 },
      { daysAgo: 3, count: 15 },
      { daysAgo: 2, count: 9 },
      { daysAgo: 1, count: 14 },
      { daysAgo: 0, count: 7 },
    ],
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
      },
      {
        id: 'cafe-p03',
        name: 'Bạc xỉu',
        price: 35000,
        unit: 'ly',
        category: 'Cà phê',
      },
      {
        id: 'cafe-p04',
        name: 'Trà đào cam sả',
        price: 42000,
        unit: 'ly',
        category: 'Trà',
      },
      {
        id: 'cafe-p05',
        name: 'Matcha latte',
        price: 48000,
        unit: 'ly',
        category: 'Đồ uống',
      },
      {
        id: 'cafe-p06',
        name: 'Croissant bơ',
        price: 38000,
        unit: 'cái',
        category: 'Bánh',
      },
    ],
    dailyOrders: [
      { daysAgo: 6, count: 18 },
      { daysAgo: 5, count: 16 },
      { daysAgo: 4, count: 22 },
      { daysAgo: 3, count: 20 },
      { daysAgo: 2, count: 24 },
      { daysAgo: 1, count: 19 },
      { daysAgo: 0, count: 15 },
    ],
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
      },
      {
        id: 'goods-p02',
        name: 'Mì gói bò',
        price: 5000,
        unit: 'gói',
        category: 'Thực phẩm',
      },
      {
        id: 'goods-p03',
        name: 'Sữa tươi 180ml',
        price: 9000,
        unit: 'hộp',
        category: 'Sữa',
      },
      {
        id: 'goods-p04',
        name: 'Bánh quy bơ',
        price: 28000,
        unit: 'hộp',
        category: 'Bánh kẹo',
      },
      {
        id: 'goods-p05',
        name: 'Nước rửa chén',
        price: 32000,
        unit: 'chai',
        category: 'Gia dụng',
      },
      {
        id: 'goods-p06',
        name: 'Khăn giấy',
        price: 18000,
        unit: 'gói',
        category: 'Gia dụng',
      },
    ],
    dailyOrders: [
      { daysAgo: 6, count: 28 },
      { daysAgo: 5, count: 31 },
      { daysAgo: 4, count: 26 },
      { daysAgo: 3, count: 33 },
      { daysAgo: 2, count: 30 },
      { daysAgo: 1, count: 35 },
      { daysAgo: 0, count: 21 },
    ],
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
    await prisma.product.upsert({
      where: { id: product.id },
      update: {
        store_id: store.id,
        name: product.name,
        price: product.price,
        unit: product.unit,
        category: product.category,
        image_url: product.image_url ?? null,
        is_active: true,
      },
      create: {
        ...product,
        store_id: store.id,
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

      await prisma.invoice.create({
        data: {
          id: `demo-${store.id}-${invoiceSeq.toString().padStart(4, '0')}`,
          store_id: store.id,
          invoice_number: invoiceSeq,
          total_amount: total,
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

  const user = await prisma.user.upsert({
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
    const result = await seedStore(user.id, storeDef);
    totalInvoices += result.invoiceCount;
  }

  console.log(
    `Seed xong: ${user.email} | ${demoStores.length} quán | ${totalInvoices} hóa đơn`,
  );
  console.log('Đăng nhập: owner@taxeasy.vn / password123');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
