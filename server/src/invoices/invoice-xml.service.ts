import { Injectable, UnprocessableEntityException } from '@nestjs/common';
import { create } from 'xmlbuilder2';
import { resolveRate } from '../tax/tax-rules';

interface InvoiceXmlData {
  invoiceNumber: number;
  storeId: string;
  storeName: string;
  storeTaxId: string | null;
  storeAddress: string | null;
  storePhone: string | null;
  businessType: string | null;
  createdAt: Date;
  items: Array<{
    productName: string;
    unit: string | null;
    quantity: number;
    price: number;
    subtotal: number;
  }>;
  totalAmount: number;
  note: string | null;
}

@Injectable()
export class InvoiceXmlService {
  // Mã loại hóa đơn theo Thông tư 78/2021/TT-BTC: 2 = hóa đơn bán hàng (HKD).
  private readonly MAU_SO = '2';
  // Ký hiệu hóa đơn — HKD = hộ kinh doanh.
  private readonly KY_HIEU = 'HKD-2026';

  buildXml(data: InvoiceXmlData): string {
    // Validate mandatory fields per TT 78/2021
    if (!data.storeName) {
      throw new UnprocessableEntityException(
        'Thiếu tên cửa hàng — không thể xuất XML',
      );
    }
    if (!data.storeTaxId) {
      throw new UnprocessableEntityException(
        'Thiếu MST cửa hàng — không thể xuất XML',
      );
    }

    // Tỷ lệ GTGT theo loại hình HKD (hàng hóa 1%, ăn uống 3%, dịch vụ 5%).
    const vatRate = resolveRate(data.businessType).rate.vat;
    const vatBase = Math.round(data.totalAmount / (1 + vatRate));
    const vatAmount = data.totalAmount - vatBase;
    const ngayLap = data.createdAt.toISOString().substring(0, 10);

    const root = create({ version: '1.0', encoding: 'UTF-8' }).ele('HDon', {
      xmlns: 'http://hoadon.gdt.gov.vn/schema/2.0',
      'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
      version: '2.0',
    });

    // ── Invoice header ──
    const dLHDon = root.ele('DLHDon');
    const ttChung = dLHDon.ele('TTChung');
    ttChung.ele('MSHDon').txt(this.MAU_SO);
    ttChung.ele('KHMSHDon').txt(this.KY_HIEU);
    ttChung.ele('KHHDon').txt(this.KY_HIEU);
    ttChung.ele('SHDon').txt(String(data.invoiceNumber));
    ttChung.ele('NLap').txt(ngayLap);
    ttChung.ele('DVTTe').txt('VND');
    ttChung.ele('TGia').txt('1');

    // ── Seller info (NBan) ──
    const nBan = dLHDon.ele('NDHDon').ele('NBan');
    nBan.ele('Ten').txt(data.storeName);
    nBan.ele('MST').txt(data.storeTaxId);
    if (data.storeAddress) nBan.ele('DChi').txt(data.storeAddress);
    if (data.storePhone) nBan.ele('SDThoai').txt(data.storePhone);

    // ── Items (DSHHDVu) ──
    const dsHHDVu = dLHDon.ele('NDHDon').ele('DSHHDVu');
    data.items.forEach((item, idx) => {
      const hHDVu = dsHHDVu.ele('HHDVu');
      hHDVu.ele('STT').txt(String(idx + 1));
      hHDVu.ele('THHDVu').txt(item.productName);
      hHDVu.ele('DVTinh').txt(item.unit ?? '');
      hHDVu.ele('SLuong').txt(String(item.quantity));
      hHDVu.ele('DGia').txt(String(item.price));
      hHDVu.ele('ThTien').txt(String(item.subtotal));
      hHDVu.ele('TSuat').txt(String(Math.round(vatRate * 100)) + '%');
    });

    // ── Totals ──
    const tToan = dLHDon.ele('TToan');
    tToan.ele('THTTHDon').txt(String(data.totalAmount));
    tToan.ele('TgTCThue').txt(String(vatBase));
    tToan.ele('TgTThue').txt(String(vatAmount));
    if (data.note) tToan.ele('TTHDon').txt(data.note);

    // ── Digital signature placeholder ──
    root.ele('DSCKS');

    return root.end({ prettyPrint: true });
  }
}
