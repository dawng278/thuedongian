import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { computeTax } from './tax-rules';
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

    const monthsInPeriod = period === 'quarter' ? 3 : 1;
    const tax = computeTax(store.business_type, periodRevenue, monthsInPeriod);

    return {
      period_label: periodLabel,
      period_start: periodStart.toISOString().substring(0, 10),
      period_end: periodEnd.toISOString().substring(0, 10),
      period_revenue: periodRevenue,
      ...tax,
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
