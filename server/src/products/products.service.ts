import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  private async resolveStoreId(
    userId: string,
    storeId?: string,
  ): Promise<string> {
    const store = await this.prisma.store.findFirst({
      where: {
        owner_id: userId,
        ...(storeId ? { id: storeId } : {}),
      },
      orderBy: { created_at: 'asc' },
    });
    if (!store) throw new NotFoundException('Không tìm thấy cửa hàng');
    return store.id;
  }

  async findAll(
    userId: string,
    requestedStoreId?: string,
    includeInactive = false,
  ) {
    const storeId = await this.resolveStoreId(userId, requestedStoreId);
    return this.prisma.product.findMany({
      where: {
        store_id: storeId,
        ...(includeInactive ? {} : { is_active: true }),
      },
      orderBy: { name: 'asc' },
    });
  }

  async create(userId: string, dto: CreateProductDto, queryStoreId?: string) {
    const storeId = await this.resolveStoreId(
      userId,
      dto.store_id ?? queryStoreId,
    );
    return this.prisma.product.create({
      data: {
        store_id: storeId,
        name: dto.name,
        price: dto.price,
        unit: dto.unit ?? null,
        category: dto.category ?? null,
        image_url: dto.image_url ?? null,
      },
    });
  }

  async update(userId: string, productId: string, dto: UpdateProductDto) {
    const product = await this.prisma.product.findUnique({
      where: { id: productId },
      include: { store: true },
    });
    if (!product || product.store.owner_id !== userId) {
      throw new ForbiddenException('Không có quyền sửa sản phẩm này');
    }
    return this.prisma.product.update({
      where: { id: productId },
      data: dto,
    });
  }

  async softDelete(userId: string, productId: string) {
    const product = await this.prisma.product.findUnique({
      where: { id: productId },
      include: { store: true },
    });
    if (!product || product.store.owner_id !== userId) {
      throw new ForbiddenException('Không có quyền xóa sản phẩm này');
    }
    return this.prisma.product.update({
      where: { id: productId },
      data: { is_active: false },
    });
  }
}
