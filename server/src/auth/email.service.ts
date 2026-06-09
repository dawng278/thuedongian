import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class EmailService {
  private transporter: nodemailer.Transporter;

  constructor(private config: ConfigService) {
    this.transporter = nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 465,
      secure: true,
      auth: {
        user: this.config.get<string>('MAIL_USER'),
        pass: this.config.get<string>('MAIL_PASS'),
      },
    });
  }

  async sendOtp(to: string, otp: string): Promise<void> {
    const from = this.config.get<string>('MAIL_USER');
    try {
      await this.transporter.sendMail({
        from: `"TaxEasy" <${from}>`,
        to,
        subject: 'Mã OTP đặt lại mật khẩu TaxEasy',
        html: buildOtpEmail(otp),
      });
    } catch (err) {
      console.error('Gửi email thất bại:', err);
      throw new InternalServerErrorException('Không thể gửi email. Thử lại sau.');
    }
  }
}

function buildOtpEmail(otp: string): string {
  return `
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Đặt lại mật khẩu</title>
</head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f8;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="480" cellpadding="0" cellspacing="0"
               style="background:#ffffff;border-radius:12px;overflow:hidden;
                      box-shadow:0 2px 12px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:#1976D2;padding:32px 40px;text-align:center;">
              <h1 style="margin:0;color:#ffffff;font-size:22px;font-weight:700;
                         letter-spacing:0.5px;">TaxEasy</h1>
              <p style="margin:6px 0 0;color:#BBDEFB;font-size:13px;">
                Hỗ trợ hộ kinh doanh quản lý bán hàng &amp; hóa đơn điện tử
              </p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">
              <p style="margin:0 0 16px;color:#333;font-size:15px;line-height:1.6;">
                Xin chào,
              </p>
              <p style="margin:0 0 24px;color:#333;font-size:15px;line-height:1.6;">
                Chúng tôi nhận được yêu cầu <strong>đặt lại mật khẩu</strong>
                cho tài khoản TaxEasy của bạn. Dùng mã OTP dưới đây để tiếp tục:
              </p>

              <!-- OTP box -->
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center" style="padding:8px 0 28px;">
                    <div style="display:inline-block;background:#E3F2FD;
                                border:2px dashed #1976D2;border-radius:10px;
                                padding:18px 40px;">
                      <span style="font-size:36px;font-weight:800;
                                   letter-spacing:10px;color:#1976D2;
                                   font-family:'Courier New',monospace;">
                        ${otp}
                      </span>
                    </div>
                  </td>
                </tr>
              </table>

              <p style="margin:0 0 12px;color:#555;font-size:14px;line-height:1.6;">
                &#9201; Mã có hiệu lực trong <strong>10 phút</strong>.
              </p>
              <p style="margin:0 0 24px;color:#555;font-size:14px;line-height:1.6;">
                Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này.
                Tài khoản của bạn vẫn an toàn.
              </p>

              <hr style="border:none;border-top:1px solid #eee;margin:0 0 24px;" />

              <p style="margin:0;color:#999;font-size:12px;line-height:1.6;">
                Vì lý do bảo mật, không chia sẻ mã này với bất kỳ ai.
                TaxEasy sẽ không bao giờ hỏi mã OTP của bạn qua điện thoại hoặc chat.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background:#f4f6f8;padding:20px 40px;text-align:center;
                       border-top:1px solid #eee;">
              <p style="margin:0;color:#aaa;font-size:12px;">
                &copy; 2026 TaxEasy &mdash; IT Solution Challenge
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `.trim();
}
