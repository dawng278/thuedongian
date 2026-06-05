-- Add business_type to stores for tax rate calculation (TT 40/2021)
ALTER TABLE "stores" ADD COLUMN "business_type" TEXT;
