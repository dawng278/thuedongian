import { Module } from '@nestjs/common';
import { InvoicesController } from './invoices.controller';
import { InvoicesService } from './invoices.service';
import { InvoiceXmlService } from './invoice-xml.service';

@Module({
  controllers: [InvoicesController],
  providers: [InvoicesService, InvoiceXmlService],
})
export class InvoicesModule {}
