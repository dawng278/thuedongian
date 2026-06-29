export enum TaxSchemaVersion {
  V1 = '1.0',
}

export interface TaxSchemaDefinition {
  version: TaxSchemaVersion;
  namespace: string;
  schemaLocation: string;
  rootElement: string;
  formCode: string;
  taxAuthorityCode: string;
  exportType: string;
}

export const TAX_SCHEMA_DEFINITIONS: Record<TaxSchemaVersion, TaxSchemaDefinition> = {
  [TaxSchemaVersion.V1]: {
    version: TaxSchemaVersion.V1,
    namespace: 'urn:thuedongian:tax-report:v1',
    schemaLocation: 'urn:thuedongian:tax-report:v1 tax-report-v1.0.xsd',
    rootElement: 'TaxReport',
    formCode: 'TDG-RPT-01',
    taxAuthorityCode: 'TCCT',
    exportType: 'InternalTaxReport',
  },
};
