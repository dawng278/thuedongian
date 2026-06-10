import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Anthropic from '@anthropic-ai/sdk';
import { PrismaService } from '../prisma/prisma.service';
import { StoresService } from '../stores/stores.service';
import { computeTax, EXEMPT_THRESHOLD } from '../tax/tax-rules';

export interface AiInsight {
  type: 'warning' | 'tip' | 'info';
  title: string;
  body: string;
}

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private readonly client: Anthropic | null;

  constructor(
    private config: ConfigService,
    private prisma: PrismaService,
    private stores: StoresService,
  ) {
    const apiKey = this.config.get<string>('ANTHROPIC_API_KEY');
    this.client = apiKey ? new Anthropic({ apiKey }) : null;
    if (!this.client) {
      this.logger.warn('ANTHROPIC_API_KEY chưa cấu hình — AI insights bị tắt');
    }
  }

  async getInsights(userId: string, storeId?: string): Promise<AiInsight[]> {
    if (!this.client) return this.fallbackInsights();

    const store = await this.stores.resolveStore(userId, storeId);
    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59);

    const [monthInvoices, lastMonthInvoices, topProducts, lowStockProducts] =
      await Promise.all([
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
        this.prisma.invoiceItem.groupBy({
          by: ['product_name'],
          where: {
            invoice: {
              store_id: store.id,
              created_at: { gte: monthStart },
            },
          },
          _sum: { quantity: true, subtotal: true },
          orderBy: { _sum: { subtotal: 'desc' } },
          take: 5,
        }),
        this.prisma.product.findMany({
          where: {
            store_id: store.id,
            is_active: true,
            stock: { not: null, lt: 10 },
          },
          select: { name: true, stock: true },
          take: 5,
        }),
      ]);

    const monthRevenue = monthInvoices.reduce(
      (s, i) => s + Number(i.total_amount),
      0,
    );
    const lastMonthRevenue = lastMonthInvoices.reduce(
      (s, i) => s + Number(i.total_amount),
      0,
    );

    // Quy đổi cả năm để kiểm tra ngưỡng thuế
    const annualisedRevenue = monthRevenue * 12;
    const thresholdPct = Math.round((annualisedRevenue / EXEMPT_THRESHOLD) * 100);
    const tax = computeTax(store.business_type, monthRevenue, 1);
    const growthPct =
      lastMonthRevenue > 0
        ? Math.round(((monthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100)
        : null;

    const topProductsStr = topProducts
      .map(
        (p) =>
          `${p.product_name}: ${p._sum.quantity ?? 0} cái, ${(Number(p._sum.subtotal) / 1000).toFixed(0)}k đ`,
      )
      .join('; ');

    const lowStockStr = lowStockProducts
      .map((p) => `${p.name} (còn ${p.stock})`)
      .join(', ');

    const prompt = `Bạn là trợ lý kinh doanh cho hộ kinh doanh Việt Nam. Dựa trên số liệu tháng này, hãy đưa ra ĐÚNG 3 gợi ý ngắn gọn, thực tế, bằng tiếng Việt thông thường (không dùng jargon tài chính phức tạp). Mỗi gợi ý tối đa 2 câu.

Số liệu tháng ${now.getMonth() + 1}/${now.getFullYear()}:
- Doanh thu tháng này: ${(monthRevenue / 1_000_000).toFixed(1)} triệu đồng
- Doanh thu tháng trước: ${(lastMonthRevenue / 1_000_000).toFixed(1)} triệu đồng${growthPct !== null ? ` (${growthPct > 0 ? '+' : ''}${growthPct}%)` : ''}
- Doanh thu quy đổi năm: ${(annualisedRevenue / 1_000_000).toFixed(0)} triệu (${thresholdPct}% ngưỡng miễn thuế 200 triệu)
- Thuế ước tính tháng này: ${tax.below_threshold ? 'miễn (dưới ngưỡng)' : `${((tax.total_tax) / 1000).toFixed(0)}k đ`}
- Sản phẩm bán chạy: ${topProductsStr || 'chưa có dữ liệu'}
- Sản phẩm sắp hết kho: ${lowStockStr || 'không có'}
- Loại hình: ${store.business_type ?? 'chưa xác định'}

Trả về JSON array đúng format sau, không giải thích thêm:
[
  {"type": "warning|tip|info", "title": "tiêu đề ngắn ≤6 từ", "body": "nội dung gợi ý ≤2 câu"},
  ...
]

Quy tắc chọn type:
- "warning": khi có rủi ro (gần ngưỡng thuế ≥70%, tồn kho sắp hết, doanh thu giảm mạnh >20%)
- "tip": gợi ý hành động cụ thể để tăng doanh thu hoặc tiết kiệm chi phí
- "info": thông tin hữu ích không khẩn cấp`;

    try {
      const response = await this.client.messages.create({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 512,
        messages: [{ role: 'user', content: prompt }],
      });

      const text =
        response.content[0].type === 'text' ? response.content[0].text : '';
      // Lấy JSON array từ response (bỏ qua text thừa nếu có)
      const match = text.match(/\[[\s\S]*\]/);
      if (!match) return this.fallbackInsights();
      const parsed = JSON.parse(match[0]) as AiInsight[];
      return parsed.slice(0, 3);
    } catch (err) {
      this.logger.error(
        'AI insights thất bại',
        err instanceof Error ? err.stack : String(err),
      );
      return this.fallbackInsights();
    }
  }

  // Trả về gợi ý tĩnh khi không có API key hoặc lỗi mạng
  private fallbackInsights(): AiInsight[] {
    const now = new Date();
    const month = now.getMonth() + 1;
    // Cảnh báo nộp tờ khai quý nếu đang ở tháng cuối quý (3, 6, 9, 12)
    const isLastMonthOfQuarter = [3, 6, 9, 12].includes(month);
    return [
      ...(isLastMonthOfQuarter
        ? [
            {
              type: 'warning' as const,
              title: 'Sắp đến hạn kê khai quý',
              body: `Tháng ${month} là tháng cuối quý. Kiểm tra doanh thu và chuẩn bị tờ khai trước ngày cuối tháng sau.`,
            },
          ]
        : []),
      {
        type: 'tip' as const,
        title: 'Nhập giá vốn để tính lợi nhuận',
        body: 'Điền giá vốn cho từng sản phẩm để app tự tính lợi nhuận thực. Giúp bạn biết món nào lãi nhất.',
      },
      {
        type: 'info' as const,
        title: 'Ngưỡng miễn thuế 2026',
        body: 'Từ 1/1/2026, hộ kinh doanh có doanh thu dưới 200 triệu/năm được miễn GTGT và TNCN.',
      },
    ];
  }
}
