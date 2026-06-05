import { Controller, Get, Patch, Body, UseGuards, Request } from '@nestjs/common';
import { StoresService } from './stores.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('stores')
@UseGuards(JwtAuthGuard)
export class StoresController {
  constructor(private storesService: StoresService) {}

  @Get('me')
  getMyStore(@Request() req: { user: { userId: string } }) {
    return this.storesService.getMyStore(req.user.userId);
  }

  @Patch('me')
  updateStore(
    @Request() req: { user: { userId: string } },
    @Body() body: Partial<{ name: string; tax_id: string; address: string; phone: string }>,
  ) {
    return this.storesService.updateStore(req.user.userId, body);
  }
}
