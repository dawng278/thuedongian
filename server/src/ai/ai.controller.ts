import { Controller, Get, Query, Request, UseGuards } from '@nestjs/common';
import { Throttle, ThrottlerGuard } from '@nestjs/throttler';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AiService } from './ai.service';

@Controller('ai')
@UseGuards(JwtAuthGuard)
export class AiController {
  constructor(private aiService: AiService) {}

  // Tối đa 10 lần/phút — gọi Claude API tốn tiền, tránh spam.
  @Get('insights')
  @UseGuards(ThrottlerGuard)
  @Throttle({ default: { ttl: 60_000, limit: 10 } })
  getInsights(
    @Request() req: { user: { userId: string } },
    @Query('store_id') storeId?: string,
  ) {
    return this.aiService.getInsights(req.user.userId, storeId);
  }
}
