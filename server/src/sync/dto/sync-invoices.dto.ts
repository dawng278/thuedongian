import { IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { CreateInvoiceDto } from '../../invoices/dto/create-invoice.dto';

export class SyncInvoicesDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateInvoiceDto)
  invoices: CreateInvoiceDto[];
}
