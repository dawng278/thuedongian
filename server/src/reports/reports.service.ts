import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ReportsService {
  constructor(private prisma: PrismaService) {}

  private async getStoreId(userId: string): Promise<string> {
    const store = await this.prisma.store.findFirst({ where: { owner_id: userId } });
    if (!store) throw new NotFoundException('Không tìm thấy cửa hàng');
    return store.id;
  }

  async getRevenue(userId: string, from?: string, to?: string) {
    const storeId = await this.getStoreId(userId);

    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    const fromDate = from ? new Date(from) : monthStart;
    const toDate = to ? new Date(to + 'T23:59:59') : now;

    const [todayInvoices, monthInvoices, rangeInvoices, topProducts] = await Promise.all([
      // Today revenue
      this.prisma.invoice.findMany({
        where: { store_id: storeId, created_at: { gte: todayStart } },
        select: { total_amount: true },
      }),
      // This month revenue
      this.prisma.invoice.findMany({
        where: { store_id: storeId, created_at: { gte: monthStart } },
        select: { total_amount: true, invoice_number: true },
      }),
      // Revenue per day in range (for chart)
      this.prisma.invoice.findMany({
        where: {
          store_id: storeId,
          created_at: { gte: fromDate, lte: toDate },
        },
        select: { total_amount: true, created_at: true },
        orderBy: { created_at: 'asc' },
      }),
      // Top selling products by revenue (from invoice items)
      this.prisma.invoiceItem.groupBy({
        by: ['product_name'],
        where: {
          invoice: {
            store_id: storeId,
            created_at: { gte: monthStart },
          },
        },
        _sum: { subtotal: true, quantity: true },
        orderBy: { _sum: { subtotal: 'desc' } },
        take: 5,
      }),
    ]);

    const todayRevenue = todayInvoices.reduce((s, i) => s + Number(i.total_amount), 0);
    const monthRevenue = monthInvoices.reduce((s, i) => s + Number(i.total_amount), 0);
    const monthInvoiceCount = monthInvoices.length;

    // Group by date for chart
    const dailyMap = new Map<string, number>();
    for (const inv of rangeInvoices) {
      const day = inv.created_at.toISOString().substring(0, 10);
      dailyMap.set(day, (dailyMap.get(day) ?? 0) + Number(inv.total_amount));
    }
    const daily = Array.from(dailyMap.entries()).map(([date, revenue]) => ({ date, revenue }));

    const topItems = topProducts.map((p) => ({
      product_name: p.product_name,
      total_revenue: Number(p._sum.subtotal ?? 0),
      total_quantity: Number(p._sum.quantity ?? 0),
    }));

    return {
      today_revenue: todayRevenue,
      month_revenue: monthRevenue,
      month_invoice_count: monthInvoiceCount,
      daily,
      top_products: topItems,
    };
  }
}
