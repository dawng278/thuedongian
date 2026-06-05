import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('products')
@UseGuards(JwtAuthGuard)
export class ProductsController {
  constructor(private productsService: ProductsService) {}

  @Get()
  findAll(@Request() req: { user: { userId: string } }) {
    return this.productsService.findAll(req.user.userId);
  }

  @Post()
  create(
    @Request() req: { user: { userId: string } },
    @Body() dto: CreateProductDto,
  ) {
    return this.productsService.create(req.user.userId, dto);
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
