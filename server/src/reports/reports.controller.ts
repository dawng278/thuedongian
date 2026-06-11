import { Controller, Get, Query, UseGuards, Request } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('reports')
@UseGuards(JwtAuthGuard)
export class ReportsController {
  constructor(private reportsService: ReportsService) {}

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
}
