import { Injectable, UnprocessableEntityException } from '@nestjs/common';
import { XmlBuilderService } from './xml-builder.service';
import { XmlValidator } from './xml-validator.service';
import {
  ExportOptions,
  ExportMetadata,
} from './export-options';
import {
  InternalTaxReport,
  TaxInvoice,
  TaxInvoiceItem,
} from './internal-tax-report';
import {
  TAX_SCHEMA_DEFINITIONS,
  TaxSchemaDefinition,
  TaxSchemaVersion,
} from './tax-schema-version';

@Injectable()
export class VietnamTaxXmlExporter {
  constructor(
    private readonly xmlBuilder: XmlBuilderService,
    private readonly validator: XmlValidator,
  ) {}

  export(
    report: InternalTaxReport,
    options: ExportOptions = {},
  ): { xml: string; valid: boolean; errors: string[] } {
    const schemaVersion = options.schemaVersion ?? TaxSchemaVersion.V1;
    const schemaDef = TAX_SCHEMA_DEFINITIONS[schemaVersion];
    const metadata = this.normalizeMetadata(options.metadata);

    if (!report.store.taxId) {
      throw new UnprocessableEntityException(
        'Thiếu MST cửa hàng — không thể xuất XML thuế.',
      );
    }

    const rootAttrs = this.buildRootAttributes(schemaDef, metadata);
    const document = this.xmlBuilder.buildDocument(schemaDef.rootElement, rootAttrs);
    this.buildReport(document, report, metadata, schemaDef);
    const xml = this.xmlBuilder.toString(document, options.prettyPrint ?? true);
    const validation = options.validate
      ? this.validator.validate(xml, schemaDef.schemaLocation)
      : { valid: true, errors: [] };
    return { xml, valid: validation.valid, errors: validation.errors };
  }

  private normalizeMetadata(metadata?: ExportMetadata): ExportMetadata {
    return {
      exporterName: metadata?.exporterName ?? 'TaxEasy Internal Exporter',
      generatedAt:
        metadata?.generatedAt ?? new Date().toISOString().substring(0, 19),
      reportCode: metadata?.reportCode ?? 'TDG-RPT-01',
      taxAuthorityCode: metadata?.taxAuthorityCode ?? 'TCCT',
      formCode: metadata?.formCode ?? 'TDG-RPT-01',
      reportType: metadata?.reportType ?? 'InternalTaxReport',
    };
  }

  private buildRootAttributes(
    schemaDef: TaxSchemaDefinition,
    metadata: ExportMetadata,
  ) {
    return {
      xmlns: schemaDef.namespace,
      'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
      'xsi:schemaLocation': schemaDef.schemaLocation,
      version: schemaDef.version,
      metadataExporter: metadata.exporterName ?? '',
      metadataGeneratedAt: metadata.generatedAt ?? '',
      metadataReportCode: metadata.reportCode ?? '',
      metadataTaxAuthorityCode: metadata.taxAuthorityCode ?? '',
      metadataFormCode: metadata.formCode ?? '',
      metadataReportType: metadata.reportType ?? '',
    } as Record<string, string>;
  }

  private buildReport(
    document: any,
    report: InternalTaxReport,
    metadata: ExportMetadata,
    schemaDef: TaxSchemaDefinition,
  ) {
    document.ele('Header').ele('CreatedAt').txt(metadata.generatedAt);
    const issuer = document.ele('Issuer');
    issuer.ele('Name').txt(report.store.name);
    issuer.ele('TaxId').txt(report.store.taxId ?? '');
    issuer.ele('Address').txt(report.store.address ?? '');
    issuer.ele('Phone').txt(report.store.phone ?? '');
    issuer.ele('BusinessType').txt(report.store.businessType ?? '');

    const period = document.ele('Period');
    period.ele('From').txt(report.from);
    period.ele('To').txt(report.to);
    period.ele('InvoiceCount').txt(String(report.invoiceCount));
    period.ele('TotalRevenue').txt(String(report.totalRevenue));

    const tax = document.ele('TaxSummary');
    if (report.taxEstimate.vatRate != null)
      tax.ele('VatRate').txt(String(report.taxEstimate.vatRate));
    if (report.taxEstimate.pitRate != null)
      tax.ele('PitRate').txt(String(report.taxEstimate.pitRate));
    if (report.taxEstimate.vatAmount != null)
      tax.ele('VatAmount').txt(String(report.taxEstimate.vatAmount));
    if (report.taxEstimate.pitAmount != null)
      tax.ele('PitAmount').txt(String(report.taxEstimate.pitAmount));
    if (report.taxEstimate.totalTax != null)
      tax.ele('TotalTax').txt(String(report.taxEstimate.totalTax));

    const invoicesNode = document.ele('Invoices');
    report.invoices.forEach((invoice, index) => {
      this.appendInvoice(invoicesNode, invoice, index + 1);
    });

    const productsNode = document.ele('TopProducts');
    report.topProducts.forEach((product, index) => {
      const node = productsNode.ele('Product');
      node.ele('Index').txt(String(index + 1));
      node.ele('Name').txt(product.productName);
      node.ele('Revenue').txt(String(product.totalRevenue));
      node.ele('Quantity').txt(String(product.totalQuantity));
    });
  }

  private appendInvoice(
    parent: any,
    invoice: TaxInvoice,
    index: number,
  ) {
    const node = parent.ele('Invoice');
    node.ele('Index').txt(String(index));
    node.ele('InvoiceNumber').txt(invoice.invoiceNumber?.toString() ?? '');
    node.ele('CreatedAt').txt(invoice.createdAt);
    node.ele('TotalAmount').txt(String(invoice.totalAmount));
    if (invoice.note) node.ele('Note').txt(invoice.note);

    const itemsNode = node.ele('Items');
    invoice.items.forEach((item, itemIndex) => {
      this.appendInvoiceItem(itemsNode, item, itemIndex + 1);
    });
  }

  private appendInvoiceItem(
    parent: any,
    item: TaxInvoiceItem,
    index: number,
  ) {
    const node = parent.ele('Item');
    node.ele('Index').txt(String(index));
    node.ele('ProductName').txt(item.productName);
    node.ele('Quantity').txt(String(item.quantity));
    node.ele('Price').txt(String(item.price));
    node.ele('Subtotal').txt(String(item.subtotal));
  }
}
