import {
  IsString,
  IsUUID,
  IsNotEmpty,
  IsArray,
  ValidateNested,
  IsNumber,
  Min,
  IsOptional,
  IsDateString,
  IsIn,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateInvoiceItemDto {
  // Khóa ngoại tới product có sẵn — không ép định dạng UUID
  // (id seed/demo có thể không phải UUID v4).
  @IsString()
  @IsOptional()
  product_id?: string;

  @IsString()
  @IsNotEmpty()
  product_name: string;

  @IsNumber()
  @Min(0)
  price: number;

  @IsNumber()
  @Min(1)
  quantity: number;
}

export class CreateInvoiceDto {
  // id hóa đơn do client sinh (UUID v4) — chống trùng khi sync offline.
  @IsUUID()
  id: string;

  // Khóa ngoại tới store có sẵn — không ép UUID (id seed/demo có thể khác).
  @IsString()
  @IsOptional()
  store_id?: string;

  @IsDateString()
  @IsOptional()
  created_at?: string;

  @IsString()
  @IsOptional()
  note?: string;

  @IsIn(['cash', 'transfer'])
  @IsOptional()
  payment_method?: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateInvoiceItemDto)
  items: CreateInvoiceItemDto[];
}
