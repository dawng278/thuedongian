/**
 * Rule-based insight engine cho hộ kinh doanh Việt Nam.
 * Không cần API key, chạy offline, < 1ms.
 *
 * Mỗi rule nhận context và trả về AiInsight | null.
 * Engine chạy tất cả rules, chọn top 3 theo độ ưu tiên (warning > tip > info).
 *
 * Priority map (càng cao càng ưu tiên):
 *  110 ruleNoProducts
 *  105 ruleZeroMonthRevenue
 *  100 ruleTaxCritical
 *   95 ruleOutOfStock
 *   90 ruleTaxWarning
 *   85 ruleTaxQuarterDeadline
 *   80 ruleRevenueDropSevere
 *   75 ruleLowStock
 *   60 ruleTopProductDominates
 *   55 ruleMissingTaxId
 *   50 ruleRevenueGrowth
 *   40 ruleMissingCostPrice
 *   30 ruleFewProducts
 *   20 ruleTaxSafe
 *   15 ruleNoSalesToday
 */

export interface AiInsight {
  type: 'warning' | 'tip' | 'info';
  title: string;
  body: string;
  priority: number; // Số càng lớn càng ưu tiên cao
}

export interface InsightContext {
  // Doanh thu
  monthRevenue: number;
  lastMonthRevenue: number;
  growthPct: number | null; // null nếu tháng trước = 0

  // Thuế
  annualisedRevenue: number;
  thresholdPct: number; // % ngưỡng 200tr
  taxAmount: number; // 0 nếu miễn
  belowThreshold: boolean;
  currentMonth: number; // 1-12

  // Sản phẩm
  topProducts: Array<{ name: string; subtotal: number; quantity: number }>;
  lowStockProducts: Array<{ name: string; stock: number }>;
  outOfStockProducts: Array<{ name: string }>;
  totalProducts: number;
  productsMissingCostPrice: number; // số sản phẩm chưa nhập giá vốn

  // Cửa hàng
  hasTaxId: boolean;
  businessType: string | null;

  // Hóa đơn hôm nay
  todayInvoiceCount: number;
  daysIntoMonth: number; // ngày bao nhiêu của tháng
}

type Rule = (
  ctx: InsightContext,
) => (Omit<AiInsight, 'priority'> & { priority: number }) | null;

// ── Nhóm 0: Trạng thái khẩn cấp ───────────────────────────────────────────

const ruleNoProducts: Rule = (ctx) => {
  if (ctx.totalProducts > 0) return null;
  return {
    type: 'warning',
    title: 'Chưa có sản phẩm nào',
    body: 'Menu trống. Thêm ít nhất 1 sản phẩm để bắt đầu bán hàng.',
    priority: 110,
  };
};

const ruleZeroMonthRevenue: Rule = (ctx) => {
  // Chỉ cảnh báo từ ngày 5 trở đi để tránh false-positive đầu tháng
  if (ctx.monthRevenue > 0 || ctx.daysIntoMonth < 5 || ctx.totalProducts === 0)
    return null;
  return {
    type: 'warning',
    title: 'Chưa có doanh thu tháng này',
    body: `Đã qua ngày ${ctx.daysIntoMonth} tháng này nhưng chưa ghi nhận đơn hàng nào. Kiểm tra kết nối và đồng bộ dữ liệu.`,
    priority: 105,
  };
};

// ── Nhóm 1: Thuế ──────────────────────────────────────────────────────────

const ruleTaxCritical: Rule = (ctx) => {
  if (ctx.thresholdPct < 90) return null;
  const remaining = Math.round(
    (200_000_000 - ctx.annualisedRevenue) / 1_000_000,
  );
  return {
    type: 'warning',
    title: 'Nguy cơ vượt ngưỡng thuế',
    body: `Doanh thu quy đổi năm đã đạt ${ctx.thresholdPct}% ngưỡng 200 triệu. Còn khoảng ${remaining > 0 ? remaining + ' triệu' : 'rất ít'} trước khi phải nộp thuế.`,
    priority: 100,
  };
};

const ruleTaxWarning: Rule = (ctx) => {
  if (ctx.thresholdPct < 70 || ctx.thresholdPct >= 90) return null;
  return {
    type: 'warning',
    title: `Gần ngưỡng thuế (${ctx.thresholdPct}%)`,
    body: `Doanh thu quy đổi năm đang ở ${ctx.thresholdPct}% ngưỡng miễn thuế 200 triệu. Theo dõi sát để chuẩn bị trước.`,
    priority: 90,
  };
};

const ruleTaxQuarterDeadline: Rule = (ctx) => {
  const isLastMonthOfQuarter = [3, 6, 9, 12].includes(ctx.currentMonth);
  if (!isLastMonthOfQuarter) return null;
  const quarterNum = Math.ceil(ctx.currentMonth / 3);
  return {
    type: 'warning',
    title: `Sắp hạn kê khai Q${quarterNum}`,
    body: `Tháng ${ctx.currentMonth} là tháng cuối quý. Hạn nộp tờ khai thuế là ngày cuối tháng ${ctx.currentMonth + 1 > 12 ? 1 : ctx.currentMonth + 1}.`,
    priority: 85,
  };
};

const ruleTaxSafe: Rule = (ctx) => {
  if (!ctx.belowThreshold || ctx.thresholdPct > 40) return null;
  if (ctx.daysIntoMonth < 20) return null; // chỉ hiện cuối tháng
  return {
    type: 'info',
    title: 'Miễn thuế tháng này',
    body: `Doanh thu tháng này chỉ chiếm ${ctx.thresholdPct}% ngưỡng. Bạn vẫn đang trong vùng miễn GTGT và TNCN.`,
    priority: 20,
  };
};

// ── Nhóm 2: Doanh thu ─────────────────────────────────────────────────────

