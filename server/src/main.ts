import { NestFactory } from '@nestjs/core';
import { Logger, ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/all-exceptions.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const corsOrigin = process.env.CORS_ORIGIN ?? '*';
  app.enableCors({ origin: corsOrigin === '*' ? true : corsOrigin.split(',') });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.useGlobalFilters(new AllExceptionsFilter());
  const port = process.env.PORT ?? 3000;
  // Bind 0.0.0.0 để điện thoại trong cùng LAN truy cập được (không chỉ localhost).
  await app.listen(port, '0.0.0.0');
  Logger.log(
    `TaxEasy API đang chạy tại http://0.0.0.0:${port} (truy cập LAN qua IP máy)`,
    'Bootstrap',
  );
}
void bootstrap();
