import {
  BadRequestException,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { AuthService } from './auth.service';

/**
 * Test logic auth thuần: login (sai/đúng mật khẩu) và luồng quên mật khẩu OTP.
 * Mock Prisma + JwtService + EmailService để không cần DB/SMTP thật.
 */
describe('AuthService', () => {
  describe('login', () => {
    it('email không tồn tại → UnauthorizedException', async () => {
      const prisma = {
        user: { findUnique: jest.fn().mockResolvedValue(null) },
      } as never;
      const jwt = { sign: jest.fn() } as never;
      const email = {} as never;

      const service = new AuthService(prisma, jwt, email);
      await expect(
        service.login({ email: 'x@y.z', password: '123456' }),
      ).rejects.toBeInstanceOf(UnauthorizedException);
    });

    it('sai mật khẩu → UnauthorizedException (không lộ "email tồn tại")', async () => {
      const hash = await bcrypt.hash('correct-pass', 10);
      const prisma = {
        user: {
          findUnique: jest.fn().mockResolvedValue({
            id: 'u1',
            email: 'a@b.c',
            name: 'A',
            password_hash: hash,
          }),
        },
      } as never;
      const jwt = { sign: jest.fn() } as never;
      const email = {} as never;

      const service = new AuthService(prisma, jwt, email);
      await expect(
        service.login({ email: 'a@b.c', password: 'wrong-pass' }),
      ).rejects.toBeInstanceOf(UnauthorizedException);
    });

    it('đúng mật khẩu → trả access_token + refresh_token + user', async () => {
      const hash = await bcrypt.hash('correct-pass', 10);
      const prisma = {
        user: {
          findUnique: jest.fn().mockResolvedValue({
            id: 'u1',
            email: 'a@b.c',
            name: 'A',
            password_hash: hash,
          }),
        },
      } as never;
      const jwt = { sign: jest.fn().mockReturnValue('signed-token') } as never;
      const email = {} as never;

      const service = new AuthService(prisma, jwt, email);
      const res = await service.login({
        email: 'a@b.c',
        password: 'correct-pass',
      });

      expect(res.access_token).toBe('signed-token');
      expect(res.refresh_token).toBe('signed-token');
      expect(res.user).toEqual({ id: 'u1', email: 'a@b.c', name: 'A' });
    });
  });

  describe('forgotPassword', () => {
    it('email không tồn tại → vẫn trả success, KHÔNG gửi email (không lộ email)', async () => {
      const prisma = {
        user: { findUnique: jest.fn().mockResolvedValue(null) },
        passwordResetOtp: { deleteMany: jest.fn(), create: jest.fn() },
      } as never;
      const jwt = {} as never;
      const sendOtp = jest.fn();
      const email = { sendOtp } as never;

      const service = new AuthService(prisma, jwt, email);
      const res = await service.forgotPassword({ email: 'ghost@x.z' });

      expect(res.message).toContain('Nếu email tồn tại');
      expect(sendOtp).not.toHaveBeenCalled();
    });

    it('email tồn tại → xóa OTP cũ, tạo OTP mới (đã hash) và gửi email', async () => {
      const deleteMany = jest.fn().mockResolvedValue({ count: 0 });
      const create = jest.fn().mockResolvedValue({});
      const sendOtp = jest.fn().mockResolvedValue(undefined);
      const prisma = {
        user: { findUnique: jest.fn().mockResolvedValue({ id: 'u1' }) },
        passwordResetOtp: { deleteMany, create },
      } as never;
      const jwt = {} as never;
      const email = { sendOtp } as never;

      const service = new AuthService(prisma, jwt, email);
      await service.forgotPassword({ email: 'a@b.c' });

      expect(deleteMany).toHaveBeenCalled();
      expect(create).toHaveBeenCalled();
      // OTP lưu xuống DB phải là hash, không phải plaintext 6 số.
      const stored = create.mock.calls[0][0].data.otp_hash as string;
      expect(stored).not.toMatch(/^\d{6}$/);
      // OTP gửi qua email phải là 6 chữ số.
      const sent = sendOtp.mock.calls[0][1] as string;
      expect(sent).toMatch(/^\d{6}$/);
    });
  });

  describe('resetPassword', () => {
    const baseDto = { email: 'a@b.c', otp: '123456', new_password: 'newpass1' };

    it('không có OTP nào → BadRequestException', async () => {
      const prisma = {
        passwordResetOtp: { findFirst: jest.fn().mockResolvedValue(null) },
      } as never;
      const service = new AuthService(prisma, {} as never, {} as never);
      await expect(service.resetPassword(baseDto)).rejects.toBeInstanceOf(
        BadRequestException,
      );
    });

    it('OTP đã hết hạn → BadRequestException', async () => {
      const prisma = {
        passwordResetOtp: {
          findFirst: jest.fn().mockResolvedValue({
            id: 'otp1',
            otp_hash: await bcrypt.hash('123456', 10),
            expires_at: new Date(Date.now() - 1000), // quá khứ
          }),
        },
      } as never;
      const service = new AuthService(prisma, {} as never, {} as never);
      await expect(service.resetPassword(baseDto)).rejects.toBeInstanceOf(
        BadRequestException,
      );
    });

    it('OTP sai → BadRequestException', async () => {
      const prisma = {
        passwordResetOtp: {
          findFirst: jest.fn().mockResolvedValue({
            id: 'otp1',
            otp_hash: await bcrypt.hash('999999', 10), // hash của OTP khác
            expires_at: new Date(Date.now() + 60_000),
          }),
        },
      } as never;
      const service = new AuthService(prisma, {} as never, {} as never);
      await expect(service.resetPassword(baseDto)).rejects.toBeInstanceOf(
        BadRequestException,
      );
    });

    it('OTP đúng + còn hạn → cập nhật mật khẩu trong transaction, đánh dấu used', async () => {
      const userUpdate = jest.fn();
      const otpUpdate = jest.fn();
      const $transaction = jest.fn().mockResolvedValue([]);
      const prisma = {
        passwordResetOtp: {
          findFirst: jest.fn().mockResolvedValue({
            id: 'otp1',
            otp_hash: await bcrypt.hash('123456', 10),
            expires_at: new Date(Date.now() + 60_000),
          }),
          update: otpUpdate,
        },
        user: {
          findUnique: jest.fn().mockResolvedValue({ id: 'u1' }),
          update: userUpdate,
        },
        $transaction,
      } as never;
      const service = new AuthService(prisma, {} as never, {} as never);

      const res = await service.resetPassword(baseDto);
      expect(res.message).toContain('thành công');
      // Cập nhật mật khẩu + đánh dấu used phải nằm trong 1 transaction.
      expect($transaction).toHaveBeenCalledTimes(1);
      expect(userUpdate).toHaveBeenCalled();
      expect(otpUpdate).toHaveBeenCalledWith({
        where: { id: 'otp1' },
        data: { used: true },
      });
    });

    it('OTP đúng nhưng user đã bị xóa → NotFoundException', async () => {
      const prisma = {
        passwordResetOtp: {
          findFirst: jest.fn().mockResolvedValue({
            id: 'otp1',
            otp_hash: await bcrypt.hash('123456', 10),
            expires_at: new Date(Date.now() + 60_000),
          }),
        },
        user: { findUnique: jest.fn().mockResolvedValue(null) },
      } as never;
      const service = new AuthService(prisma, {} as never, {} as never);
      await expect(service.resetPassword(baseDto)).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });
  });
});
