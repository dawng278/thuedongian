import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/stores_provider.dart';
import '../../theme/taxeasy_design.dart';
import 'app_settings_screen.dart';
import 'edit_profile_screen.dart';
import 'store_settings_screen.dart';

/// Trang Tài khoản: thông tin người dùng, quán hiện tại, chuyển quán,
/// vào cài đặt quán, và đăng xuất. Điểm điều hướng rõ ràng cho chủ quán.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _businessTypeLabel(String? v) {
    switch (v) {
      case 'goods':
        return 'Hàng hóa';
      case 'services':
        return 'Dịch vụ';
      case 'food_beverage':
      default:
        return 'Ăn uống';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final stores = context.watch<StoresProvider>();
    final user = auth.user;
    final current = stores.currentStore;

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          // Hồ sơ người dùng
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.person, size: 40, color: cs.onPrimaryContainer),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? 'Chủ quán',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(user?.email ?? '',
                    style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quán hiện tại
          _sectionLabel('QUÁN HIỆN TẠI', cs),
          if (current != null)
            ListTile(
              leading: Icon(Icons.storefront_outlined, color: cs.primary),
              title: Text(current.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                '${_businessTypeLabel(current.businessType)}'
                '${current.taxId != null && current.taxId!.isNotEmpty ? " · MST ${current.taxId}" : " · Chưa có MST"}',
              ),
            ),
          // Cảnh báo thiếu MST
          if (current != null &&
              (current.taxId == null || current.taxId!.isEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chưa khai báo MST — cần để xuất hóa đơn điện tử',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF7A4100)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),
          _sectionLabel('CÀI ĐẶT', cs),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Chỉnh sửa hồ sơ'),
            subtitle: const Text('Tên, email, mật khẩu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EditProfileScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: const Text('Cài đặt quán'),
            subtitle: const Text('Tên, MST, địa chỉ, loại hình'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const StoreSettingsScreen(),
              ),
            ),
          ),
          if (stores.stores.length > 1)
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Chuyển quán'),
              subtitle: Text('${stores.stores.length} quán'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showStoreSwitcher(context, stores),
            ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt ứng dụng'),
            subtitle: const Text('Trải nghiệm, hỗ trợ, về ứng dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AppSettingsScreen(),
              ),
            ),
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
          const SizedBox(height: 24),
          Center(
            child: Text('TaxEasy 2026',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, ColorScheme cs) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(text,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.5)),
      );

  void _showStoreSwitcher(BuildContext context, StoresProvider stores) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: stores.stores.map((s) {
            final isCurrent = s.id == stores.currentStore?.id;
            return ListTile(
              leading: Icon(
                isCurrent ? Icons.check_circle : Icons.storefront_outlined,
                color: isCurrent ? TaxEasyColors.primary : TaxEasyColors.outline,
              ),
              title: Text(s.name),
              onTap: () async {
                await stores.switchStore(s);
                if (sheetCtx.mounted) Navigator.pop(sheetCtx);
              },
            );
          }).toList(),
        ),
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
