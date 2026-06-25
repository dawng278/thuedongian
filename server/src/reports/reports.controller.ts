import { Controller, Get, Query, UseGuards, Request, Res } from '@nestjs/common';
import type { Response } from 'express';
import { ReportsService } from './reports.service';
import { ReportsXmlService } from './reports-xml.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('reports')
@UseGuards(JwtAuthGuard)
export class ReportsController {
  constructor(
    private reportsService: ReportsService,
    private reportsXmlService: ReportsXmlService,
  ) {}

  @Get('revenue')
  getRevenue(
    @Request() req: { user: { userId: string } },
    @Query('from') from?: string,
    @Query('to') to?: string,
    @Query('store_id') storeId?: string,
  ) {
    return this.reportsService.getRevenue(req.user.userId, from, to, storeId);
  }

  // Dữ liệu biểu đồ doanh thu theo mốc thời gian:
  // week = 7 ngày gần nhất, month = 30 ngày, year = 12 tháng gần nhất.
  @Get('chart')
  getChart(
    @Request() req: { user: { userId: string } },
    @Query('granularity') granularity?: string,
    @Query('store_id') storeId?: string,
  ) {
    return this.reportsService.getChart(
      req.user.userId,
      granularity ?? 'week',
      storeId,
    );
  }

  @Get('period')
  getPeriodReport(
    @Request() req: { user: { userId: string } },
    @Query('from') from: string,
    @Query('to') to: string,
    @Query('store_id') storeId?: string,
  ) {
    return this.reportsService.getPeriodReport(
      req.user.userId,
      from,
      to,
      storeId,
    );
  }

  @Get('period/xml')
  async exportPeriodXml(
    @Request() req: { user: { userId: string } },
    @Query('from') from: string,
    @Query('to') to: string,
    @Query('store_id') storeId: string | undefined,
    @Res() res: Response,
  ) {
    const report = await this.reportsService.getPeriodReport(
      req.user.userId,
      from,
      to,
      storeId,
    );
    const xml = this.reportsXmlService.buildXml(report);
    res.setHeader('Content-Type', 'application/xml; charset=utf-8');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="thuedongian-report-${from}-${to}.xml"`,
    );
    res.send(xml);
  }
}
