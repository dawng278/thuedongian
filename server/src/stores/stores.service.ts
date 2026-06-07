import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateStoreDto, UpdateStoreDto } from './dto/create-store.dto';

@Injectable()
export class StoresService {
  constructor(private prisma: PrismaService) {}

  async listStores(userId: string) {
    return this.prisma.store.findMany({
      where: { owner_id: userId },
      orderBy: { created_at: 'asc' },
    });
  }

  async createStore(userId: string, dto: CreateStoreDto) {
    return this.prisma.store.create({
      data: {
        owner_id: userId,
        name: dto.name.trim(),
        business_type: dto.business_type,
        tax_id: dto.tax_id?.trim() || null,
        address: dto.address?.trim() || null,
        phone: dto.phone?.trim() || null,
      },
    });
  }

  async getMyStore(userId: string) {
    const store = await this.prisma.store.findFirst({
      where: { owner_id: userId },
      orderBy: { created_at: 'asc' },
    });
    if (!store) throw new NotFoundException('Không tìm thấy cửa hàng');
    return store;
  }

  async getStore(userId: string, storeId: string) {
    const store = await this.prisma.store.findFirst({
      where: { id: storeId, owner_id: userId },
    });
    if (!store) throw new NotFoundException('Không tìm thấy cửa hàng');
    return store;
  }

  async resolveStore(userId: string, storeId?: string) {
    if (storeId) return this.getStore(userId, storeId);
    return this.getMyStore(userId);
  }

  async updateStore(userId: string, data: UpdateStoreDto) {
    const existing = await this.prisma.store.findFirst({
      where: { owner_id: userId },
      orderBy: { created_at: 'asc' },
    });
    if (!existing) {
      return this.prisma.store.create({
        data: {
          owner_id: userId,
          name: (data.name ?? 'Cửa hàng của tôi').trim(),
          business_type: data.business_type ?? 'goods',
          tax_id: data.tax_id?.trim() || null,
          address: data.address?.trim() || null,
          phone: data.phone?.trim() || null,
        },
      });
    }
    return this.prisma.store.update({
      where: { id: existing.id },
      data: {
        ...(data.name !== undefined ? { name: data.name.trim() } : {}),
        ...(data.business_type !== undefined
          ? { business_type: data.business_type }
          : {}),
        ...(data.tax_id !== undefined
          ? { tax_id: data.tax_id?.trim() || null }
          : {}),
        ...(data.address !== undefined
          ? { address: data.address?.trim() || null }
          : {}),
        ...(data.phone !== undefined
          ? { phone: data.phone?.trim() || null }
          : {}),
      },
    });
  }
}
