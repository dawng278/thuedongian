import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { computeTax } from '../tax/tax-rules';
import { StoresService } from '../stores/stores.service';

@Injectable()
export class ReportsService {
  constructor(
    private prisma: PrismaService,
    private stores: StoresService,
  ) {}

  async getRevenue(
    userId: string,
    from?: string,
    to?: string,
    requestedStoreId?: string,
  ) {
    const store = await this.stores.resolveStore(userId, requestedStoreId);

    const now = new Date();
    const todayStart = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate(),
    );
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    const fromDate = from ? new Date(from) : monthStart;
    const toDate = to ? new Date(to + 'T23:59:59') : now;

    const [
      todayInvoices,
      monthInvoices,
      rangeInvoices,
      topProducts,
      monthItems,
    ] = await Promise.all([
      // Today revenue (kèm phương thức để chốt ca)
      this.prisma.invoice.findMany({
        where: { store_id: store.id, created_at: { gte: todayStart } },
        select: { total_amount: true, payment_method: true },
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
      // Items tháng này kèm giá vốn sản phẩm (để ước tính lợi nhuận)
      this.prisma.invoiceItem.findMany({
        where: {
          invoice: { store_id: store.id, created_at: { gte: monthStart } },
        },
        select: {
          quantity: true,
          subtotal: true,
          product: { select: { cost_price: true } },
        },
      }),
    ]);

    const todayRevenue = todayInvoices.reduce(
      (s, i) => s + Number(i.total_amount),
      0,
    );
    // Chốt ca: tổng theo phương thức thanh toán trong ngày.
    const todayCash = todayInvoices
      .filter((i) => i.payment_method !== 'transfer')
      .reduce((s, i) => s + Number(i.total_amount), 0);
    const todayTransfer = todayInvoices
      .filter((i) => i.payment_method === 'transfer')
      .reduce((s, i) => s + Number(i.total_amount), 0);
    const monthRevenue = monthInvoices.reduce(
      (s, i) => s + Number(i.total_amount),
      0,
    );
    const monthInvoiceCount = monthInvoices.length;

    // Lợi nhuận ước tính tháng này = doanh thu - giá vốn (chỉ tính món có giá vốn).
    // hasCost: có ít nhất 1 món khai báo giá vốn thì mới hiển thị lợi nhuận.
    let monthCogs = 0; // giá vốn hàng bán
    let monthRevenueWithCost = 0; // doanh thu của riêng món có giá vốn
    let hasCost = false;
    for (const it of monthItems) {
      const cost = it.product?.cost_price;
      if (cost != null) {
        hasCost = true;
        monthCogs += Number(cost) * it.quantity;
        monthRevenueWithCost += Number(it.subtotal);
      }
    }
    const monthProfit = hasCost ? monthRevenueWithCost - monthCogs : null;

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
      today_cash: todayCash,
      today_transfer: todayTransfer,
      today_invoice_count: todayInvoices.length,
      month_revenue: monthRevenue,
      month_invoice_count: monthInvoiceCount,
      month_profit: monthProfit,
      month_cogs: hasCost ? monthCogs : null,
      daily,
      top_products: topItems,
      // Doanh thu 1 tháng → computeTax tự quy đổi cả năm để so ngưỡng miễn thuế.
      tax_estimate: computeTax(store.business_type, monthRevenue, 1),
    };
  }

  /**
   * Dữ liệu biểu đồ doanh thu theo mốc thời gian.
   * - week: 7 ngày gần nhất, mỗi cột 1 ngày
   * - month: 30 ngày gần nhất, mỗi cột 1 ngày
   * - year: 12 tháng gần nhất, mỗi cột 1 tháng
   * Trả về đủ các mốc kể cả mốc doanh thu = 0 để biểu đồ liền mạch.
   */
  async getChart(userId: string, granularity: string, storeId?: string) {
    const store = await this.stores.resolveStore(userId, storeId);
    const now = new Date();

    if (granularity === 'year') {
      const start = new Date(now.getFullYear(), now.getMonth() - 11, 1);
      const invoices = await this.prisma.invoice.findMany({
        where: { store_id: store.id, created_at: { gte: start } },
        select: { total_amount: true, created_at: true },
      });
      // Khởi tạo 12 tháng = 0
      const buckets = new Map<string, number>();
      const labels: string[] = [];
      for (let i = 0; i < 12; i++) {
        const d = new Date(now.getFullYear(), now.getMonth() - 11 + i, 1);
        const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
        buckets.set(key, 0);
        labels.push(`T${d.getMonth() + 1}`);
      }
      for (const inv of invoices) {
        const d = inv.created_at;
        const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
        if (buckets.has(key)) {
          buckets.set(key, buckets.get(key)! + Number(inv.total_amount));
        }
      }
      const points = Array.from(buckets.entries()).map(([key, revenue], i) => ({
        label: labels[i],
        key,
        revenue,
      }));
      return { granularity, points };
    }

    // week / month: gom theo ngày
    const days = granularity === 'month' ? 30 : 7;
    const start = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate() - (days - 1),
    );
    const invoices = await this.prisma.invoice.findMany({
      where: { store_id: store.id, created_at: { gte: start } },
      select: { total_amount: true, created_at: true },
    });
    const buckets = new Map<string, number>();
    const labels: string[] = [];
    for (let i = 0; i < days; i++) {
      const d = new Date(
        now.getFullYear(),
        now.getMonth(),
        now.getDate() - (days - 1) + i,
      );
      const key = d.toISOString().substring(0, 10);
      buckets.set(key, 0);
      labels.push(`${d.getDate()}/${d.getMonth() + 1}`);
    }
    for (const inv of invoices) {
      const key = inv.created_at.toISOString().substring(0, 10);
      if (buckets.has(key)) {
        buckets.set(key, buckets.get(key)! + Number(inv.total_amount));
      }
    }
    const points = Array.from(buckets.entries()).map(([key, revenue], i) => ({
      label: labels[i],
      key,
      revenue,
    }));
    return { granularity, points };
  }

  async getPeriodReport(
    userId: string,
    from: string,
    to: string,
    requestedStoreId?: string,
  ) {
    const store = await this.stores.resolveStore(userId, requestedStoreId);
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

    // Số tháng của kỳ báo cáo (tối thiểu 1) để quy đổi doanh thu cả năm.
    const days = Math.max(
      1,
      (toDate.getTime() - fromDate.getTime()) / 86_400_000,
    );
    const monthsInPeriod = Math.max(1, days / 30);

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
      tax_estimate: computeTax(
        store.business_type,
        totalRevenue,
        monthsInPeriod,
      ),
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
