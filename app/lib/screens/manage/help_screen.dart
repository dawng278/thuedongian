import 'package:flutter/material.dart';

import '../../theme/taxeasy_design.dart';

/// Trang Trợ giúp & FAQ: câu hỏi thường gặp dạng accordion + liên hệ hỗ trợ.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    _Faq(
      q: 'Bán hàng khi mất mạng có được không?',
      a: 'Được. Mọi đơn bán đều lưu vào máy trước, rồi tự động đồng bộ lên '
          'server khi có mạng trở lại. Số hóa đơn không bị trùng nhờ mã định '
          'danh sinh ở máy.',
    ),
    _Faq(
      q: 'Làm sao xuất hóa đơn điện tử (XML)?',
      a: 'Mở Quản lý → Hóa đơn → chọn một hóa đơn → nút "Xuất XML". File lưu '
          'vào thư mục Download. Lưu ý: quán cần khai báo Mã số thuế (MST) '
          'trong Cài đặt quán trước.',
    ),
    _Faq(
      q: 'Thuế ước tính tính theo công thức nào?',
      a: 'Theo Thông tư 40/2021/TT-BTC: thuế khoán hộ kinh doanh = (tỷ lệ '
          'GTGT + tỷ lệ TNCN) trên doanh thu. Miễn thuế nếu doanh thu cả năm '
          'dưới 100 triệu đồng. Con số chỉ mang tính tham khảo.',
    ),
    _Faq(
      q: 'Một tài khoản quản lý được nhiều quán không?',
      a: 'Có. Mỗi quán có sản phẩm, hóa đơn, báo cáo và thuế riêng. Chuyển '
          'quán ở mục "Chuyển quán" trong Tài khoản hoặc chạm tên quán ở '
          'thanh trên cùng.',
    ),
    _Faq(
      q: 'Khách quét QR hóa đơn để làm gì?',
      a: 'QR chứa thông tin tóm tắt hóa đơn (số, ngày, tổng tiền, số món). '
          'Khách quét để xem lại đơn hàng, tiện đối chiếu.',
    ),
    _Faq(
      q: 'Dữ liệu của tôi có an toàn không?',
      a: 'Dữ liệu được mã hóa khi truyền và chỉ truy cập được qua tài khoản '
          'của bạn. Ứng dụng không chia sẻ dữ liệu cho bên thứ ba vì mục đích '
          'quảng cáo.',
    ),
    _Faq(
      q: 'Quên mật khẩu thì làm sao?',
      a: 'Ở màn hình đăng nhập, chạm "Quên mật khẩu?" và làm theo hướng dẫn: '
          'nhập email → nhận mã OTP → đặt mật khẩu mới.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      appBar: AppBar(title: const Text('Trợ giúp & FAQ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: TaxEasyGradients.brand,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent, color: Colors.white, size: 40),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chúng tôi luôn sẵn sàng hỗ trợ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('Tìm câu trả lời nhanh bên dưới',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('CÂU HỎI THƯỜNG GẶP',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          ..._faqs.map((f) => _FaqTile(faq: f)),

          const SizedBox(height: 24),
          Text('LIÊN HỆ',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          _ContactCard(
            icon: Icons.email_outlined,
            title: 'Email hỗ trợ',
            value: 'hotro@taxeasy.vn',
            cs: cs,
          ),
          _ContactCard(
            icon: Icons.phone_outlined,
            title: 'Hotline',
            value: '1900 1234 (8h–20h)',
            cs: cs,
          ),
          _ContactCard(
            icon: Icons.bug_report_outlined,
            title: 'Báo lỗi / Góp ý',
            value: 'gopy@taxeasy.vn',
            cs: cs,
          ),
        ],
      ),
    );
  }
}

class _Faq {
  final String q;
  final String a;
  const _Faq({required this.q, required this.a});
}

class _FaqTile extends StatelessWidget {
  final _Faq faq;
  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: TaxEasyColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TaxEasyColors.outlineVariant),
      ),
      child: Theme(
        // Bỏ đường kẻ mặc định của ExpansionTile.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(faq.q,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)),
          iconColor: TaxEasyColors.primary,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(faq.a,
                  style: const TextStyle(
                      height: 1.5, color: TaxEasyColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final ColorScheme cs;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaxEasyColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TaxEasyColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: TaxEasyColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: TaxEasyColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
