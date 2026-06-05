import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import * as bcrypt from 'bcrypt';

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! });
const prisma = new PrismaClient({ adapter });

async function main() {
  const passwordHash = await bcrypt.hash('password123', 10);

  const user = await prisma.user.upsert({
    where: { email: 'owner@taxeasy.vn' },
    update: {},
    create: {
      email: 'owner@taxeasy.vn',
      password_hash: passwordHash,
      name: 'Chủ quán Demo',
    },
  });

  const store = await prisma.store.upsert({
    where: { id: 'store-demo-001' },
    update: { owner_id: user.id },
    create: {
      id: 'store-demo-001',
      owner_id: user.id,
      name: 'Quán Ăn Ngon',
      tax_id: '0123456789',
      address: '45 Phố Huế, Hai Bà Trưng, Hà Nội',
      phone: '0901234567',
      business_type: 'food_beverage',
    },
  });

  const productDefs = [
    { id: 'p01', name: 'Phở bò tái', price: 55000, unit: 'bát', category: 'Món chính' },
    { id: 'p02', name: 'Phở bò chín', price: 55000, unit: 'bát', category: 'Món chính' },
    { id: 'p03', name: 'Phở gà', price: 50000, unit: 'bát', category: 'Món chính' },
    { id: 'p04', name: 'Bún bò Huế', price: 60000, unit: 'bát', category: 'Món chính' },
    { id: 'p05', name: 'Bún riêu cua', price: 50000, unit: 'bát', category: 'Món chính' },
    { id: 'p06', name: 'Cơm sườn cốt lết', price: 65000, unit: 'đĩa', category: 'Cơm' },
    { id: 'p07', name: 'Cơm tấm bì chả', price: 60000, unit: 'đĩa', category: 'Cơm' },
    { id: 'p08', name: 'Bánh mì thịt', price: 25000, unit: 'cái', category: 'Bánh mì' },
    { id: 'p09', name: 'Bánh mì trứng', price: 20000, unit: 'cái', category: 'Bánh mì' },
    { id: 'p10', name: 'Cà phê sữa đá', price: 30000, unit: 'ly', category: 'Đồ uống' },
    { id: 'p11', name: 'Cà phê đen đá', price: 25000, unit: 'ly', category: 'Đồ uống' },
    { id: 'p12', name: 'Trà đá', price: 5000, unit: 'ly', category: 'Đồ uống' },
    { id: 'p13', name: 'Nước cam tươi', price: 35000, unit: 'ly', category: 'Đồ uống' },
    { id: 'p14', name: 'Sinh tố bơ', price: 45000, unit: 'ly', category: 'Đồ uống' },
    { id: 'p15', name: 'Chè thập cẩm', price: 30000, unit: 'chén', category: 'Tráng miệng' },
  ];

  for (const p of productDefs) {
    await prisma.product.upsert({
      where: { id: p.id },
      update: { price: p.price, name: p.name },
      create: {
        id: p.id,
        store_id: store.id,
        name: p.name,
        price: p.price,
        unit: p.unit,
        category: p.category,
      },
    });
  }

  // Create demo invoices for the past 7 days to populate the revenue chart
  const existingCount = await prisma.invoice.count({ where: { store_id: store.id } });
  if (existingCount === 0) {
    let invoiceSeq = 0;
    const now = new Date();

    const dailyOrders = [
      { daysAgo: 6, count: 8 },
      { daysAgo: 5, count: 12 },
      { daysAgo: 4, count: 10 },
      { daysAgo: 3, count: 15 },
      { daysAgo: 2, count: 9 },
      { daysAgo: 1, count: 14 },
      { daysAgo: 0, count: 6 },
    ];

    const randomItems = () => {
      const items = [];
      const picks = Math.floor(Math.random() * 3) + 1;
      const shuffled = [...productDefs].sort(() => Math.random() - 0.5);
      for (let i = 0; i < picks; i++) {
        const qty = Math.floor(Math.random() * 2) + 1;
        items.push({ p: shuffled[i], qty });
      }
      return items;
    };

    for (const { daysAgo, count } of dailyOrders) {
      for (let j = 0; j < count; j++) {
        invoiceSeq++;
        const createdAt = new Date(now.getFullYear(), now.getMonth(), now.getDate() - daysAgo, 8 + j, 0, 0);
        const items = randomItems();
        const total = items.reduce((s, { p, qty }) => s + p.price * qty, 0);

        await prisma.invoice.create({
          data: {
            id: `demo-inv-${invoiceSeq.toString().padStart(4, '0')}`,
            store_id: store.id,
            invoice_number: invoiceSeq,
            total_amount: total,
            created_at: createdAt,
            synced_at: createdAt,
            items: {
              create: items.map(({ p, qty }) => ({
                product_id: p.id,
                product_name: p.name,
                price: p.price,
                quantity: qty,
                subtotal: p.price * qty,
              })),
            },
          },
        });
      }
    }
    console.log(`Đã tạo ${invoiceSeq} hóa đơn demo`);
  } else {
    console.log(`Bỏ qua tạo hóa đơn demo (đã có ${existingCount})`);
  }

  console.log(`Seed xong: ${user.email} | ${store.name} | ${productDefs.length} sản phẩm`);
  console.log('Đăng nhập: owner@taxeasy.vn / password123');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
