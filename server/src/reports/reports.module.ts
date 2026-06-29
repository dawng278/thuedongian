import { Module } from '@nestjs/common';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';
import { StoresModule } from '../stores.module';
import { VietnamTaxXmlExporter } from './vietnam-tax-xml-exporter';
import { XmlBuilderService } from './xml-builder.service';
import { XmlValidator } from './xml-validator.service';

@Module({
  imports: [StoresModule],
  controllers: [ReportsController],
  providers: [
    ReportsService,
    VietnamTaxXmlExporter,
    XmlBuilderService,
    XmlValidator,
  ],
})
export class ReportsModule {}
