-- AlterTable
ALTER TABLE "invoices" ADD COLUMN     "payment_method" TEXT NOT NULL DEFAULT 'cash';
