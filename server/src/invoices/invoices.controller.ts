import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, Request, MethodNotAllowedException, Header, Res } from '@nestjs/common';
import type { Response } from 'express';
import { InvoicesService } from './invoices.service';
import { CreateInvoiceDto } from './dto/create-invoice.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('invoices')
@UseGuards(JwtAuthGuard)
export class InvoicesController {
  constructor(private invoicesService: InvoicesService) {}

  @Post()
  create(
    @Request() req: { user: { userId: string } },
    @Body() dto: CreateInvoiceDto,
  ) {
    return this.invoicesService.create(req.user.userId, dto);
  }

  @Get()
  findAll(
    @Request() req: { user: { userId: string } },
    @Query('from') from?: string,
    @Query('to') to?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.invoicesService.findAll(
      req.user.userId,
      from,
      to,
      page ? parseInt(page) : 1,
      limit ? parseInt(limit) : 20,
    );
  }

  @Get(':id')
  findOne(
    @Request() req: { user: { userId: string } },
    @Param('id') id: string,
  ) {
    return this.invoicesService.findOne(req.user.userId, id);
  }

  @Get(':id/xml')
  async exportXml(
    @Request() req: { user: { userId: string } },
    @Param('id') id: string,
    @Res() res: Response,
  ) {
    const xml = await this.invoicesService.exportXml(req.user.userId, id);
    res.setHeader('Content-Type', 'application/xml; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="invoice-${id}.xml"`);
    res.send(xml);
  }

  // Invoices are immutable — no edit or delete
  @Patch(':id')
  patchNotAllowed() {
    throw new MethodNotAllowedException('Hóa đơn không thể sửa sau khi tạo');
  }

  @Delete(':id')
  deleteNotAllowed() {
    throw new MethodNotAllowedException('Hóa đơn không thể xóa');
  }
}
