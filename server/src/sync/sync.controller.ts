import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { SyncService } from './sync.service';
import { SyncInvoicesDto } from './dto/sync-invoices.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('sync')
@UseGuards(JwtAuthGuard)
export class SyncController {
  constructor(private syncService: SyncService) {}

  @Post('invoices')
  syncInvoices(
    @Request() req: { user: { userId: string } },
    @Body() dto: SyncInvoicesDto,
  ) {
    return this.syncService.syncInvoices(req.user.userId, dto);
  }
}
