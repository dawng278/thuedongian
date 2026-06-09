import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { EmailService } from './email.service';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private emailService: EmailService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });
    if (existing) throw new ConflictException('Email đã tồn tại');

    const hash = await bcrypt.hash(dto.password, 10);
    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        password_hash: hash,
        name: dto.name,
      },
    });

    return this.issueTokens(user);
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });
    if (!user)
      throw new UnauthorizedException('Email hoặc mật khẩu không đúng');

    const valid = await bcrypt.compare(dto.password, user.password_hash);
    if (!valid)
      throw new UnauthorizedException('Email hoặc mật khẩu không đúng');

    return this.issueTokens(user);
  }

  async refresh(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new UnauthorizedException();
    return this.issueTokens(user);
  }

  /// Lấy thông tin hồ sơ người dùng hiện tại.
  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('Không tìm thấy người dùng');
    return { id: user.id, email: user.email, name: user.name };
  }

  /// Cập nhật tên/email. Kiểm tra email mới không trùng người khác.
  async updateProfile(userId: string, dto: UpdateProfileDto) {
    if (dto.email) {
      const existing = await this.prisma.user.findUnique({
        where: { email: dto.email },
      });
      if (existing && existing.id !== userId) {
        throw new ConflictException('Email đã được dùng bởi tài khoản khác');
      }
    }
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: {
        ...(dto.name !== undefined ? { name: dto.name } : {}),
        ...(dto.email !== undefined ? { email: dto.email } : {}),
      },
    });
    return { id: user.id, email: user.email, name: user.name };
  }

  /// Đổi mật khẩu: xác minh mật khẩu hiện tại trước khi đặt mật khẩu mới.
  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('Không tìm thấy người dùng');

    const valid = await bcrypt.compare(
      dto.current_password,
      user.password_hash,
    );
    if (!valid) {
      throw new UnauthorizedException('Mật khẩu hiện tại không đúng');
    }
    const hash = await bcrypt.hash(dto.new_password, 10);
    await this.prisma.user.update({
      where: { id: userId },
      data: { password_hash: hash },
    });
    return { success: true };
  }

  async forgotPassword(dto: ForgotPasswordDto): Promise<{ message: string }> {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email } });
    // Luôn trả success để không lộ email có tồn tại hay không
    if (!user) return { message: 'Nếu email tồn tại, mã OTP đã được gửi.' };

    const otp = String(Math.floor(100000 + Math.random() * 900000));
    const otpHash = await bcrypt.hash(otp, 10);
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 phút

    // Xóa OTP cũ chưa dùng của email này
    await this.prisma.passwordResetOtp.deleteMany({
      where: { email: dto.email, used: false },
    });

    await this.prisma.passwordResetOtp.create({
      data: { email: dto.email, otp_hash: otpHash, expires_at: expiresAt },
    });

    await this.emailService.sendOtp(dto.email, otp);
    return { message: 'Nếu email tồn tại, mã OTP đã được gửi.' };
  }

  async resetPassword(dto: ResetPasswordDto): Promise<{ message: string }> {
    const record = await this.prisma.passwordResetOtp.findFirst({
      where: { email: dto.email, used: false },
      orderBy: { created_at: 'desc' },
    });

    if (!record) throw new BadRequestException('OTP không hợp lệ hoặc đã hết hạn');
    if (record.expires_at < new Date()) {
      throw new BadRequestException('OTP đã hết hạn. Vui lòng yêu cầu mã mới.');
    }

    const valid = await bcrypt.compare(dto.otp, record.otp_hash);
    if (!valid) throw new BadRequestException('OTP không đúng');

    const user = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (!user) throw new NotFoundException('Không tìm thấy người dùng');

    const newHash = await bcrypt.hash(dto.new_password, 10);

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: user.id },
        data: { password_hash: newHash },
      }),
      this.prisma.passwordResetOtp.update({
        where: { id: record.id },
        data: { used: true },
      }),
    ]);

    return { message: 'Đặt lại mật khẩu thành công' };
  }

  private issueTokens(user: { id: string; email: string; name: string }) {
    const payload = { sub: user.id, email: user.email };
    return {
      access_token: this.jwtService.sign(payload, { expiresIn: '1h' }),
      refresh_token: this.jwtService.sign(payload, { expiresIn: '7d' }),
      user: { id: user.id, email: user.email, name: user.name },
    };
  }
}
