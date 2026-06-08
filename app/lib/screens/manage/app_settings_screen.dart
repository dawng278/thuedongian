import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/taxeasy_design.dart';
import 'help_screen.dart';

/// Trang Cài đặt ứng dụng: tuỳ chọn chung, thông tin app, hỗ trợ, đăng xuất.
/// Khác với "Cài đặt quán" (StoreSettingsScreen) — trang này là cấp ứng dụng.
class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  static const _appVersion = '0.1.0';

  // Tuỳ chọn cục bộ (demo) — rung khi bán, âm thanh xác nhận.
  bool _haptics = true;
  bool _sound = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          _sectionLabel('TÀI KHOẢN', cs),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.person, color: cs.onPrimaryContainer),
            ),
            title: Text(user?.name ?? 'Chủ quán',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(user?.email ?? ''),
          ),

          const SizedBox(height: 8),
          _sectionLabel('TRẢI NGHIỆM BÁN HÀNG', cs),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Rung phản hồi'),
            subtitle: const Text('Rung nhẹ khi chạm chọn món'),
            value: _haptics,
            onChanged: (v) => setState(() => _haptics = v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text('Âm thanh xác nhận'),
            subtitle: const Text('Phát tiếng khi tạo hóa đơn'),
            value: _sound,
            onChanged: (v) => setState(() => _sound = v),
          ),

          const SizedBox(height: 8),
          _sectionLabel('HỖ TRỢ', cs),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Hướng dẫn sử dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showGuide(context),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Trợ giúp & FAQ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Điều khoản & Quyền riêng tư'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTerms(context),
          ),

          const SizedBox(height: 8),
          _sectionLabel('VỀ ỨNG DỤNG', cs),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Phiên bản'),
            trailing: Text('v$_appVersion',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          const ListTile(
            leading: Icon(Icons.storefront_outlined),
            title: Text('TaxEasy'),
            subtitle: Text(
                'Hỗ trợ hộ kinh doanh quản lý bán hàng & hóa đơn điện tử'),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: Icon(Icons.logout, color: cs.error),
              label: Text('Đăng xuất', style: TextStyle(color: cs.error)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text('TaxEasy © 2026',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, ColorScheme cs) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(text,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.5)),
      );

  void _showGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: const [
            Text('Hướng dẫn nhanh',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 16),
            _GuideStep(
              icon: Icons.point_of_sale,
              title: 'Bán hàng',
              desc:
                  'Ở chế độ Bán hàng, chạm vào món để thêm vào đơn. Bấm giỏ hàng để thanh toán. Hoạt động cả khi mất mạng.',
            ),
            _GuideStep(
              icon: Icons.qr_code_2,
              title: 'Hóa đơn QR',
              desc:
                  'Sau khi thanh toán, bấm "Xem QR" để khách quét mã xem thông tin hóa đơn.',
            ),
            _GuideStep(
              icon: Icons.sync,
              title: 'Đồng bộ',
              desc:
                  'Đơn bán offline tự động đồng bộ lên server khi có mạng — không lo trùng số.',
            ),
            _GuideStep(
              icon: Icons.bar_chart,
              title: 'Quản lý',
              desc:
                  'Chuyển sang chế độ Quản lý để xem doanh thu, biểu đồ, thuế ước tính và xuất báo cáo.',
            ),
          ],
        ),
      ),
    );
  }

  void _showTerms(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Điều khoản & Quyền riêng tư'),
        content: const SingleChildScrollView(
          child: Text(
            'TaxEasy lưu dữ liệu bán hàng của bạn trên thiết bị và máy chủ để '
            'phục vụ quản lý kinh doanh và ước tính thuế.\n\n'
            'Dữ liệu hóa đơn được mã hóa khi truyền và chỉ bạn truy cập được '
            'qua tài khoản của mình. Ứng dụng không chia sẻ dữ liệu với bên '
            'thứ ba cho mục đích quảng cáo.\n\n'
            'Thuế ước tính chỉ mang tính tham khảo theo Thông tư 40/2021/TT-BTC, '
            'không thay thế tư vấn thuế chính thức.',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      context.read<AuthProvider>().logout();
    }
  }
}

class _GuideStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _GuideStep({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        height: 1.45, color: TaxEasyColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
