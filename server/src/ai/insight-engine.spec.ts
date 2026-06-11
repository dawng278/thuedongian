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

// ── Helpers ────────────────────────────────────────────────────────────────

const titles = (ctx: Partial<InsightContext>) =>
  runInsightEngine(makeCtx(ctx)).map((i) => i.title);

const hasTitle = (ctx: Partial<InsightContext>, fragment: string) =>
  titles(ctx).some((t) => t.includes(fragment));

// ══════════════════════════════════════════════════════════════════════════
// Nhóm 0: Engine fundamentals
// ══════════════════════════════════════════════════════════════════════════

describe('Engine', () => {
  it('trả về tối đa 3 gợi ý', () => {
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

  it('trả về mảng rỗng khi không có rule nào khớp', () => {
    // Tất cả điều kiện trong "vùng ổn"
    const insights = runInsightEngine(
      makeCtx({
        thresholdPct: 30,
        growthPct: 0,
        todayInvoiceCount: 5,
        daysIntoMonth: 10, // < 20 → ruleTaxSafe không trigger
        outOfStockProducts: [],
        lowStockProducts: [],
        totalProducts: 5,
        productsMissingCostPrice: 0,
        hasTaxId: true,
        currentMonth: 1,
      }),
    );
    expect(insights.length).toBe(0);
  });

  it('kết quả được sắp xếp priority giảm dần', () => {
    const insights = runInsightEngine(
      makeCtx({
        thresholdPct: 95,
        outOfStockProducts: [{ name: 'X' }],
        growthPct: -30,
      }),
    );
    for (let i = 1; i < insights.length; i++) {
      expect(insights[i - 1].priority).toBeGreaterThanOrEqual(
        insights[i].priority,
      );
    }
  });

  it('mỗi insight đều có type hợp lệ', () => {
    const insights = runInsightEngine(
      makeCtx({
        thresholdPct: 95,
        hasTaxId: false,
        productsMissingCostPrice: 2,
      }),
    );
    const validTypes = ['warning', 'tip', 'info'];
    insights.forEach((i) => expect(validTypes).toContain(i.type));
  });

  it('mỗi insight đều có title và body không rỗng', () => {
    const insights = runInsightEngine(
      makeCtx({ thresholdPct: 80, outOfStockProducts: [{ name: 'A' }] }),
    );
    insights.forEach((i) => {
      expect(i.title.trim().length).toBeGreaterThan(0);
      expect(i.body.trim().length).toBeGreaterThan(0);
    });
  });
});

// ══════════════════════════════════════════════════════════════════════════
// Nhóm 1: Trạng thái khẩn cấp
// ══════════════════════════════════════════════════════════════════════════

describe('ruleNoProducts', () => {
  it('cảnh báo khi totalProducts = 0', () => {
    expect(hasTitle({ totalProducts: 0 }, 'Chưa có sản phẩm')).toBe(true);
  });

  it('KHÔNG cảnh báo khi có ít nhất 1 sản phẩm', () => {
    expect(hasTitle({ totalProducts: 1 }, 'Chưa có sản phẩm')).toBe(false);
  });

  it('là warning và ưu tiên cao nhất (vượt cả ruleTaxCritical)', () => {
    const insights = runInsightEngine(
      makeCtx({ totalProducts: 0, thresholdPct: 99 }),
    );
    expect(insights[0].title).toContain('Chưa có sản phẩm');
    expect(insights[0].type).toBe('warning');
  });
});

describe('ruleZeroMonthRevenue', () => {
  it('cảnh báo khi doanh thu = 0 và đã qua ngày 5', () => {
    expect(
      hasTitle(
        {
          monthRevenue: 0,
          daysIntoMonth: 6,
          totalProducts: 3,
          annualisedRevenue: 0,
          thresholdPct: 0,
        },
        'Chưa có doanh thu',
      ),
    ).toBe(true);
  });

  it('KHÔNG cảnh báo khi mới đầu tháng (ngày 1-4)', () => {
    for (const day of [1, 2, 3, 4]) {
      expect(
        hasTitle(
          {
            monthRevenue: 0,
            daysIntoMonth: day,
            totalProducts: 3,
            annualisedRevenue: 0,
            thresholdPct: 0,
          },
          'Chưa có doanh thu',
        ),
      ).toBe(false);
    }
  });

  it('KHÔNG cảnh báo khi chưa có sản phẩm (tránh trùng với ruleNoProducts)', () => {
    expect(
      hasTitle(
        {
          monthRevenue: 0,
          daysIntoMonth: 10,
          totalProducts: 0,
          annualisedRevenue: 0,
          thresholdPct: 0,
        },
        'Chưa có doanh thu',
      ),
    ).toBe(false);
  });

  it('KHÔNG cảnh báo khi đã có doanh thu', () => {
    expect(
      hasTitle({ monthRevenue: 1_000, daysIntoMonth: 10 }, 'Chưa có doanh thu'),
    ).toBe(false);
  });
});

// ══════════════════════════════════════════════════════════════════════════
// Nhóm 2: Thuế
// ══════════════════════════════════════════════════════════════════════════

describe('ruleTaxCritical', () => {
  it('trigger tại đúng ngưỡng 90%', () => {
    expect(hasTitle({ thresholdPct: 90 }, 'vượt ngưỡng')).toBe(true);
  });

  it('KHÔNG trigger tại 89%', () => {
    expect(hasTitle({ thresholdPct: 89 }, 'vượt ngưỡng')).toBe(false);
  });

  it('type = warning và là phần tử đầu tiên khi không có rule ưu tiên cao hơn', () => {
    const insights = runInsightEngine(
      makeCtx({ thresholdPct: 95, annualisedRevenue: 190_000_000 }),
    );
    expect(insights[0].type).toBe('warning');
    expect(insights[0].title).toContain('vượt ngưỡng');
  });

  it('body chứa % ngưỡng hiện tại', () => {
    const insights = runInsightEngine(makeCtx({ thresholdPct: 92 }));
    const critical = insights.find((i) => i.title.includes('vượt ngưỡng'));
    expect(critical?.body).toContain('92%');
  });
});

describe('ruleTaxWarning', () => {
  it('trigger tại đúng ngưỡng 70%', () => {
    expect(hasTitle({ thresholdPct: 70 }, 'Gần ngưỡng thuế')).toBe(true);
  });

  it('KHÔNG trigger tại 69%', () => {
    expect(hasTitle({ thresholdPct: 69 }, 'Gần ngưỡng thuế')).toBe(false);
  });

  it('KHÔNG trigger tại 90% (ruleTaxCritical đã xử lý)', () => {
    expect(hasTitle({ thresholdPct: 90 }, 'Gần ngưỡng thuế')).toBe(false);
  });

  it('KHÔNG cùng lúc với ruleTaxCritical trong kết quả', () => {
    const insights = runInsightEngine(makeCtx({ thresholdPct: 95 }));
    const hasCritical = insights.some((i) => i.title.includes('vượt ngưỡng'));
    const hasWarning = insights.some((i) =>
      i.title.includes('Gần ngưỡng thuế'),
    );
    expect(hasCritical && hasWarning).toBe(false);
  });
});

describe('ruleTaxQuarterDeadline', () => {
  it.each([3, 6, 9, 12])('trigger tháng cuối quý %i', (month) => {
    expect(hasTitle({ currentMonth: month }, 'kê khai')).toBe(true);
  });

  it.each([1, 2, 4, 5, 7, 8, 10, 11])('KHÔNG trigger tháng %i', (month) => {
    expect(hasTitle({ currentMonth: month }, 'kê khai')).toBe(false);
  });

  it('body chứa số quý đúng', () => {
    const cases = [
      { month: 3, quarter: 'Q1' },
      { month: 6, quarter: 'Q2' },
      { month: 9, quarter: 'Q3' },
      { month: 12, quarter: 'Q4' },
    ];
    for (const { month, quarter } of cases) {
      const insights = runInsightEngine(makeCtx({ currentMonth: month }));
      const q = insights.find((i) => i.title.includes('kê khai'));
      expect(q?.title).toContain(quarter);
    }
  });
});

describe('ruleTaxSafe', () => {
  it('trigger khi belowThreshold, thresholdPct ≤ 40, daysIntoMonth ≥ 20', () => {
    expect(
      hasTitle(
        { belowThreshold: true, thresholdPct: 30, daysIntoMonth: 20 },
        'Miễn thuế',
      ),
    ).toBe(true);
  });

  it('KHÔNG trigger khi daysIntoMonth < 20', () => {
    expect(
      hasTitle(
        { belowThreshold: true, thresholdPct: 20, daysIntoMonth: 19 },
        'Miễn thuế',
      ),
    ).toBe(false);
  });

  it('KHÔNG trigger khi thresholdPct > 40', () => {
    expect(
      hasTitle(
        { belowThreshold: true, thresholdPct: 41, daysIntoMonth: 25 },
        'Miễn thuế',
      ),
    ).toBe(false);
  });
});

// ══════════════════════════════════════════════════════════════════════════
// Nhóm 3: Doanh thu
// ══════════════════════════════════════════════════════════════════════════

describe('ruleRevenueDropSevere', () => {
  it('trigger tại đúng -20%', () => {
    expect(hasTitle({ growthPct: -20 }, 'giảm')).toBe(true);
  });

  it('KHÔNG trigger tại -19%', () => {
    expect(hasTitle({ growthPct: -19 }, 'giảm 19')).toBe(false);
  });

  it('KHÔNG trigger khi growthPct = null (tháng đầu tiên dùng app)', () => {
    expect(hasTitle({ growthPct: null }, 'giảm')).toBe(false);
  });

  it('body chứa % giảm chính xác', () => {
    const insights = runInsightEngine(makeCtx({ growthPct: -35 }));
    const drop = insights.find((i) => i.title.includes('giảm'));
    expect(drop?.title).toContain('35%');
  });
});

describe('ruleRevenueGrowth', () => {
  it('trigger tại đúng 30%', () => {
    expect(hasTitle({ growthPct: 30 }, 'tăng')).toBe(true);
  });

  it('KHÔNG trigger tại 29%', () => {
    expect(hasTitle({ growthPct: 29 }, 'tăng 29')).toBe(false);
  });

  it('KHÔNG trigger khi growthPct = null', () => {
    expect(hasTitle({ growthPct: null }, 'tăng')).toBe(false);
  });

  it('type = tip', () => {
    const insights = runInsightEngine(makeCtx({ growthPct: 50 }));
    const growth = insights.find((i) => i.title.includes('tăng'));
    expect(growth?.type).toBe('tip');
  });
});

describe('ruleNoSalesToday', () => {
  it('trigger khi todayInvoiceCount = 0 và đã có doanh thu tháng này', () => {
    expect(
      hasTitle(
        { todayInvoiceCount: 0, monthRevenue: 1_000_000 },
        'Chưa có đơn hôm nay',
      ),
    ).toBe(true);
  });

  it('KHÔNG trigger khi todayInvoiceCount > 0', () => {
    expect(
      hasTitle(
        { todayInvoiceCount: 1, monthRevenue: 1_000_000 },
        'Chưa có đơn hôm nay',
      ),
    ).toBe(false);
  });

  it('KHÔNG trigger khi monthRevenue = 0 (shop chưa hoạt động)', () => {
    // Nếu monthRevenue = 0 thì ruleZeroMonthRevenue đã xử lý
    expect(
      hasTitle(
        {
          todayInvoiceCount: 0,
          monthRevenue: 0,
          daysIntoMonth: 10,
          totalProducts: 3,
          annualisedRevenue: 0,
          thresholdPct: 0,
        },
        'Chưa có đơn hôm nay',
      ),
    ).toBe(false);
  });
});

// ══════════════════════════════════════════════════════════════════════════
// Nhóm 4: Tồn kho
// ══════════════════════════════════════════════════════════════════════════

describe('ruleOutOfStock', () => {
  it('cảnh báo khi có 1 sản phẩm hết kho', () => {
    expect(
      hasTitle({ outOfStockProducts: [{ name: 'Bún bò' }] }, 'hết kho'),
    ).toBe(true);
  });

  it('type = warning', () => {
    const insights = runInsightEngine(
      makeCtx({ outOfStockProducts: [{ name: 'X' }] }),
    );
    const oos = insights.find((i) => i.title.includes('hết kho'));
    expect(oos?.type).toBe('warning');
  });

  it('title chứa đúng số lượng sản phẩm hết kho', () => {
    const insights = runInsightEngine(
      makeCtx({
        outOfStockProducts: [{ name: 'A' }, { name: 'B' }, { name: 'C' }],
      }),
    );
    const oos = insights.find((i) => i.title.includes('hết kho'));
    expect(oos?.title).toContain('3');
  });

  it('body chỉ liệt kê tối đa 3 tên (truncate với ...)', () => {
    const insights = runInsightEngine(
      makeCtx({
        outOfStockProducts: [
          { name: 'A' },
          { name: 'B' },
          { name: 'C' },
          { name: 'D' },
          { name: 'E' },
        ],
      }),
    );
    const oos = insights.find((i) => i.title.includes('hết kho'));
    expect(oos?.body).toContain('...');
    expect(oos?.body).not.toContain('D');
  });

  it('KHÔNG cảnh báo khi không có sản phẩm hết kho', () => {
    expect(hasTitle({ outOfStockProducts: [] }, 'hết kho')).toBe(false);
  });

  it('ưu tiên cao hơn ruleRevenueDropSevere', () => {
    const insights = runInsightEngine(
      makeCtx({ outOfStockProducts: [{ name: 'X' }], growthPct: -50 }),
    );
    const oosIdx = insights.findIndex((i) => i.title.includes('hết kho'));
    const dropIdx = insights.findIndex((i) => i.title.includes('giảm'));
    if (oosIdx !== -1 && dropIdx !== -1) {
      expect(oosIdx).toBeLessThan(dropIdx);
    }
  });
});

describe('ruleLowStock', () => {
  it('cảnh báo khi có sản phẩm sắp hết (stock 1-9)', () => {
    expect(
      hasTitle({ lowStockProducts: [{ name: 'Cà phê', stock: 3 }] }, 'sắp hết'),
    ).toBe(true);
  });

  it('body chứa tên và số lượng tồn', () => {
    const insights = runInsightEngine(
      makeCtx({ lowStockProducts: [{ name: 'Sữa', stock: 2 }] }),
    );
    const low = insights.find((i) => i.title.includes('sắp hết'));
    expect(low?.body).toContain('Sữa');
    expect(low?.body).toContain('2');
  });

  it('body chỉ liệt kê tối đa 2 tên khi nhiều hơn', () => {
    const insights = runInsightEngine(
      makeCtx({
        lowStockProducts: [
          { name: 'A', stock: 1 },
          { name: 'B', stock: 2 },
          { name: 'C', stock: 3 },
        ],
      }),
    );
    const low = insights.find((i) => i.title.includes('sắp hết'));
    expect(low?.body).toContain('...');
    expect(low?.body).not.toContain('C');
  });
});

// ══════════════════════════════════════════════════════════════════════════
// Nhóm 5: Sản phẩm
// ══════════════════════════════════════════════════════════════════════════

describe('ruleTopProductDominates', () => {
  it('cảnh báo khi 1 sản phẩm chiếm ≥60% doanh thu', () => {
    expect(
      hasTitle(
        {
          monthRevenue: 10_000_000,
          topProducts: [
            { name: 'Cơm tấm', subtotal: 6_000_000, quantity: 100 },
          ],
        },
        'Cơm tấm',
      ),
    ).toBe(true);
  });

  it('KHÔNG cảnh báo tại 59%', () => {
    expect(
      hasTitle(
        {
          monthRevenue: 10_000_000,
          topProducts: [
            { name: 'Cơm tấm', subtotal: 5_900_000, quantity: 100 },
          ],
        },
        'Cơm tấm',
      ),
    ).toBe(false);
  });

  it('KHÔNG cảnh báo khi monthRevenue = 0 (tránh chia cho 0)', () => {
    expect(() =>
      runInsightEngine(
        makeCtx({
          monthRevenue: 0,
          topProducts: [{ name: 'X', subtotal: 0, quantity: 0 }],
        }),
      ),
    ).not.toThrow();
  });

  it('KHÔNG cảnh báo khi topProducts rỗng', () => {
    expect(
      hasTitle({ monthRevenue: 10_000_000, topProducts: [] }, 'chiếm'),
    ).toBe(false);
  });
});

describe('ruleMissingCostPrice', () => {
  it('tip khi có ít nhất 1 sản phẩm thiếu giá vốn', () => {
    expect(hasTitle({ productsMissingCostPrice: 1 }, 'giá vốn')).toBe(true);
  });

  it('KHÔNG trigger khi tất cả sản phẩm đã có giá vốn', () => {
    expect(hasTitle({ productsMissingCostPrice: 0 }, 'giá vốn')).toBe(false);
  });

  it('body chứa đúng số lượng sản phẩm thiếu', () => {
    const insights = runInsightEngine(makeCtx({ productsMissingCostPrice: 7 }));
    const tip = insights.find((i) => i.title.includes('giá vốn'));
    expect(tip?.body).toContain('7');
  });
});

// ══════════════════════════════════════════════════════════════════════════
// Nhóm 6: Hành động chưa làm
// ══════════════════════════════════════════════════════════════════════════

describe('ruleMissingTaxId', () => {
  it('tip khi chưa có MST', () => {
    expect(hasTitle({ hasTaxId: false }, 'MST')).toBe(true);
  });

  it('KHÔNG trigger khi đã có MST', () => {
    expect(hasTitle({ hasTaxId: true }, 'MST')).toBe(false);
  });

  it('type = tip', () => {
    const insights = runInsightEngine(makeCtx({ hasTaxId: false }));
    const mst = insights.find((i) => i.title.includes('MST'));
    expect(mst?.type).toBe('tip');
  });
});

describe('ruleFewProducts', () => {
  it('tip khi totalProducts < 3', () => {
    expect(hasTitle({ totalProducts: 2 }, 'Thêm sản phẩm')).toBe(true);
    expect(hasTitle({ totalProducts: 1 }, 'Thêm sản phẩm')).toBe(true);
  });

  it('KHÔNG trigger tại đúng 3 sản phẩm', () => {
    expect(hasTitle({ totalProducts: 3 }, 'Thêm sản phẩm')).toBe(false);
  });

  it('KHÔNG trigger khi > 3 sản phẩm', () => {
    expect(hasTitle({ totalProducts: 10 }, 'Thêm sản phẩm')).toBe(false);
  });
});

// ══════════════════════════════════════════════════════════════════════════
// Nhóm 7: Priority & mutual exclusion
// ══════════════════════════════════════════════════════════════════════════

describe('Priority và loại trừ lẫn nhau', () => {
  it('ruleNoProducts ưu tiên hơn ruleTaxCritical', () => {
    const insights = runInsightEngine(
      makeCtx({ totalProducts: 0, thresholdPct: 99 }),
    );
    expect(insights[0].title).toContain('Chưa có sản phẩm');
  });

  it('ruleOutOfStock ưu tiên hơn ruleTaxWarning', () => {
    const insights = runInsightEngine(
      makeCtx({ outOfStockProducts: [{ name: 'X' }], thresholdPct: 75 }),
    );
    const oosIdx = insights.findIndex((i) => i.title.includes('hết kho'));
    const taxIdx = insights.findIndex((i) => i.title.includes('Gần ngưỡng'));
    if (oosIdx !== -1 && taxIdx !== -1) {
      expect(oosIdx).toBeLessThan(taxIdx);
    }
  });

  it('ruleTaxCritical và ruleTaxWarning không cùng xuất hiện', () => {
    for (const pct of [90, 95, 100]) {
      const insights = runInsightEngine(makeCtx({ thresholdPct: pct }));
      const hasCritical = insights.some((i) => i.title.includes('vượt ngưỡng'));
      const hasWarning = insights.some((i) => i.title.includes('Gần ngưỡng'));
      expect(hasCritical && hasWarning).toBe(false);
    }
  });

  it('ruleNoSalesToday và ruleZeroMonthRevenue không cùng xuất hiện', () => {
    const insights = runInsightEngine(
      makeCtx({
        todayInvoiceCount: 0,
        monthRevenue: 0,
        daysIntoMonth: 10,
        totalProducts: 3,
        annualisedRevenue: 0,
        thresholdPct: 0,
      }),
    );
    const hasNoSales = insights.some((i) => i.title.includes('Chưa có đơn'));
    const hasNoRevenue = insights.some((i) =>
      i.title.includes('Chưa có doanh thu'),
    );
    expect(hasNoSales && hasNoRevenue).toBe(false);
  });
});

// ══════════════════════════════════════════════════════════════════════════
// Nhóm 8: Edge cases & data integrity
// ══════════════════════════════════════════════════════════════════════════

describe('Edge cases', () => {
  it('growthPct = null (tháng đầu tiên dùng app) — không crash', () => {
    expect(() =>
      runInsightEngine(makeCtx({ growthPct: null, lastMonthRevenue: 0 })),
    ).not.toThrow();
  });

  it('growthPct = null không tạo warning giảm hay tip tăng', () => {
    const insights = runInsightEngine(
      makeCtx({ growthPct: null, lastMonthRevenue: 0 }),
    );
    expect(insights.some((i) => i.title.includes('giảm'))).toBe(false);
    expect(insights.some((i) => i.title.includes('tăng'))).toBe(false);
  });

  it('monthRevenue = 0 và topProducts rỗng — không crash', () => {
    expect(() =>
      runInsightEngine(
        makeCtx({
          monthRevenue: 0,
          topProducts: [],
          annualisedRevenue: 0,
          thresholdPct: 0,
        }),
      ),
    ).not.toThrow();
  });

  it('thresholdPct = 0 — không tạo bất kỳ warning thuế nào', () => {
    const insights = runInsightEngine(makeCtx({ thresholdPct: 0 }));
    const taxWarnings = insights.filter(
      (i) => i.title.includes('ngưỡng') || i.title.includes('thuế'),
    );
    expect(taxWarnings.every((i) => i.type !== 'warning')).toBe(true);
  });

  it('thresholdPct = 100 (vượt ngưỡng) — remaining âm, body không crash', () => {
    expect(() =>
      runInsightEngine(
        makeCtx({ thresholdPct: 100, annualisedRevenue: 210_000_000 }),
      ),
    ).not.toThrow();
  });

  it('tất cả sản phẩm hết kho đều có tên (không undefined)', () => {
    const insights = runInsightEngine(
      makeCtx({ outOfStockProducts: [{ name: 'A' }, { name: 'B' }] }),
    );
    const oos = insights.find((i) => i.title.includes('hết kho'));
    expect(oos?.body).not.toContain('undefined');
  });

  it('currentMonth = 12 — ruleTaxQuarterDeadline tháng sau là 1 (không là 13)', () => {
    const insights = runInsightEngine(makeCtx({ currentMonth: 12 }));
    const q = insights.find((i) => i.title.includes('kê khai'));
    expect(q?.body).toContain('tháng 1');
    expect(q?.body).not.toContain('tháng 13');
  });
});
