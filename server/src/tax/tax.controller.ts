import { Controller, Get, Query, UseGuards, Request } from '@nestjs/common';
import { TaxService } from './tax.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('tax')
@UseGuards(JwtAuthGuard)
export class TaxController {
  constructor(private taxService: TaxService) {}

  @Get('estimate')
  estimate(
    @Request() req: { user: { userId: string } },
    @Query('period') period?: string,
    @Query('store_id') storeId?: string,
  ) {
    return this.taxService.estimate(req.user.userId, period, storeId);
  }

  @Get('deadlines')
  getDeadlines() {
    return this.taxService.getDeadlines();
  }
}
