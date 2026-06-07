import {
  Injectable,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateInvoiceDto } from './dto/create-invoice.dto';
import { InvoiceXmlService } from './invoice-xml.service';
import { createInvoiceAtomic } from './create-invoice-atomic';
import { StoresService } from '../stores/stores.service';

@Injectable()
export class InvoicesService {
  constructor(
    private prisma: PrismaService,
    private xmlService: InvoiceXmlService,
    private stores: StoresService,
  ) {}

  private serializeInvoice(invoice: any) {
    return {
      ...invoice,
      total_amount: Number(invoice.total_amount),
      items: invoice.items?.map((item: any) => ({
        ...item,
        price: Number(item.price),
        subtotal: Number(item.subtotal),
      })),
    };
  }

  async create(userId: string, dto: CreateInvoiceDto) {
    const store = await this.stores.resolveStore(userId, dto.store_id);

    // Check for duplicate client UUID
    const existing = await this.prisma.invoice.findUnique({
      where: { id: dto.id },
    });
    if (existing) throw new ConflictException('Hóa đơn đã tồn tại');

    const created = await createInvoiceAtomic(this.prisma, {
      id: dto.id,
      storeId: store.id,
      items: dto.items,
      note: dto.note ?? null,
      paymentMethod: dto.payment_method,
      createdAt: dto.created_at ? new Date(dto.created_at) : new Date(),
    });
    return this.serializeInvoice(created);
  }

  async findAll(
    userId: string,
    from?: string,
    to?: string,
    page = 1,
    limit = 20,
    requestedStoreId?: string,
  ) {
    const store = await this.stores.resolveStore(userId, requestedStoreId);

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

    return { total, page, limit, data: data.map((inv) => this.serializeInvoice(inv)) };
  }

  async findOne(userId: string, id: string) {
    const invoice = await this.prisma.invoice.findUnique({
      where: { id },
      include: { items: true, store: true },
    });
    if (!invoice || invoice.store.owner_id !== userId) {
      throw new NotFoundException('Không tìm thấy hóa đơn');
    }
    return this.serializeInvoice(invoice);
  }

  async exportXml(userId: string, id: string): Promise<string> {
    const invoice = await this.prisma.invoice.findUnique({
      where: { id },
      include: { items: { include: { product: true } }, store: true },
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
      businessType: invoice.store.business_type,
      createdAt: invoice.created_at,
      items: invoice.items.map((item) => ({
        productName: item.product_name,
        unit: item.product?.unit ?? null,
        quantity: item.quantity,
        price: Number(item.price),
        subtotal: Number(item.subtotal),
      })),
      totalAmount: Number(invoice.total_amount),
      note: invoice.note,
    });
  }
}
