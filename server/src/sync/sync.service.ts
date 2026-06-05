import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SyncInvoicesDto } from './dto/sync-invoices.dto';

@Injectable()
export class SyncService {
  constructor(private prisma: PrismaService) {}

  async syncInvoices(userId: string, dto: SyncInvoicesDto) {
    const store = await this.prisma.store.findFirst({ where: { owner_id: userId } });
    if (!store) throw new NotFoundException('Không tìm thấy cửa hàng');

    const results: Array<{
      id: string;
      status: 'saved' | 'duplicate';
      invoice_number?: number;
    }> = [];

    for (const inv of dto.invoices) {
      const existing = await this.prisma.invoice.findUnique({ where: { id: inv.id } });

      if (existing) {
        results.push({ id: inv.id, status: 'duplicate', invoice_number: existing.invoice_number });
        continue;
      }

      const count = await this.prisma.invoice.count({ where: { store_id: store.id } });
      const invoiceNumber = count + 1;
      const totalAmount = inv.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
      const createdAt = inv.created_at ? new Date(inv.created_at) : new Date();

      const saved = await this.prisma.invoice.create({
        data: {
          id: inv.id,
          store_id: store.id,
          invoice_number: invoiceNumber,
          total_amount: totalAmount,
          note: inv.note ?? null,
          created_at: createdAt,
          synced_at: new Date(),
          items: {
            create: inv.items.map((item) => ({
              product_id: item.product_id ?? null,
              product_name: item.product_name,
              price: item.price,
              quantity: item.quantity,
              subtotal: item.price * item.quantity,
            })),
          },
        },
      });

      results.push({ id: inv.id, status: 'saved', invoice_number: saved.invoice_number });
    }

    const saved = results.filter((r) => r.status === 'saved').length;
    const duplicates = results.filter((r) => r.status === 'duplicate').length;

    return { saved, duplicates, results };
  }
}
