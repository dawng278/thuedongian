import { IsIn, IsOptional, IsString, MinLength } from 'class-validator';

const BUSINESS_TYPES = ['goods', 'food_beverage', 'services'] as const;

export class CreateStoreDto {
  @IsString()
  @MinLength(1)
  name: string;

  @IsString()
  @IsIn(BUSINESS_TYPES)
  business_type: string;

  @IsString()
  @IsOptional()
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
  tax_id?: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  phone?: string;
}
