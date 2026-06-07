import {
  Injectable,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateInvoiceDto } from './dto/create-invoice.dto';
import { InvoiceXmlService } from './invoice-xml.service';

@Injectable()
export class InvoicesService {
  constructor(
    private prisma: PrismaService,
    private xmlService: InvoiceXmlService,
  ) {}

  private async resolveStore(userId: string, storeId?: string) {
    const store = await this.prisma.store.findFirst({
      where: {
        owner_id: userId,
        ...(storeId ? { id: storeId } : {}),
      },
      orderBy: { created_at: 'asc' },
    });
    if (!store) throw new NotFoundException('Không tìm thấy cửa hàng');
    return store;
  }

  async create(userId: string, dto: CreateInvoiceDto) {
    const store = await this.resolveStore(userId, dto.store_id);

    // Check for duplicate client UUID
    const existing = await this.prisma.invoice.findUnique({
      where: { id: dto.id },
    });
    if (existing) throw new ConflictException('Hóa đơn đã tồn tại');

    // Sequential invoice number per store
    const count = await this.prisma.invoice.count({
      where: { store_id: store.id },
    });
    const invoiceNumber = count + 1;

    const totalAmount = dto.items.reduce(
      (sum, item) => sum + item.price * item.quantity,
      0,
    );
    const createdAt = dto.created_at ? new Date(dto.created_at) : new Date();

    return this.prisma.invoice.create({
      data: {
        id: dto.id,
        store_id: store.id,
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

  async findAll(
    userId: string,
    from?: string,
    to?: string,
    page = 1,
    limit = 20,
    requestedStoreId?: string,
  ) {
    const store = await this.resolveStore(userId, requestedStoreId);

    const where = {
      store_id: store.id,
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
    const invoice = await this.prisma.invoice.findUnique({
      where: { id },
      include: { items: true, store: true },
    });
    if (!invoice || invoice.store.owner_id !== userId) {
      throw new NotFoundException('Không tìm thấy hóa đơn');
    }
    return invoice;
  }

  async exportXml(userId: string, id: string): Promise<string> {
    const invoice = await this.prisma.invoice.findUnique({
      where: { id },
      include: { items: true, store: true },
    });
    if (!invoice || invoice.store.owner_id !== userId) {
      throw new NotFoundException('Không tìm thấy hóa đơn');
    }

    return this.xmlService.buildXml({
      invoiceNumber: invoice.invoice_number,
      storeId: invoice.store.id,
      storeName: invoice.store.name,
      storeTaxId: invoice.store.tax_id,
      storeAddress: invoice.store.address,
      storePhone: invoice.store.phone,
      createdAt: invoice.created_at,
      items: invoice.items.map((item) => ({
        productName: item.product_name,
        quantity: item.quantity,
        price: Number(item.price),
        subtotal: Number(item.subtotal),
      })),
      totalAmount: Number(invoice.total_amount),
      note: invoice.note,
    });
  }
}
