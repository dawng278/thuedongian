import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/invoices_provider.dart';
import '../sale/sale_screen.dart';
import '../manage/product_manage_screen.dart';
import '../manage/revenue_screen.dart';
import '../manage/invoice_history_screen.dart';
import '../manage/tax_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isSaleMode = true;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final storeName = auth.store?.name ?? 'Cửa hàng của tôi';
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSaleMode ? storeName : 'Quản lý'),
        backgroundColor: color.inversePrimary,
        actions: [
          // Mode toggle button
          _ModeToggle(
            isSaleMode: _isSaleMode,
            onToggle: () => setState(() => _isSaleMode = !_isSaleMode),
          ),
          _SyncBadge(),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'logout') await context.read<AuthProvider>().logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [Icon(Icons.logout), SizedBox(width: 8), Text('Đăng xuất')]),
              ),
            ],
          ),
        ],
        bottom: _isSaleMode
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.analytics_outlined), text: 'Doanh thu'),
                  Tab(icon: Icon(Icons.calculate_outlined), text: 'Thuế'),
                  Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Sản phẩm'),
                  Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Hóa đơn'),
                ],
              ),
      ),
      body: _isSaleMode
          ? const SaleScreen()
          : TabBarView(
              controller: _tabController,
              children: const [
                RevenueScreen(),
                TaxScreen(),
                ProductManageScreen(),
                InvoiceHistoryScreen(),
              ],
            ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool isSaleMode;
  final VoidCallback onToggle;

  const _ModeToggle({required this.isSaleMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: isSaleMode
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: isSaleMode
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSecondaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        icon: Icon(isSaleMode ? Icons.point_of_sale : Icons.manage_accounts, size: 18),
        label: Text(isSaleMode ? 'Bán hàng' : 'Quản lý', style: const TextStyle(fontSize: 13)),
        onPressed: onToggle,
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pending = context.watch<InvoicesProvider>().pendingCount;
    if (pending == 0) return const SizedBox.shrink();
    return IconButton(
      icon: Badge(
        label: Text('$pending'),
        child: const Icon(Icons.cloud_upload_outlined),
      ),
      tooltip: 'Đồng bộ $pending hóa đơn offline',
      onPressed: () async {
        final result = await context.read<InvoicesProvider>().syncPending();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đồng bộ: ${result.synced} thành công, ${result.errors} lỗi'),
              backgroundColor: result.errors > 0 ? Colors.orange : Colors.green,
            ),
          );
        }
      },
    );
  }
}
