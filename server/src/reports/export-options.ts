import { TaxSchemaVersion } from './tax-schema-version';

export interface ExportMetadata {
  exporterName?: string;
  generatedAt?: string;
  reportCode?: string;
  taxAuthorityCode?: string;
  formCode?: string;
  reportType?: string;
}

export interface ExportOptions {
  schemaVersion?: TaxSchemaVersion;
  prettyPrint?: boolean;
  encoding?: string;
  validate?: boolean;
  metadata?: ExportMetadata;
}
