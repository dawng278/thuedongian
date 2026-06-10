import { UnprocessableEntityException } from '@nestjs/common';
import { InvoiceXmlService } from './invoice-xml.service';

/**
 * Test xuất XML hóa đơn điện tử theo TT 78/2021:
 * - Validate trường bắt buộc (tên + MST cửa hàng).
 * - Cấu trúc XML đúng, escape ký tự đặc biệt (chống XML injection).
 * - Tách tiền chưa thuế / tiền thuế theo loại hình HKD.
 */
function makeData(overrides: Partial<Parameters<InvoiceXmlService['buildXml']>[0]> = {}) {
  return {
    invoiceNumber: 7,
    storeId: 'store-1',
    storeName: 'Quán Cơm Tấm',
    storeTaxId: '0123456789',
    storeAddress: '12 Lê Lợi',
    storePhone: '0900000000',
    businessType: 'food_beverage',
    createdAt: new Date('2026-06-09T03:00:00.000Z'),
    items: [
      {
        productName: 'Cơm tấm',
        unit: 'phần',
        quantity: 2,
        price: 30000,
        subtotal: 60000,
      },
    ],
    totalAmount: 60000,
    note: null,
    ...overrides,
  };
}

describe('InvoiceXmlService.buildXml', () => {
  const service = new InvoiceXmlService();

  it('thiếu tên cửa hàng → UnprocessableEntityException', () => {
    expect(() => service.buildXml(makeData({ storeName: '' }))).toThrow(
      UnprocessableEntityException,
    );
  });

  it('thiếu MST → UnprocessableEntityException', () => {
    expect(() => service.buildXml(makeData({ storeTaxId: null }))).toThrow(
      UnprocessableEntityException,
    );
  });

  it('xuất XML hợp lệ có MST, số hóa đơn và tên món', () => {
    const xml = service.buildXml(makeData());
    expect(xml).toContain('<MST>0123456789</MST>');
    expect(xml).toContain('<SHDon>7</SHDon>');
    expect(xml).toContain('Cơm tấm');
    expect(xml).toContain('http://hoadon.gdt.gov.vn/schema/2.0');
  });

  it('escape ký tự XML đặc biệt trong tên cửa hàng (chống injection)', () => {
    const xml = service.buildXml(
      makeData({ storeName: 'A & B <script>' }),
    );
    // Ký tự thô < > & KHÔNG được xuất hiện nguyên dạng trong nội dung.
    expect(xml).toContain('&amp;');
    expect(xml).toContain('&lt;');
    expect(xml).not.toContain('<script>');
  });

  it('tách tiền chưa thuế + tiền thuế đúng cho ăn uống (VAT 3%)', () => {
    const xml = service.buildXml(makeData({ totalAmount: 103000 }));
    // vatBase = round(103000 / 1.03) = 100000; vatAmount = 3000
    expect(xml).toContain('<TgTCThue>100000</TgTCThue>');
    expect(xml).toContain('<TgTThue>3000</TgTThue>');
    expect(xml).toContain('<THTTHDon>103000</THTTHDon>');
  });

  it('hàng hóa dùng VAT 1%', () => {
    const xml = service.buildXml(
      makeData({ businessType: 'goods', totalAmount: 101000 }),
    );
    // vatBase = round(101000 / 1.01) = 100000; vatAmount = 1000
    expect(xml).toContain('<TgTCThue>100000</TgTCThue>');
    expect(xml).toContain('<TgTThue>1000</TgTThue>');
  });
});
