import { NotFoundException } from '@nestjs/common';
import { SyncService } from './sync.service';

/**
 * Test logic đồng bộ: chống trùng (idempotency) và phân quyền (authz).
 * Mock Prisma + StoresService để không cần DB thật.
 */
function makeInvoiceInput(id: string, storeId = 'store-1') {
  return {
    id,
    store_id: storeId,
    items: [{ product_name: 'A', price: 1000, quantity: 2 }],
  };
}

describe('SyncService.syncInvoices', () => {
  it('hóa đơn UUID đã tồn tại (của chính chủ) → duplicate, KHÔNG tạo mới', async () => {
    const prisma = {
      invoice: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'inv-1',
          invoice_number: 7,
          store: { owner_id: 'user-1' },
        }),
        // không được gọi tới create trong nhánh duplicate
      },
      $transaction: jest.fn(),
    } as never;
    const stores = { resolveStore: jest.fn() } as never;

    const service = new SyncService(prisma, stores);
    const res = await service.syncInvoices('user-1', {
      invoices: [makeInvoiceInput('inv-1')],
    });

    expect(res.duplicates).toBe(1);
    expect(res.saved).toBe(0);
    expect(res.results[0]).toEqual({
      id: 'inv-1',
      status: 'duplicate',
      invoice_number: 7,
    });
    // Không chạm transaction (không tạo hóa đơn mới)
    expect(
      (prisma as { $transaction: jest.Mock }).$transaction,
    ).not.toHaveBeenCalled();
  });

  it('hóa đơn của user khác → NotFoundException (authz, không lộ dữ liệu)', async () => {
    const prisma = {
      invoice: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'inv-1',
          invoice_number: 3,
          store: { owner_id: 'user-OTHER' },
        }),
      },
      $transaction: jest.fn(),
    } as never;
    const stores = { resolveStore: jest.fn() } as never;

    const service = new SyncService(prisma, stores);
    await expect(
      service.syncInvoices('user-1', { invoices: [makeInvoiceInput('inv-1')] }),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('hóa đơn mới → saved với số hóa đơn từ server', async () => {
    const prisma = {
      invoice: {
        findUnique: jest.fn().mockResolvedValue(null),
      },
      // createInvoiceAtomic gọi prisma.$transaction(cb) → trả về invoice đã tạo
      $transaction: jest.fn().mockResolvedValue({ invoice_number: 42 }),
    } as never;
    const stores = {
      resolveStore: jest.fn().mockResolvedValue({ id: 'store-1' }),
    } as never;

    const service = new SyncService(prisma, stores);
    const res = await service.syncInvoices('user-1', {
      invoices: [makeInvoiceInput('inv-new')],
    });

    expect(res.saved).toBe(1);
    expect(res.duplicates).toBe(0);
    expect(res.results[0]).toEqual({
      id: 'inv-new',
      status: 'saved',
      invoice_number: 42,
    });
  });

  it('gửi lại cùng lô 2 lần → lần 2 toàn duplicate (idempotent)', async () => {
    // Lần 1: chưa tồn tại → saved. Lần 2: đã tồn tại → duplicate.
    let exists = false;
    const prisma = {
      invoice: {
        findUnique: jest
          .fn()
          .mockImplementation(() =>
            Promise.resolve(
              exists
                ? { invoice_number: 1, store: { owner_id: 'user-1' } }
                : null,
            ),
          ),
      },
      $transaction: jest.fn().mockImplementation(() => {
        exists = true; // sau khi tạo, lần sau sẽ thấy tồn tại
        return Promise.resolve({ invoice_number: 1 });
      }),
    } as never;
    const stores = {
      resolveStore: jest.fn().mockResolvedValue({ id: 'store-1' }),
    } as never;

    const service = new SyncService(prisma, stores);
    const dto = { invoices: [makeInvoiceInput('inv-x')] };

    const first = await service.syncInvoices('user-1', dto);
    expect(first.saved).toBe(1);

    const second = await service.syncInvoices('user-1', dto);
    expect(second.saved).toBe(0);
    expect(second.duplicates).toBe(1);
  });
});
