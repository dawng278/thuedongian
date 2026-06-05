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
  ) {
    return this.reportsService.getRevenue(req.user.userId, from, to);
  }
}
