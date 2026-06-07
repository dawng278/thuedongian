import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

// Tax rates per Thông tư 40/2021/TT-BTC (effective 2021-08-01)
// HKD rates = VAT rate + PIT rate on revenue
const TAX_RATES: Record<string, { vat: number; pit: number; label: string }> = {
  goods: { vat: 0.01, pit: 0.005, label: 'Kinh doanh hàng hóa' },
  food_beverage: { vat: 0.03, pit: 0.015, label: 'Ăn uống' },
  services: { vat: 0.05, pit: 0.02, label: 'Dịch vụ' },
};

// Annual revenue threshold for VAT & PIT exemption (VND) per TT 40/2021
const EXEMPT_THRESHOLD = 100_000_000;

@Injectable()
export class TaxService {
  constructor(private prisma: PrismaService) {}

  private async getStore(userId: string, storeId?: string) {
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

  async estimate(userId: string, period?: string, storeId?: string) {
    const store = await this.getStore(userId, storeId);
    const businessType = (store as Record<string, unknown>)['business_type'] as
      | string
      | undefined;
    const rateKey =
      businessType && businessType in TAX_RATES
        ? businessType
        : 'food_beverage';
    const rates = TAX_RATES[rateKey];

    const now = new Date();
    let periodStart: Date;
    let periodEnd: Date;
    let periodLabel: string;

    if (period === 'quarter') {
      const quarter = Math.floor(now.getMonth() / 3);
      periodStart = new Date(now.getFullYear(), quarter * 3, 1);
      periodEnd = new Date(now.getFullYear(), quarter * 3 + 3, 0, 23, 59, 59);
      periodLabel = `Quý ${quarter + 1}/${now.getFullYear()}`;
    } else {
      periodStart = new Date(now.getFullYear(), now.getMonth(), 1);
      periodEnd = new Date(
        now.getFullYear(),
        now.getMonth() + 1,
        0,
        23,
        59,
        59,
      );
      periodLabel = `Tháng ${now.getMonth() + 1}/${now.getFullYear()}`;
    }

    const invoices = await this.prisma.invoice.findMany({
      where: {
        store_id: store.id,
        created_at: { gte: periodStart, lte: periodEnd },
      },
      select: { total_amount: true },
    });

    const periodRevenue = invoices.reduce(
      (s, i) => s + Number(i.total_amount),
      0,
    );

    // Annualise to check threshold
    const monthsInPeriod = period === 'quarter' ? 3 : 1;
    const annualisedRevenue = (periodRevenue / monthsInPeriod) * 12;
    const belowThreshold = annualisedRevenue < EXEMPT_THRESHOLD;

    const vatAmount = belowThreshold
      ? 0
      : Math.round(periodRevenue * rates.vat);
    const pitAmount = belowThreshold
      ? 0
      : Math.round(periodRevenue * rates.pit);
    const totalTax = vatAmount + pitAmount;

    return {
      period_label: periodLabel,
      period_start: periodStart.toISOString().substring(0, 10),
      period_end: periodEnd.toISOString().substring(0, 10),
      period_revenue: periodRevenue,
      annualised_revenue: Math.round(annualisedRevenue),
      below_threshold: belowThreshold,
      exempt_threshold: EXEMPT_THRESHOLD,
      business_type: rateKey,
      business_type_label: rates.label,
      vat_rate: rates.vat,
      pit_rate: rates.pit,
      vat_amount: vatAmount,
      pit_amount: pitAmount,
      total_tax: totalTax,
      source: 'Thông tư 40/2021/TT-BTC',
      disclaimer:
        'Số liệu ước tính tham khảo — không thay thế tư vấn thuế chính thức.',
    };
  }

  getDeadlines(now = new Date()) {
    const year = now.getFullYear();

    const upcoming: Array<{
      label: string;
      deadline: string;
      daysLeft: number;
      urgent: boolean;
    }> = [];

    // Quarterly deadlines: 30th of month after quarter end
    const quarterDeadlines = [
      { label: 'Kê khai thuế Q1', month: 3, day: 30 }, // Apr 30
      { label: 'Kê khai thuế Q2', month: 6, day: 30 }, // Jul 30
      { label: 'Kê khai thuế Q3', month: 9, day: 30 }, // Oct 30
      { label: 'Kê khai thuế Q4', month: 0, day: 30, nextYear: true }, // Jan 30 next year
    ];

    for (const d of quarterDeadlines) {
      const deadlineYear = d.nextYear ? year + 1 : year;
      const deadline = new Date(deadlineYear, d.month, d.day, 23, 59, 59);
      if (deadline >= now) {
        const daysLeft = Math.ceil(
          (deadline.getTime() - now.getTime()) / 86400000,
        );
        upcoming.push({
          label: d.nextYear ? `${d.label} (${year})` : `${d.label} (${year})`,
          deadline: deadline.toISOString().substring(0, 10),
          daysLeft,
          urgent: daysLeft <= 14,
        });
      }
    }

    // Monthly license fee (lệ phí môn bài): Jan 30 each year
    const monBai = new Date(year, 0, 30, 23, 59, 59);
    if (monBai >= now) {
      const daysLeft = Math.ceil((monBai.getTime() - now.getTime()) / 86400000);
      upcoming.push({
        label: `Lệ phí môn bài (${year})`,
        deadline: monBai.toISOString().substring(0, 10),
        daysLeft,
        urgent: daysLeft <= 14,
      });
    }

    upcoming.sort((a, b) => a.daysLeft - b.daysLeft);
    return { deadlines: upcoming.slice(0, 5) };
  }
}
