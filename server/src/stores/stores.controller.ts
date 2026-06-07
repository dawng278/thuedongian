import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { StoresService } from './stores.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateStoreDto, UpdateStoreDto } from './dto/create-store.dto';

@Controller('stores')
@UseGuards(JwtAuthGuard)
export class StoresController {
  constructor(private storesService: StoresService) {}

  @Get()
  listStores(@Request() req: { user: { userId: string } }) {
    return this.storesService.listStores(req.user.userId);
  }

  @Post()
  createStore(
    @Request() req: { user: { userId: string } },
    @Body() dto: CreateStoreDto,
  ) {
    return this.storesService.createStore(req.user.userId, dto);
  }

  @Get('me')
  getMyStore(@Request() req: { user: { userId: string } }) {
    return this.storesService.getMyStore(req.user.userId);
  }

  @Get(':id')
  getStore(
    @Request() req: { user: { userId: string } },
    @Param('id') id: string,
  ) {
    return this.storesService.getStore(req.user.userId, id);
  }

  @Patch('me')
  updateStore(
    @Request() req: { user: { userId: string } },
    @Body() body: UpdateStoreDto,
  ) {
    return this.storesService.updateStore(req.user.userId, body);
  }
}
