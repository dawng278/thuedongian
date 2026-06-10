import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { Request, Response } from 'express';

/**
 * Bắt mọi exception và trả về envelope nhất quán:
 *   { statusCode, message, timestamp, path }
 *
 * Map lỗi Prisma đã biết sang HTTP code phù hợp, không rò stack trace ra client.
 * Log lỗi 5xx kèm stack để debug phía server.
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger('Exception');

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message: string | string[] = 'Lỗi máy chủ nội bộ';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const res = exception.getResponse();
      message =
        typeof res === 'string'
          ? res
          : ((res as { message?: string | string[] }).message ??
            exception.message);
    } else if (exception instanceof Prisma.PrismaClientKnownRequestError) {
      switch (exception.code) {
        case 'P2002': // unique constraint
          status = HttpStatus.CONFLICT;
          message = 'Dữ liệu đã tồn tại';
          break;
        case 'P2025': // record not found
          status = HttpStatus.NOT_FOUND;
          message = 'Không tìm thấy dữ liệu';
          break;
        case 'P2003': // foreign key constraint
          status = HttpStatus.BAD_REQUEST;
          message = 'Dữ liệu tham chiếu không hợp lệ';
          break;
        default:
          // Log code để debug
          this.logger.error(
            `Prisma known error ${exception.code}: ${request.method} ${request.url}`,
            exception.message,
          );
          status = HttpStatus.BAD_REQUEST;
          message = 'Yêu cầu không hợp lệ';
      }
    } else if (exception instanceof Prisma.PrismaClientValidationError) {
      status = HttpStatus.BAD_REQUEST;
      message = 'Dữ liệu gửi lên không hợp lệ';
    } else if (exception instanceof Prisma.PrismaClientInitializationError) {
      // DB unreachable (sai port, chưa start, v.v.)
      status = HttpStatus.SERVICE_UNAVAILABLE;
      message = 'Không kết nối được cơ sở dữ liệu';
      this.logger.error(
        `DB init error ${exception.errorCode}: ${request.method} ${request.url}`,
        exception.message,
      );
    }

    if (status >= 500) {
      this.logger.error(
        `${request.method} ${request.url} -> ${status}`,
        exception instanceof Error ? exception.stack : String(exception),
      );
    } else {
      this.logger.warn(`${request.method} ${request.url} -> ${status}`);
    }

    response.status(status).json({
      statusCode: status,
      message,
      timestamp: new Date().toISOString(),
      path: request.url,
    });
  }
}
