import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class StoresService {
  constructor(private prisma: PrismaService) {}

  async getMyStore(userId: string) {
    const store = await this.prisma.store.findFirst({
      where: { owner_id: userId },
    });
    if (!store) throw new NotFoundException('Không tìm thấy cửa hàng');
    return store;
  }

  async updateStore(userId: string, data: Partial<{ name: string; tax_id: string; address: string; phone: string }>) {
    const store = await this.prisma.store.findFirst({
      where: { owner_id: userId },
    });
    if (!store) throw new NotFoundException('Không tìm thấy cửa hàng');
    return this.prisma.store.update({
      where: { id: store.id },
      data,
    });
  }
}
