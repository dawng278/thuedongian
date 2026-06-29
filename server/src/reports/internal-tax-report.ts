export interface StoreInfo {
  id: string;
  name: string;
  taxId: string | null;
  address: string | null;
  phone: string | null;
  businessType: string | null;
}

export interface TaxSummary {
  vatRate?: number;
  pitRate?: number;
  vatAmount?: number;
  pitAmount?: number;
  totalTax?: number;
}

export interface TaxInvoiceItem {
  productName: string;
  quantity: number;
  price: number;
  subtotal: number;
}

export interface TaxInvoice {
  invoiceNumber?: number;
  createdAt: string;
  totalAmount: number;
  note?: string | null;
  items: TaxInvoiceItem[];
}

export interface TaxTopProduct {
  productName: string;
  totalRevenue: number;
  totalQuantity: number;
}

export interface InternalTaxReport {
  store: StoreInfo;
  from: string;
  to: string;
  totalRevenue: number;
  invoiceCount: number;
  taxEstimate: TaxSummary;
  invoices: TaxInvoice[];
  topProducts: TaxTopProduct[];
  metadata?: Record<string, string>;
}
