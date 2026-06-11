import { Prisma, PrismaClient } from '@prisma/client';

export interface InvoiceItemInput {
  product_id?: string | null;
  product_name: string;
  price: number;
  quantity: number;
}

export interface CreateInvoiceInput {
  id: string;
  storeId: string;
  items: InvoiceItemInput[];
  note?: string | null;
  paymentMethod?: string;
  createdAt: Date;
}

/**
 * Tạo hóa đơn với số thứ tự tuần tự theo cửa hàng, an toàn với race condition.
 *
 * Số hóa đơn = count + 1 không atomic: hai hóa đơn sync đồng thời cùng cửa hàng
 * có thể đọc cùng count → trùng số → vi phạm @@unique([store_id, invoice_number]).
 *
 * Giải pháp: bọc trong $transaction (Serializable) và retry khi đụng unique
 * constraint (P2002) hoặc lỗi serialization (P2034).
 */
export async function createInvoiceAtomic(
  prisma: PrismaClient,
  input: CreateInvoiceInput,
  maxRetries = 5,
): Promise<Prisma.InvoiceGetPayload<{ include: { items: true } }>> {
  const totalAmount = input.items.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0,
  );

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await prisma.$transaction(
        async (tx) => {
          const count = await tx.invoice.count({
            where: { store_id: input.storeId },
          });
          const invoiceNumber = count + 1;

          const invoice = await tx.invoice.create({
            data: {
              id: input.id,
              store_id: input.storeId,
              invoice_number: invoiceNumber,
              total_amount: totalAmount,
              payment_method: input.paymentMethod ?? 'cash',
              note: input.note ?? null,
              created_at: input.createdAt,
              synced_at: new Date(),
              items: {
                create: input.items.map((item) => ({
                  product_id: item.product_id ?? null,
                  product_name: item.product_name,
                  price: item.price,
                  quantity: item.quantity,
                  subtotal: item.price * item.quantity,
                })),
              },
            },
            include: { items: true },
          });

          // Trừ kho cho sản phẩm có theo dõi tồn (stock != null).
          // KHÔNG chặn khi âm: offline app đã bán xong, server chỉ ghi nhận —
          // chặn sẽ làm mất hóa đơn. Tồn âm sẽ được cảnh báo ở UI.
          for (const item of input.items) {
            if (!item.product_id) continue;
            const product = await tx.product.findUnique({
              where: { id: item.product_id },
              select: { stock: true },
            });
            if (product && product.stock != null) {
              await tx.product.update({
                where: { id: item.product_id },
                data: { stock: { decrement: item.quantity } },
              });
            }
          }

          return invoice;
        },
        { isolationLevel: Prisma.TransactionIsolationLevel.Serializable },
      );
    } catch (e) {
      const isRetryable =
        e instanceof Prisma.PrismaClientKnownRequestError &&
        (e.code === 'P2002' || e.code === 'P2034');
      if (isRetryable && attempt < maxRetries - 1) {
        continue;
      }
      throw e;
    }
  }
  // Không thể tới đây — vòng lặp luôn return hoặc throw.
  throw new Error('Không thể tạo hóa đơn sau nhiều lần thử');
}
