import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { StoresService } from '../stores/stores.service';
import { computeTax, EXEMPT_THRESHOLD } from '../tax/tax-rules';
import {
  AiInsight,
  InsightContext,
  runInsightEngine,
} from './insight-engine';

export { AiInsight };

@Injectable()
export class AiService {
  constructor(
    private prisma: PrismaService,
    private stores: StoresService,
  ) {}

  async getInsights(userId: string, storeId?: string): Promise<AiInsight[]> {
    const store = await this.stores.resolveStore(userId, storeId);
    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59);
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const [
      monthInvoices,
      lastMonthInvoices,
      todayCount,
      topProducts,
      lowStockProducts,
      outOfStockProducts,
      totalProducts,
      productsMissingCost,
    ] = await Promise.all([
      this.prisma.invoice.findMany({
        where: { store_id: store.id, created_at: { gte: monthStart } },
        select: { total_amount: true },
      }),
      this.prisma.invoice.findMany({
        where: {
          store_id: store.id,
          created_at: { gte: lastMonthStart, lte: lastMonthEnd },
        },
        select: { total_amount: true },
      }),
      this.prisma.invoice.count({
        where: { store_id: store.id, created_at: { gte: todayStart } },
      }),
      this.prisma.invoiceItem.groupBy({
        by: ['product_name'],
        where: { invoice: { store_id: store.id, created_at: { gte: monthStart } } },
        _sum: { quantity: true, subtotal: true },
        orderBy: { _sum: { subtotal: 'desc' } },
        take: 5,
      }),
      this.prisma.product.findMany({
        where: { store_id: store.id, is_active: true, stock: { gt: 0, lt: 10 } },
        select: { name: true, stock: true },
        take: 5,
      }),
      this.prisma.product.findMany({
        where: { store_id: store.id, is_active: true, stock: { equals: 0 } },
        select: { name: true },
        take: 5,
      }),
      this.prisma.product.count({
        where: { store_id: store.id, is_active: true },
      }),
      this.prisma.product.count({
        where: { store_id: store.id, is_active: true, cost_price: null },
      }),
    ]);

    const monthRevenue = monthInvoices.reduce((s, i) => s + Number(i.total_amount), 0);
    const lastMonthRevenue = lastMonthInvoices.reduce((s, i) => s + Number(i.total_amount), 0);
    const annualisedRevenue = monthRevenue * 12;
    const thresholdPct = Math.round((annualisedRevenue / EXEMPT_THRESHOLD) * 100);
    const tax = computeTax(store.business_type, monthRevenue, 1);
    const growthPct =
      lastMonthRevenue > 0
        ? Math.round(((monthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100)
        : null;

    const ctx: InsightContext = {
      monthRevenue,
      lastMonthRevenue,
      growthPct,
      annualisedRevenue,
      thresholdPct,
      taxAmount: tax.total_tax,
      belowThreshold: tax.below_threshold,
      currentMonth: now.getMonth() + 1,
      topProducts: topProducts.map((p) => ({
        name: p.product_name,
        subtotal: Number(p._sum.subtotal ?? 0),
        quantity: p._sum.quantity ?? 0,
      })),
      lowStockProducts: lowStockProducts.map((p) => ({
        name: p.name,
        stock: p.stock ?? 0,
      })),
      outOfStockProducts: outOfStockProducts.map((p) => ({ name: p.name })),
      totalProducts,
      productsMissingCostPrice: productsMissingCost,
      hasTaxId: !!store.tax_id,
      businessType: store.business_type,
      todayInvoiceCount: todayCount,
      daysIntoMonth: now.getDate(),
    };

    return runInsightEngine(ctx);
  }
}
