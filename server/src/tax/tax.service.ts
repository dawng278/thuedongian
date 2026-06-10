import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { computeTax, EXEMPT_THRESHOLD } from './tax-rules';
import { StoresService } from '../stores/stores.service';

const MS_PER_DAY = 86_400_000;

@Injectable()
export class TaxService {
  constructor(
    private prisma: PrismaService,
    private stores: StoresService,
  ) {}

  async estimate(userId: string, period?: string, storeId?: string) {
    const store = await this.stores.resolveStore(userId, storeId);

    const now = new Date();
    let periodStart: Date;
    let periodEnd: Date;
    let periodLabel: string;
    let monthsInPeriod: number;

    if (period === 'quarter') {
      const quarter = Math.floor(now.getMonth() / 3);
      periodStart = new Date(now.getFullYear(), quarter * 3, 1);
      periodEnd = new Date(now.getFullYear(), quarter * 3 + 3, 0, 23, 59, 59);
      periodLabel = `Quý ${quarter + 1}/${now.getFullYear()}`;
      monthsInPeriod = 3;
    } else if (period === 'year') {
      periodStart = new Date(now.getFullYear(), 0, 1);
      periodEnd = new Date(now.getFullYear(), 11, 31, 23, 59, 59);
      periodLabel = `Năm ${now.getFullYear()}`;
      monthsInPeriod = 12;
    } else {
      periodStart = new Date(now.getFullYear(), now.getMonth(), 1);
      periodEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
      periodLabel = `Tháng ${now.getMonth() + 1}/${now.getFullYear()}`;
      monthsInPeriod = 1;
    }

    const invoices = await this.prisma.invoice.findMany({
      where: {
        store_id: store.id,
        created_at: { gte: periodStart, lte: periodEnd },
      },
      select: { total_amount: true, created_at: true },
    });

    const periodRevenue = invoices.reduce(
      (s, i) => s + Number(i.total_amount),
      0,
    );

    const tax = computeTax(store.business_type, periodRevenue, monthsInPeriod);

    // Breakdown theo tháng trong kỳ (để vẽ biểu đồ / chi tiết)
    const monthlyBreakdown = await this._monthlyBreakdown(
      store.id,
      periodStart,
      periodEnd,
      store.business_type,
    );

    // Doanh thu năm thực tế (để so với ngưỡng 200tr chính xác hơn)
    const yearStart = new Date(now.getFullYear(), 0, 1);
    const yearRevenue =
      period === 'year'
        ? periodRevenue
        : (
            await this.prisma.invoice.aggregate({
              where: { store_id: store.id, created_at: { gte: yearStart, lte: now } },
              _sum: { total_amount: true },
            })
          )._sum.total_amount ?? 0;

    const yearRevenueNum = Number(yearRevenue);
    const yearProgress = Math.min(
      Math.round((yearRevenueNum / EXEMPT_THRESHOLD) * 100),
      100,
    );

    return {
      period_label: periodLabel,
      period_start: periodStart.toISOString().substring(0, 10),
      period_end: periodEnd.toISOString().substring(0, 10),
      period_revenue: periodRevenue,
      year_revenue: yearRevenueNum,
      year_progress_pct: yearProgress,
      monthly_breakdown: monthlyBreakdown,
      ...tax,
      disclaimer:
        'Số liệu ước tính tham khảo — không thay thế tư vấn thuế chính thức.',
    };
  }

  private async _monthlyBreakdown(
    storeId: string,
    from: Date,
    to: Date,
    businessType: string | null,
  ) {
    const rows = await this.prisma.$queryRaw<
      { month: number; year: number; revenue: bigint }[]
    >`
      SELECT
        EXTRACT(MONTH FROM created_at)::int AS month,
        EXTRACT(YEAR  FROM created_at)::int AS year,
        SUM(total_amount)::bigint           AS revenue
      FROM invoices
      WHERE store_id = ${storeId}
        AND created_at >= ${from}
        AND created_at <= ${to}
      GROUP BY year, month
      ORDER BY year, month
    `;

    return rows.map((r) => {
      const rev = Number(r.revenue);
      const tax = computeTax(businessType, rev, 1);
      return {
        month: r.month,
        year: r.year,
        revenue: rev,
        tax_amount: tax.total_tax,
        below_threshold: tax.below_threshold,
      };
    });
  }

  getDeadlines(now = new Date()) {
    const year = now.getFullYear();

    const upcoming: Array<{
      label: string;
      deadline: string;
      daysLeft: number;
      urgent: boolean;
    }> = [];

    // Hạn nộp tờ khai thuế quý (HKD kê khai): chậm nhất ngày cuối cùng của
    // tháng đầu quý kế tiếp (TT 40/2021, Điều 11). Dùng "ngày 0 của tháng sau"
    // để lấy đúng ngày cuối tháng (30 hoặc 31), không hardcode 30.
    // Q1 → 30/4, Q2 → 31/7, Q3 → 31/10, Q4 → 31/1 năm sau.
    const quarterDeadlines = [
      { label: 'Kê khai thuế Q1', firstMonthOfNextQuarter: 3, year }, // tháng 4 → 30/4
      { label: 'Kê khai thuế Q2', firstMonthOfNextQuarter: 6, year }, // tháng 7 → 31/7
      { label: 'Kê khai thuế Q3', firstMonthOfNextQuarter: 9, year }, // tháng 10 → 31/10
      { label: 'Kê khai thuế Q4', firstMonthOfNextQuarter: 12, year }, // tháng 1 năm sau → 31/1
    ];

    for (const d of quarterDeadlines) {
      // Ngày cuối tháng đầu quý sau = ngày 0 của tháng kế tiếp tháng đó.
      const deadline = new Date(
        d.year,
        d.firstMonthOfNextQuarter + 1,
        0,
        23,
        59,
        59,
      );
      if (deadline >= now) {
        const daysLeft = Math.ceil(
          (deadline.getTime() - now.getTime()) / MS_PER_DAY,
        );
        upcoming.push({
          label: `${d.label} (${year})`,
          deadline: deadline.toISOString().substring(0, 10),
          daysLeft,
          urgent: daysLeft <= 14,
        });
      }
    }

    // Lệ phí môn bài đã bị BÃI BỎ từ 1/1/2026 theo Nghị quyết 198/2025/QH15.
    // Không hiển thị deadline này nữa.

    upcoming.sort((a, b) => a.daysLeft - b.daysLeft);
    return { deadlines: upcoming.slice(0, 5) };
  }
}
