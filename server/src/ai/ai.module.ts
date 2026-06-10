import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';
import { StoresModule } from '../stores/stores.module';

@Module({
  imports: [ConfigModule, StoresModule],
  controllers: [AiController],
  providers: [AiService],
})
export class AiModule {}
