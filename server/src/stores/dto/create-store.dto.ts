import { IsIn, IsOptional, IsString, Matches, MinLength } from 'class-validator';

const BUSINESS_TYPES = ['goods', 'food_beverage', 'services'] as const;

// MST Việt Nam: 10 chữ số (đơn vị) hoặc 10 số + "-" + 3 số (đơn vị phụ thuộc).
const TAX_ID_PATTERN = /^\d{10}(-\d{3})?$/;
const TAX_ID_MESSAGE = 'MST phải gồm 10 chữ số (hoặc 10 số + "-" + 3 số)';

export class CreateStoreDto {
  @IsString()
  @MinLength(1)
  name: string;

  @IsString()
  @IsIn(BUSINESS_TYPES)
  business_type: string;

  @IsString()
  @IsOptional()
  @Matches(TAX_ID_PATTERN, { message: TAX_ID_MESSAGE })
  tax_id?: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  phone?: string;
}

export class UpdateStoreDto {
  @IsString()
  @MinLength(1)
  @IsOptional()
  name?: string;

  @IsString()
  @IsIn(BUSINESS_TYPES)
  @IsOptional()
  business_type?: string;

  @IsString()
  @IsOptional()
  @Matches(TAX_ID_PATTERN, { message: TAX_ID_MESSAGE })
  tax_id?: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  phone?: string;
}
