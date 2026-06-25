import { Injectable, UnprocessableEntityException } from '@nestjs/common';
import { create } from 'xmlbuilder2';

interface ReportXmlData {
  store: {
    id: string;
    name: string;
    tax_id: string | null;
    address: string | null;
    phone: string | null;
    business_type: string | null;
  };
  from: string;
  to: string;
  total_revenue: number;
  invoice_count: number;
  tax_estimate: {
    vat_rate?: number;
    pit_rate?: number;
    vat_amount?: number;
    pit_amount?: number;
    total_tax?: number;
  };
  invoices: Array<{
    invoice_number: number | null;
    created_at: string | Date;
    total_amount: number;
    note: string | null;
    items: Array<{
      product_name: string;
      quantity: number;
      price: number;
      subtotal: number;
    }>;
  }>;
  top_products: Array<{
    product_name: string;
    total_revenue: number;
    total_quantity: number;
  }>;
}

@Injectable()
export class ReportsXmlService {
  buildXml(report: ReportXmlData): string {
    if (!report.store?.tax_id) {
      throw new UnprocessableEntityException(
        'Thiếu MST cửa hàng — không thể xuất XML báo cáo kỳ',
      );
    }

    const root = create({ version: '1.0', encoding: 'UTF-8' }).ele('BaoCaoThue');

    const store = root.ele('CuaHang');
    store.ele('Id').txt(report.store.id);
    store.ele('Ten').txt(report.store.name);
    store.ele('MST').txt(report.store.tax_id);
    if (report.store.address) store.ele('DiaChi').txt(report.store.address);
    if (report.store.phone) store.ele('DienThoai').txt(report.store.phone);
    if (report.store.business_type)
      store.ele('LoaiHinh').txt(report.store.business_type);

    const period = root.ele('KyBaoCao');
    period.ele('TuNgay').txt(report.from);
    period.ele('DenNgay').txt(report.to);
    period.ele('SoHoaDon').txt(String(report.invoice_count));
    period.ele('TongDoanhThu').txt(String(report.total_revenue));

    const tax = root.ele('Thue');
    if (report.tax_estimate.vat_rate != null)
      tax.ele('TyLeVAT').txt(String(report.tax_estimate.vat_rate));
    if (report.tax_estimate.pit_rate != null)
      tax.ele('TyLeTNCN').txt(String(report.tax_estimate.pit_rate));
    if (report.tax_estimate.vat_amount != null)
      tax.ele('TienVAT').txt(String(report.tax_estimate.vat_amount));
    if (report.tax_estimate.pit_amount != null)
      tax.ele('TienTNCN').txt(String(report.tax_estimate.pit_amount));
    if (report.tax_estimate.total_tax != null)
      tax.ele('TongThue').txt(String(report.tax_estimate.total_tax));

    const invoices = root.ele('DanhSachHoaDon');
    report.invoices.forEach((invoice, index) => {
      const inv = invoices.ele('HoaDon');
      inv.ele('STT').txt(String(index + 1));
      inv.ele('SoHoaDon').txt(invoice.invoice_number?.toString() ?? '');
      inv.ele('NgayLap').txt(
        typeof invoice.created_at === 'string'
          ? invoice.created_at
          : invoice.created_at.toISOString().substring(0, 10),
      );
      inv.ele('TongTien').txt(String(invoice.total_amount));
      if (invoice.note) inv.ele('GhiChu').txt(invoice.note);

      const items = inv.ele('HangHoa');
      invoice.items.forEach((item, itemIndex) => {
        const row = items.ele('MatHang');
        row.ele('STT').txt(String(itemIndex + 1));
        row.ele('TenHang').txt(item.product_name);
        row.ele('SoLuong').txt(String(item.quantity));
        row.ele('DonGia').txt(String(item.price));
        row.ele('ThanhTien').txt(String(item.subtotal));
      });
    });

    const topProducts = root.ele('TopSanPham');
    report.top_products.forEach((product, index) => {
      const item = topProducts.ele('SanPham');
      item.ele('STT').txt(String(index + 1));
      item.ele('Ten').txt(product.product_name);
      item.ele('DoanhThu').txt(String(product.total_revenue));
      item.ele('SoLuong').txt(String(product.total_quantity));
    });

    return root.end({ prettyPrint: true });
  }
}
