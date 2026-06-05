import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  private async getStoreId(userId: string): Promise<string> {
    const store = await this.prisma.store.findFirst({ where: { owner_id: userId } });
    if (!store) throw new NotFoundException('Không tìm thấy cửa hàng');
    return store.id;
  }

  async findAll(userId: string) {
    const storeId = await this.getStoreId(userId);
    return this.prisma.product.findMany({
      where: { store_id: storeId, is_active: true },
      orderBy: { name: 'asc' },
    });
  }

  async create(userId: string, dto: CreateProductDto) {
    const storeId = await this.getStoreId(userId);
    return this.prisma.product.create({
      data: {
        store_id: storeId,
        name: dto.name,
        price: dto.price,
        category: dto.category ?? null,
        image_url: dto.image_url ?? null,
      },
    });
  }

  async update(userId: string, productId: string, dto: UpdateProductDto) {
    const storeId = await this.getStoreId(userId);
    const product = await this.prisma.product.findUnique({ where: { id: productId } });
    if (!product || product.store_id !== storeId) {
      throw new ForbiddenException('Không có quyền sửa sản phẩm này');
    }
    return this.prisma.product.update({
      where: { id: productId },
      data: dto,
    });
  }

  async softDelete(userId: string, productId: string) {
    const storeId = await this.getStoreId(userId);
    const product = await this.prisma.product.findUnique({ where: { id: productId } });
    if (!product || product.store_id !== storeId) {
      throw new ForbiddenException('Không có quyền xóa sản phẩm này');
    }
    return this.prisma.product.update({
      where: { id: productId },
      data: { is_active: false },
    });
  }
}
