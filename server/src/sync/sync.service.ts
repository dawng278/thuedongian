import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SyncInvoicesDto } from './dto/sync-invoices.dto';
import { createInvoiceAtomic } from '../invoices/create-invoice-atomic';
import { StoresService } from '../stores/stores.service';

@Injectable()
export class SyncService {
  constructor(
    private prisma: PrismaService,
    private stores: StoresService,
  ) {}

  async syncInvoices(userId: string, dto: SyncInvoicesDto) {
    const results: Array<{
      id: string;
      status: 'saved' | 'duplicate';
      invoice_number?: number;
    }> = [];

    for (const inv of dto.invoices) {
      const existing = await this.prisma.invoice.findUnique({
        where: { id: inv.id },
        include: { store: true },
      });

      if (existing) {
        if (existing.store.owner_id !== userId) {
          throw new NotFoundException('Không tìm thấy hóa đơn');
        }
        results.push({
          id: inv.id,
          status: 'duplicate',
          invoice_number: existing.invoice_number,
        });
        continue;
      }

      const store = await this.stores.resolveStore(userId, inv.store_id);
      const saved = await createInvoiceAtomic(this.prisma, {
        id: inv.id,
        storeId: store.id,
        items: inv.items,
        note: inv.note ?? null,
        paymentMethod: inv.payment_method,
        createdAt: inv.created_at ? new Date(inv.created_at) : new Date(),
      });

      results.push({
        id: inv.id,
        status: 'saved',
        invoice_number: saved.invoice_number,
      });
    }

    const saved = results.filter((r) => r.status === 'saved').length;
    const duplicates = results.filter((r) => r.status === 'duplicate').length;

    return { saved, duplicates, results };
  }
}
