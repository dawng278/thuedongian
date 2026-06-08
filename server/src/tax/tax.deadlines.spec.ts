import { TaxService } from './tax.service';

// getDeadlines không chạm DB nên truyền deps giả là đủ để test logic ngày.
const service = new TaxService(null as never, null as never);

describe('TaxService.getDeadlines', () => {
  it('Q2 hạn 31/7, Q3 hạn 31/10 (ngày cuối tháng, không phải 30)', () => {
    // Đứng ở 01/05 để mọi hạn từ Q2 trở đi còn phía trước.
    const now = new Date(2026, 4, 1); // 1 May 2026
    const { deadlines } = service.getDeadlines(now);
    const byLabel = (kw: string) => deadlines.find((d) => d.label.includes(kw));

    expect(byLabel('Q2')?.deadline).toBe('2026-07-31');
    expect(byLabel('Q3')?.deadline).toBe('2026-10-31');
  });

  it('Q1 hạn 30/4', () => {
    const now = new Date(2026, 0, 1); // 1 Jan 2026
    const { deadlines } = service.getDeadlines(now);
    const q1 = deadlines.find((d) => d.label.includes('Q1'));
    expect(q1?.deadline).toBe('2026-04-30');
  });

  it('chỉ trả các hạn còn phía trước, sắp xếp tăng theo daysLeft', () => {
    const now = new Date(2026, 7, 15); // 15 Aug 2026 — Q1, Q2 đã qua
    const { deadlines } = service.getDeadlines(now);
    for (const d of deadlines) {
      expect(d.daysLeft).toBeGreaterThanOrEqual(0);
    }
    const days = deadlines.map((d) => d.daysLeft);
    const sorted = [...days].sort((a, b) => a - b);
    expect(days).toEqual(sorted);
    // Q1 (30/4) và Q2 (31/7) đã qua → không còn trong danh sách
    expect(deadlines.find((d) => d.label.includes('Q1'))).toBeUndefined();
    expect(deadlines.find((d) => d.label.includes('Q2'))).toBeUndefined();
  });

  it('đánh dấu urgent khi còn <= 14 ngày', () => {
    // 20/10 → Q3 hạn 31/10 còn 11 ngày → urgent
    const now = new Date(2026, 9, 20);
    const { deadlines } = service.getDeadlines(now);
    const q3 = deadlines.find((d) => d.label.includes('Q3'));
    expect(q3?.urgent).toBe(true);
  });
});
