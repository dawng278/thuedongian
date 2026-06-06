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
import '../../theme/taxeasy_design.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor:
          _isSaleMode ? TaxEasyColors.surface : TaxEasyColors.background,
      appBar: AppBar(
        backgroundColor: TaxEasyColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        scrolledUnderElevation: 2,
        // Gradient bottom border line
        flexibleSpace: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(gradient: TaxEasyGradients.horizontal),
              child: SizedBox(height: 3, width: double.infinity),
            ),
          ],
        ),
        title: _StoreTitle(storeName: storeName),
        actions: [
          // Mode toggle pill
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
                child: Row(children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Đăng xuất')
                ]),
              ),
            ],
          ),
        ],
        bottom: _isSaleMode
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: cs.primary,
                indicatorWeight: 2,
                labelColor: cs.primary,
                unselectedLabelColor: cs.onSurfaceVariant,
                labelStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(
                      icon: Icon(Icons.payments_outlined, size: 20),
                      text: 'Doanh thu'),
                  Tab(
                      icon: Icon(Icons.receipt_long_outlined, size: 20),
                      text: 'Thuế'),
                  Tab(
                      icon: Icon(Icons.inventory_2_outlined, size: 20),
                      text: 'Sản phẩm'),
                  Tab(
                      icon: Icon(Icons.history_outlined, size: 20),
                      text: 'Hóa đơn'),
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          decoration: BoxDecoration(
            color: TaxEasyColors.surfaceLow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: TaxEasyColors.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PillTab(
                label: 'Bán hàng',
                isActive: isSaleMode,
                cs: cs,
              ),
              _PillTab(
                label: 'Quản lý',
                isActive: !isSaleMode,
                cs: cs,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreTitle extends StatelessWidget {
  final String storeName;

  const _StoreTitle({required this.storeName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Chọn / tạo thêm quán sẽ được mở ở bước tiếp theo')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TaxEasyColors.surfaceLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TaxEasyColors.outlineVariant),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 18,
                color: TaxEasyColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                storeName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: TaxEasyColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down,
                size: 20, color: TaxEasyColors.outline),
          ],
        ),
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final ColorScheme cs;

  const _PillTab(
      {required this.label, required this.isActive, required this.cs});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? cs.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1))
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : cs.onSurfaceVariant,
        ),
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
        child: const Icon(Icons.sync_outlined),
      ),
      tooltip: 'Đồng bộ $pending hóa đơn offline',
      onPressed: () async {
        final result = await context.read<InvoicesProvider>().syncPending();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Đồng bộ: ${result.synced} thành công, ${result.errors} lỗi'),
              backgroundColor: result.errors > 0
                  ? const Color(0xFFD97706)
                  : const Color(0xFF059669),
            ),
          );
        }
      },
    );
  }
}
