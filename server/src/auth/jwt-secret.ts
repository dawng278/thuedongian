import { ConfigService } from '@nestjs/config';

/**
 * Lấy JWT_SECRET, fail-fast nếu thiếu hoặc dùng giá trị mặc định không an toàn.
 * Không bao giờ fallback sang secret hardcode — token giả mạo được nếu prod quên set.
 */
export function getJwtSecret(config: ConfigService): string {
  const secret = config.get<string>('JWT_SECRET');
  if (!secret || secret.trim().length < 16) {
    throw new Error(
      'JWT_SECRET chưa được cấu hình (cần >= 16 ký tự). ' +
        'Đặt biến môi trường JWT_SECRET trong server/.env trước khi khởi động.',
    );
  }
  return secret;
}
