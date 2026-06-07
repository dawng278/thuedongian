import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const TAX_RATES: Record<
  string,
  { label: string; vat: number; pit: number; exemptThreshold: number }
> = {
  goods: {
    label: 'Hàng hóa',
    vat: 0.01,
    pit: 0.005,
    exemptThreshold: 100_000_000,
  },
  food_beverage: {
    label: 'Ăn uống',
    vat: 0.03,
    pit: 0.015,
    exemptThreshold: 100_000_000,
  },
  services: {
    label: 'Dịch vụ',
    vat: 0.05,
    pit: 0.02,
    exemptThreshold: 100_000_000,
  },
};

@Injectable()
export class ReportsService {
  constructor(private prisma: PrismaService) {}

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

  private buildTaxEstimate(
    store: { business_type: string | null },
    revenue: number,
  ) {
    const businessType = store.business_type ?? 'food_beverage';
    const rates = TAX_RATES[businessType] ?? TAX_RATES.food_beverage;
    const belowThreshold = revenue < rates.exemptThreshold;
    const vatAmount = belowThreshold ? 0 : Math.round(revenue * rates.vat);
    const pitAmount = belowThreshold ? 0 : Math.round(revenue * rates.pit);
    return {
      business_type: businessType,
      business_type_label: rates.label,
      exempt_threshold: rates.exemptThreshold,
      below_threshold: belowThreshold,
      vat_rate: rates.vat,
      pit_rate: rates.pit,
      vat_amount: vatAmount,
      pit_amount: pitAmount,
      total_tax: vatAmount + pitAmount,
      source: 'Thông tư 40/2021/TT-BTC',
    };
  }

  async getRevenue(
    userId: string,
    from?: string,
    to?: string,
    requestedStoreId?: string,
  ) {
    const store = await this.resolveStore(userId, requestedStoreId);

    const now = new Date();
    const todayStart = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate(),
    );
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    const fromDate = from ? new Date(from) : monthStart;
    const toDate = to ? new Date(to + 'T23:59:59') : now;

    const [todayInvoices, monthInvoices, rangeInvoices, topProducts] =
      await Promise.all([
        // Today revenue
        this.prisma.invoice.findMany({
          where: { store_id: store.id, created_at: { gte: todayStart } },
          select: { total_amount: true },
        }),
        // This month revenue
        this.prisma.invoice.findMany({
          where: { store_id: store.id, created_at: { gte: monthStart } },
          select: { total_amount: true, invoice_number: true },
        }),
        // Revenue per day in range (for chart)
        this.prisma.invoice.findMany({
          where: {
            store_id: store.id,
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
              store_id: store.id,
              created_at: { gte: monthStart },
            },
          },
          _sum: { subtotal: true, quantity: true },
          orderBy: { _sum: { subtotal: 'desc' } },
          take: 5,
        }),
      ]);

    const todayRevenue = todayInvoices.reduce(
      (s, i) => s + Number(i.total_amount),
      0,
    );
    const monthRevenue = monthInvoices.reduce(
      (s, i) => s + Number(i.total_amount),
      0,
    );
    const monthInvoiceCount = monthInvoices.length;

    // Group by date for chart
    const dailyMap = new Map<string, number>();
    for (const inv of rangeInvoices) {
      const day = inv.created_at.toISOString().substring(0, 10);
      dailyMap.set(day, (dailyMap.get(day) ?? 0) + Number(inv.total_amount));
    }
    const daily = Array.from(dailyMap.entries()).map(([date, revenue]) => ({
      date,
      revenue,
    }));

    const topItems = topProducts.map((p) => ({
      product_name: p.product_name,
      total_revenue: Number(p._sum.subtotal ?? 0),
      total_quantity: Number(p._sum.quantity ?? 0),
    }));

    return {
      store: {
        id: store.id,
        name: store.name,
        tax_id: store.tax_id,
        address: store.address,
        phone: store.phone,
        business_type: store.business_type,
      },
      today_revenue: todayRevenue,
      month_revenue: monthRevenue,
      month_invoice_count: monthInvoiceCount,
      daily,
      top_products: topItems,
      tax_estimate: this.buildTaxEstimate(store, monthRevenue),
    };
  }

  async getPeriodReport(
    userId: string,
    from: string,
    to: string,
    requestedStoreId?: string,
  ) {
    const store = await this.resolveStore(userId, requestedStoreId);
    const fromDate = new Date(from);
    const toDate = new Date(to + 'T23:59:59');

    const [invoices, topProducts] = await Promise.all([
      this.prisma.invoice.findMany({
        where: {
          store_id: store.id,
          created_at: { gte: fromDate, lte: toDate },
        },
        include: { items: true },
        orderBy: { created_at: 'asc' },
      }),
      this.prisma.invoiceItem.groupBy({
        by: ['product_name'],
        where: {
          invoice: {
            store_id: store.id,
            created_at: { gte: fromDate, lte: toDate },
          },
        },
        _sum: { subtotal: true, quantity: true },
        orderBy: { _sum: { subtotal: 'desc' } },
        take: 10,
      }),
    ]);

    const totalRevenue = invoices.reduce(
      (s, i) => s + Number(i.total_amount),
      0,
    );

    return {
      store: {
        id: store.id,
        name: store.name,
        tax_id: store.tax_id,
        address: store.address,
        phone: store.phone,
        business_type: store.business_type,
      },
      from,
      to,
      total_revenue: totalRevenue,
      invoice_count: invoices.length,
      tax_estimate: this.buildTaxEstimate(store, totalRevenue),
      invoices: invoices.map((inv) => ({
        id: inv.id,
        invoice_number: inv.invoice_number,
        created_at: inv.created_at,
        total_amount: Number(inv.total_amount),
        note: inv.note,
        items: inv.items.map((item) => ({
          product_name: item.product_name,
          quantity: item.quantity,
          price: Number(item.price),
          subtotal: Number(item.subtotal),
        })),
      })),
      top_products: topProducts.map((p) => ({
        product_name: p.product_name,
        total_revenue: Number(p._sum.subtotal ?? 0),
        total_quantity: Number(p._sum.quantity ?? 0),
      })),
    };
  }
}
