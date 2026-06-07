import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { StoresService } from '../stores/stores.service';

@Injectable()
export class ProductsService {
  constructor(
    private prisma: PrismaService,
    private stores: StoresService,
  ) {}

  private serializeProduct(p: any) {
    return {
      ...p,
      price: Number(p.price),
      cost_price: p.cost_price != null ? Number(p.cost_price) : null,
    };
  }

  private async resolveStoreId(
    userId: string,
    storeId?: string,
  ): Promise<string> {
    const store = await this.stores.resolveStore(userId, storeId);
    return store.id;
  }

  async findAll(
    userId: string,
    requestedStoreId?: string,
    includeInactive = false,
  ) {
    const storeId = await this.resolveStoreId(userId, requestedStoreId);
    const products = await this.prisma.product.findMany({
      where: {
        store_id: storeId,
        ...(includeInactive ? {} : { is_active: true }),
      },
      orderBy: { name: 'asc' },
    });
    return products.map((p) => this.serializeProduct(p));
  }

  async create(userId: string, dto: CreateProductDto, queryStoreId?: string) {
    const storeId = await this.resolveStoreId(
      userId,
      dto.store_id ?? queryStoreId,
    );
    const created = await this.prisma.product.create({
      data: {
        store_id: storeId,
        name: dto.name,
        price: dto.price,
        cost_price: dto.cost_price ?? null,
        stock: dto.stock ?? null,
        unit: dto.unit ?? null,
        category: dto.category ?? null,
        image_url: dto.image_url ?? null,
      },
    });
    return this.serializeProduct(created);
  }

  async update(userId: string, productId: string, dto: UpdateProductDto) {
    const product = await this.prisma.product.findUnique({
      where: { id: productId },
      include: { store: true },
    });
    if (!product || product.store.owner_id !== userId) {
      throw new ForbiddenException('Không có quyền sửa sản phẩm này');
    }
    const updated = await this.prisma.product.update({
      where: { id: productId },
      data: dto,
    });
    return this.serializeProduct(updated);
  }

  async softDelete(userId: string, productId: string) {
    const product = await this.prisma.product.findUnique({
      where: { id: productId },
      include: { store: true },
    });
    if (!product || product.store.owner_id !== userId) {
      throw new ForbiddenException('Không có quyền xóa sản phẩm này');
    }
    const deleted = await this.prisma.product.update({
      where: { id: productId },
      data: { is_active: false },
    });
    return this.serializeProduct(deleted);
  }
}
