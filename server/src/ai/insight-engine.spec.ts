import { runInsightEngine, InsightContext } from './insight-engine';

function makeCtx(overrides: Partial<InsightContext> = {}): InsightContext {
  return {
    monthRevenue: 10_000_000,
    lastMonthRevenue: 10_000_000,
    growthPct: 0,
    annualisedRevenue: 120_000_000,
    thresholdPct: 60,
    taxAmount: 0,
    belowThreshold: true,
    currentMonth: 5,
    topProducts: [],
    lowStockProducts: [],
    outOfStockProducts: [],
    totalProducts: 5,
    productsMissingCostPrice: 0,
    hasTaxId: true,
    businessType: 'food_beverage',
    todayInvoiceCount: 3,
    daysIntoMonth: 15,
    ...overrides,
  };
}

describe('InsightEngine', () => {
  it('trả về tối đa 3 gợi ý', () => {
    // Tạo nhiều điều kiện trigger cùng lúc
    const insights = runInsightEngine(
      makeCtx({
        thresholdPct: 95,
        outOfStockProducts: [{ name: 'Cơm' }],
        lowStockProducts: [{ name: 'Bún', stock: 2 }],
        growthPct: -30,
        currentMonth: 6,
      }),
    );
    expect(insights.length).toBeLessThanOrEqual(3);
    expect(insights.length).toBeGreaterThan(0);
  });

  it('warning thuế critical (≥90%) — ưu tiên cao nhất', () => {
    const insights = runInsightEngine(makeCtx({ thresholdPct: 95, annualisedRevenue: 190_000_000 }));
    expect(insights[0].type).toBe('warning');
    expect(insights[0].title).toContain('vượt ngưỡng');
  });

  it('warning hết kho ưu tiên hơn warning giảm doanh thu', () => {
    const insights = runInsightEngine(
      makeCtx({
        outOfStockProducts: [{ name: 'Cơm tấm' }],
        growthPct: -25,
        thresholdPct: 30,
      }),
    );
    const types = insights.map((i) => i.title);
    const outOfStockIdx = types.findIndex((t) => t.includes('hết kho'));
    const dropIdx = types.findIndex((t) => t.includes('giảm'));
    if (outOfStockIdx !== -1 && dropIdx !== -1) {
      expect(outOfStockIdx).toBeLessThan(dropIdx);
    }
  });

  it('không có warning nào khi mọi thứ ổn', () => {
    const insights = runInsightEngine(makeCtx());
    const warnings = insights.filter((i) => i.type === 'warning');
    expect(warnings.length).toBe(0);
  });

  it('cảnh báo hạn kê khai khi tháng cuối quý (3,6,9,12)', () => {
    for (const month of [3, 6, 9, 12]) {
      const insights = runInsightEngine(makeCtx({ currentMonth: month, thresholdPct: 10 }));
      expect(insights.some((i) => i.title.includes('kê khai'))).toBe(true);
    }
  });

  it('KHÔNG cảnh báo kê khai quý khi không phải tháng cuối quý', () => {
    for (const month of [1, 2, 4, 5, 7, 8, 10, 11]) {
      const insights = runInsightEngine(makeCtx({ currentMonth: month, thresholdPct: 10 }));
      expect(insights.some((i) => i.title.includes('kê khai'))).toBe(false);
    }
  });

  it('gợi ý nhập MST khi chưa có', () => {
    const insights = runInsightEngine(makeCtx({ hasTaxId: false, totalProducts: 5 }));
    expect(insights.some((i) => i.title.includes('MST'))).toBe(true);
  });

  it('gợi ý nhập giá vốn khi có sản phẩm thiếu', () => {
    const insights = runInsightEngine(makeCtx({ productsMissingCostPrice: 3 }));
    expect(insights.some((i) => i.title.includes('giá vốn'))).toBe(true);
  });

  it('cảnh báo 1 sản phẩm chiếm >60% doanh thu', () => {
    const insights = runInsightEngine(
      makeCtx({
        monthRevenue: 10_000_000,
        topProducts: [{ name: 'Cơm tấm', subtotal: 7_000_000, quantity: 100 }],
      }),
    );
    expect(insights.some((i) => i.title.includes('Cơm tấm'))).toBe(true);
  });

  it('cảnh báo sản phẩm đã hết kho', () => {
    const insights = runInsightEngine(
      makeCtx({ outOfStockProducts: [{ name: 'Bún bò' }, { name: 'Phở' }] }),
    );
    expect(insights.some((i) => i.type === 'warning' && i.title.includes('hết kho'))).toBe(true);
  });

  it('tip tăng doanh thu khi tăng trưởng >30%', () => {
    const insights = runInsightEngine(makeCtx({ growthPct: 45 }));
    expect(insights.some((i) => i.type === 'tip' && i.title.includes('tăng'))).toBe(true);
  });
});
