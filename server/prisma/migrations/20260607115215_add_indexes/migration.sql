-- AlterTable
ALTER TABLE "invoices" ALTER COLUMN "invoice_number" DROP DEFAULT;

-- CreateIndex
CREATE INDEX "invoice_items_invoice_id_idx" ON "invoice_items"("invoice_id");

-- CreateIndex
CREATE INDEX "invoice_items_product_id_idx" ON "invoice_items"("product_id");

-- CreateIndex
CREATE INDEX "invoices_store_id_created_at_idx" ON "invoices"("store_id", "created_at");

-- CreateIndex
CREATE INDEX "products_store_id_is_active_idx" ON "products"("store_id", "is_active");

-- CreateIndex
CREATE INDEX "stores_owner_id_idx" ON "stores"("owner_id");
