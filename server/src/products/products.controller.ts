import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('products')
@UseGuards(JwtAuthGuard)
export class ProductsController {
  constructor(private productsService: ProductsService) {}

  @Get()
  findAll(
    @Request() req: { user: { userId: string } },
    @Query('store_id') storeId?: string,
    @Query('include_inactive') includeInactive?: string,
  ) {
    return this.productsService.findAll(
      req.user.userId,
      storeId,
      includeInactive === 'true',
    );
  }

  @Post()
  create(
    @Request() req: { user: { userId: string } },
    @Body() dto: CreateProductDto,
    @Query('store_id') storeId?: string,
  ) {
    return this.productsService.create(req.user.userId, dto, storeId);
  }

  @Put(':id')
  update(
    @Request() req: { user: { userId: string } },
    @Param('id') id: string,
    @Body() dto: UpdateProductDto,
  ) {
    return this.productsService.update(req.user.userId, id, dto);
  }

  @Delete(':id')
  softDelete(
    @Request() req: { user: { userId: string } },
    @Param('id') id: string,
  ) {
    return this.productsService.softDelete(req.user.userId, id);
  }
}