const ruleRevenueDropSevere: Rule = (ctx) => {
  if (ctx.growthPct === null || ctx.growthPct > -20) return null;
  return {
    type: 'warning',
    title: `Doanh thu giảm ${Math.abs(ctx.growthPct)}%`,
    body: `So với tháng trước giảm ${Math.abs(ctx.growthPct)}%. Kiểm tra lại giá bán, tồn kho, hoặc xem có món nào ngừng bán không.`,
    priority: 80,
  };
};

const ruleRevenueGrowth: Rule = (ctx) => {
  if (ctx.growthPct === null || ctx.growthPct < 30) return null;
  return {
    type: 'tip',
    title: `Doanh thu tăng ${ctx.growthPct}%`,
    body: `Tháng này tăng trưởng tốt! Đảm bảo tồn kho đủ cho các sản phẩm bán chạy để không bỏ lỡ đơn.`,
    priority: 50,
  };
};

const ruleNoSalesToday: Rule = (ctx) => {
  // Chỉ hiện khi đã có doanh thu tháng này (tức là shop đang hoạt động bình thường)
  if (ctx.todayInvoiceCount > 0 || ctx.monthRevenue === 0) return null;
  return {
    type: 'info',
    title: 'Chưa có đơn hôm nay',
    body: 'Hôm nay chưa ghi nhận đơn hàng nào. Nếu đã bán nhưng chưa thấy, kiểm tra phần đồng bộ.',
    priority: 15,
  };
};

// ── Nhóm 3: Tồn kho ───────────────────────────────────────────────────────

const ruleOutOfStock: Rule = (ctx) => {
  if (ctx.outOfStockProducts.length === 0) return null;
  const names = ctx.outOfStockProducts
    .slice(0, 3)
    .map((p) => p.name)
    .join(', ');
  return {
    type: 'warning',
    title: `${ctx.outOfStockProducts.length} món đã hết kho`,
    body: `${names}${ctx.outOfStockProducts.length > 3 ? '...' : ''} đã hết hàng — đang mất đơn. Nhập hàng ngay hoặc ẩn tạm khỏi menu.`,
    priority: 95,
  };
};

const ruleLowStock: Rule = (ctx) => {
  if (ctx.lowStockProducts.length === 0) return null;
  const names = ctx.lowStockProducts
    .slice(0, 2)
    .map((p) => `${p.name} (còn ${p.stock})`)
    .join(', ');
  return {
    type: 'warning',
    title: `${ctx.lowStockProducts.length} món sắp hết`,
    body: `${names}${ctx.lowStockProducts.length > 2 ? '...' : ''} sắp hết. Nhập thêm trước khi bán hết để không gián đoạn.`,
    priority: 75,
  };
};

// ── Nhóm 4: Sản phẩm ──────────────────────────────────────────────────────

const ruleTopProductDominates: Rule = (ctx) => {
  if (ctx.topProducts.length === 0 || ctx.monthRevenue === 0) return null;
  const top = ctx.topProducts[0];
  const topPct = Math.round((top.subtotal / ctx.monthRevenue) * 100);
  if (topPct < 60) return null;
  return {
    type: 'warning',
    title: `${top.name} chiếm ${topPct}% doanh thu`,
    body: `Phụ thuộc quá nhiều vào 1 món. Nếu món này hết hàng hoặc giảm bán, doanh thu sẽ bị ảnh hưởng lớn.`,
    priority: 60,
  };
};

const ruleMissingCostPrice: Rule = (ctx) => {
  if (ctx.productsMissingCostPrice === 0) return null;
  return {
    type: 'tip',
    title: 'Nhập giá vốn để tính lợi nhuận',
    body: `${ctx.productsMissingCostPrice} sản phẩm chưa có giá vốn. Điền vào để app tính lợi nhuận thực và biết món nào lãi nhất.`,
    priority: 40,
  };
};

// ── Nhóm 5: Hành động chưa làm ────────────────────────────────────────────

const ruleMissingTaxId: Rule = (ctx) => {
  if (ctx.hasTaxId) return null;
  return {
    type: 'tip',
    title: 'Nhập MST để xuất hóa đơn',
    body: 'Cửa hàng chưa có Mã số thuế. Vào Cài đặt cửa hàng → nhập MST để bật tính năng xuất hóa đơn điện tử XML.',
    priority: 55,
  };
};

const ruleFewProducts: Rule = (ctx) => {
  if (ctx.totalProducts >= 3) return null;
  return {
    type: 'tip',
    title: 'Thêm sản phẩm vào menu',
    body: `Menu hiện chỉ có ${ctx.totalProducts} sản phẩm. Thêm nhiều món để khách có lựa chọn và tăng giá trị đơn hàng.`,
    priority: 30,
  };
};

// ── Engine ─────────────────────────────────────────────────────────────────

const ALL_RULES: Rule[] = [
  // Khẩn cấp
  ruleNoProducts,
  ruleZeroMonthRevenue,
  // Thuế
  ruleTaxCritical,
  ruleTaxWarning,
  ruleTaxQuarterDeadline,
  ruleTaxSafe,
  // Doanh thu
  ruleRevenueDropSevere,
  ruleRevenueGrowth,
  ruleNoSalesToday,
  // Tồn kho
  ruleOutOfStock,
  ruleLowStock,
  // Sản phẩm
  ruleTopProductDominates,
  ruleMissingCostPrice,
  // Hành động
  ruleMissingTaxId,
  ruleFewProducts,
];

export function runInsightEngine(ctx: InsightContext): AiInsight[] {
  const results = ALL_RULES.map((rule) => rule(ctx))
    .filter((r): r is AiInsight => r !== null)
    .sort((a, b) => b.priority - a.priority);

  return results.slice(0, 3);
}
