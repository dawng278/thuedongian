import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateInvoiceDto } from './dto/create-invoice.dto';

@Injectable()
export class InvoicesService {
  constructor(private prisma: PrismaService) {}

  private async getStoreId(userId: string): Promise<string> {
    const store = await this.prisma.store.findFirst({ where: { owner_id: userId } });
    if (!store) throw new NotFoundException('Không tìm thấy cửa hàng');
    return store.id;
  }

  async create(userId: string, dto: CreateInvoiceDto) {
    const storeId = await this.getStoreId(userId);

    // Check for duplicate client UUID
    const existing = await this.prisma.invoice.findUnique({ where: { id: dto.id } });
    if (existing) throw new ConflictException('Hóa đơn đã tồn tại');

    // Sequential invoice number per store
    const count = await this.prisma.invoice.count({ where: { store_id: storeId } });
    const invoiceNumber = count + 1;

    const totalAmount = dto.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    const createdAt = dto.created_at ? new Date(dto.created_at) : new Date();

    return this.prisma.invoice.create({
      data: {
        id: dto.id,
        store_id: storeId,
        invoice_number: invoiceNumber,
        total_amount: totalAmount,
        note: dto.note ?? null,
        created_at: createdAt,
        synced_at: new Date(),
        items: {
          create: dto.items.map((item) => ({
            product_id: item.product_id ?? null,
            product_name: item.product_name,
            price: item.price,
            quantity: item.quantity,
            subtotal: item.price * item.quantity,
          })),
        },
      },
      include: { items: true },
    });
  }

  async findAll(userId: string, from?: string, to?: string, page = 1, limit = 20) {
    const storeId = await this.getStoreId(userId);

    const where = {
      store_id: storeId,
      ...(from || to
        ? {
            created_at: {
              ...(from ? { gte: new Date(from) } : {}),
              ...(to ? { lte: new Date(to + 'T23:59:59') } : {}),
            },
          }
        : {}),
    };

    const [total, data] = await Promise.all([
      this.prisma.invoice.count({ where }),
      this.prisma.invoice.findMany({
        where,
        include: { items: true },
        orderBy: { created_at: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
    ]);

    return { total, page, limit, data };
  }

  async findOne(userId: string, id: string) {
    const storeId = await this.getStoreId(userId);
    const invoice = await this.prisma.invoice.findUnique({
      where: { id },
      include: { items: true },
    });
    if (!invoice || invoice.store_id !== storeId) {
      throw new NotFoundException('Không tìm thấy hóa đơn');
    }
    return invoice;
  }
}
