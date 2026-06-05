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
    update: {},
    create: {
      id: 'store-demo-001',
      owner_id: user.id,
      name: 'Quán Ăn Demo',
      tax_id: '0123456789',
      address: '123 Đường Láng, Hà Nội',
      phone: '0901234567',
    },
  });

  const products = [
    { name: 'Phở bò tái', price: 50000, unit: 'bát' },
    { name: 'Phở bò chín', price: 50000, unit: 'bát' },
    { name: 'Phở gà', price: 45000, unit: 'bát' },
    { name: 'Bún bò Huế', price: 55000, unit: 'bát' },
    { name: 'Bún riêu', price: 45000, unit: 'bát' },
    { name: 'Bánh mì thịt', price: 25000, unit: 'cái' },
    { name: 'Bánh mì trứng', price: 20000, unit: 'cái' },
    { name: 'Cơm sườn', price: 55000, unit: 'đĩa' },
    { name: 'Cơm tấm bì chả', price: 50000, unit: 'đĩa' },
    { name: 'Trà đá', price: 5000, unit: 'ly' },
    { name: 'Trà chanh', price: 15000, unit: 'ly' },
    { name: 'Cà phê đen', price: 20000, unit: 'ly' },
    { name: 'Cà phê sữa', price: 25000, unit: 'ly' },
    { name: 'Nước cam', price: 30000, unit: 'ly' },
    { name: 'Sinh tố bơ', price: 35000, unit: 'ly' },
  ];

  for (const p of products) {
    await prisma.product.upsert({
      where: { id: `product-${store.id}-${p.name}` },
      update: { price: p.price },
      create: {
        id: `product-${store.id}-${p.name}`,
        store_id: store.id,
        name: p.name,
        price: p.price,
        unit: p.unit,
      },
    });
  }

  console.log(`Seed xong: user=${user.email}, store=${store.name}, products=${products.length}`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
