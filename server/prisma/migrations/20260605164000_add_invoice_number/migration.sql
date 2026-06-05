-- AlterTable
ALTER TABLE "invoices" ADD COLUMN "invoice_number" INTEGER NOT NULL DEFAULT 0;

-- CreateIndex
CREATE UNIQUE INDEX "invoices_store_id_invoice_number_key" ON "invoices"("store_id", "invoice_number");
