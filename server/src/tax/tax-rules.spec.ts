import {
  computeTax,
  resolveRate,
  EXEMPT_THRESHOLD,
  TAX_RATES,
} from './tax-rules';

describe('tax-rules', () => {
  describe('resolveRate', () => {
    it('trả đúng tỷ lệ theo loại hình', () => {
      expect(resolveRate('goods').rate).toEqual(TAX_RATES.goods);
      expect(resolveRate('services').rate).toEqual(TAX_RATES.services);
      expect(resolveRate('food_beverage').rate).toEqual(
        TAX_RATES.food_beverage,
      );
    });

    it('mặc định food_beverage khi loại hình null/không hợp lệ', () => {
      expect(resolveRate(null).key).toBe('food_beverage');
      expect(resolveRate(undefined).key).toBe('food_beverage');
      expect(resolveRate('xyz').key).toBe('food_beverage');
    });
  });

  describe('computeTax — ngưỡng miễn thuế 200tr (quy đổi cả năm, hiệu lực 1/1/2026)', () => {
    it('miễn thuế khi doanh thu năm quy đổi < 200tr', () => {
      // 15tr/tháng × 12 = 180tr/năm < 200tr → miễn
      const r = computeTax('goods', 15_000_000, 1);
      expect(r.below_threshold).toBe(true);
      expect(r.total_tax).toBe(0);
      expect(r.annualised_revenue).toBe(180_000_000);
    });

    it('PHẢI đóng thuế khi năm quy đổi vượt 200tr', () => {
      // 17tr/tháng × 12 = 204tr/năm > 200tr → phải đóng
      const r = computeTax('goods', 17_000_000, 1);
      expect(r.below_threshold).toBe(false);
      expect(r.total_tax).toBeGreaterThan(0);
      // goods: vat 1% + pit 0.5% = 1.5% trên doanh thu kỳ
      expect(r.vat_amount).toBe(170_000); // 17tr × 1%
      expect(r.pit_amount).toBe(85_000);  // 17tr × 0.5%
      expect(r.total_tax).toBe(255_000);
    });

    it('quý: quy đổi từ 3 tháng', () => {
      // 60tr/quý = 20tr/tháng = 240tr/năm > 200tr → phải đóng
      const r = computeTax('services', 60_000_000, 3);
      expect(r.below_threshold).toBe(false);
      expect(r.annualised_revenue).toBe(240_000_000);
      // services: vat 5% + pit 2% trên 60tr
      expect(r.vat_amount).toBe(3_000_000);
      expect(r.pit_amount).toBe(1_200_000);
    });

    it('đúng ngay tại ngưỡng 200tr (không miễn khi = ngưỡng)', () => {
      const atThreshold = computeTax('goods', EXEMPT_THRESHOLD, 12);
      expect(atThreshold.annualised_revenue).toBe(EXEMPT_THRESHOLD);
      expect(atThreshold.below_threshold).toBe(false);
    });

    it('làm tròn số tiền thuế', () => {
      const r = computeTax('food_beverage', 12_345_678, 1);
      expect(Number.isInteger(r.vat_amount)).toBe(true);
      expect(Number.isInteger(r.pit_amount)).toBe(true);
    });
  });
});
