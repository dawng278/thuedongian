import { Module } from '@nestjs/common';
import { InvoicesController } from './invoices.controller';
import { InvoicesService } from './invoices.service';
import { InvoiceXmlService } from './invoice-xml.service';
import { StoresModule } from '../stores/stores.module';

@Module({
  imports: [StoresModule],
  controllers: [InvoicesController],
  providers: [InvoicesService, InvoiceXmlService],
})
export class InvoicesModule {}
