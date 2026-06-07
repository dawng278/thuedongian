/**
 * Quy tắc thuế Hộ kinh doanh theo Thông tư 40/2021/TT-BTC.
 * Dùng chung cho TaxService (màn hình Thuế) và ReportsService (dashboard)
 * để tránh lệch logic giữa hai nơi.
 *
 * Thuế khoán HKD = (tỷ lệ GTGT + tỷ lệ TNCN) trên doanh thu.
 * Miễn thuế nếu doanh thu cả năm < 100 triệu VND.
 */

export interface TaxRate {
  label: string;
  vat: number; // tỷ lệ GTGT
  pit: number; // tỷ lệ TNCN
}

export const TAX_RATES: Record<string, TaxRate> = {
  goods: { label: 'Kinh doanh hàng hóa', vat: 0.01, pit: 0.005 },
  food_beverage: { label: 'Ăn uống', vat: 0.03, pit: 0.015 },
  services: { label: 'Dịch vụ', vat: 0.05, pit: 0.02 },
};

export const DEFAULT_BUSINESS_TYPE = 'food_beverage';

// Ngưỡng doanh thu năm được miễn GTGT & TNCN (VND).
export const EXEMPT_THRESHOLD = 100_000_000;

export function resolveRate(businessType?: string | null): {
  key: string;
  rate: TaxRate;
} {
  const key =
    businessType && businessType in TAX_RATES
      ? businessType
      : DEFAULT_BUSINESS_TYPE;
  return { key, rate: TAX_RATES[key] };
}

export interface TaxComputation {
  business_type: string;
  business_type_label: string;
  exempt_threshold: number;
  annualised_revenue: number;
  below_threshold: boolean;
  vat_rate: number;
  pit_rate: number;
  vat_amount: number;
  pit_amount: number;
  total_tax: number;
  source: string;
}

/**
 * Tính thuế ước tính cho một kỳ.
 * @param periodRevenue  doanh thu trong kỳ
 * @param monthsInPeriod số tháng của kỳ (1 = tháng, 3 = quý, 12 = năm)
 *
 * Ngưỡng miễn thuế so trên doanh thu **quy đổi cả năm**, không phải doanh thu kỳ.
 */
export function computeTax(
  businessType: string | null | undefined,
  periodRevenue: number,
  monthsInPeriod: number,
): TaxComputation {
  const { key, rate } = resolveRate(businessType);
  const annualisedRevenue = (periodRevenue / monthsInPeriod) * 12;
  const belowThreshold = annualisedRevenue < EXEMPT_THRESHOLD;
  const vatAmount = belowThreshold ? 0 : Math.round(periodRevenue * rate.vat);
  const pitAmount = belowThreshold ? 0 : Math.round(periodRevenue * rate.pit);
  return {
    business_type: key,
    business_type_label: rate.label,
    exempt_threshold: EXEMPT_THRESHOLD,
    annualised_revenue: Math.round(annualisedRevenue),
    below_threshold: belowThreshold,
    vat_rate: rate.vat,
    pit_rate: rate.pit,
    vat_amount: vatAmount,
    pit_amount: pitAmount,
    total_tax: vatAmount + pitAmount,
    source: 'Thông tư 40/2021/TT-BTC',
  };
}
