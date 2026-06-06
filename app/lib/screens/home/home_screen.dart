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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        scrolledUnderElevation: 2,
        // Gradient bottom border line
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF40C2FD)],
                ),
              ),
            ),
          ],
        ),
        title: _isSaleMode
            ? GestureDetector(
                onTap: () {}, // future: store picker
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.expand_more, size: 18, color: Color(0xFF737686)),
                  ],
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.store, size: 20, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(
                    'TaxEasy',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
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
                child: Row(children: [Icon(Icons.logout), SizedBox(width: 8), Text('Đăng xuất')]),
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
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(icon: Icon(Icons.payments_outlined, size: 20), text: 'Doanh thu'),
                  Tab(icon: Icon(Icons.receipt_long_outlined, size: 20), text: 'Thuế'),
                  Tab(icon: Icon(Icons.inventory_2_outlined, size: 20), text: 'Sản phẩm'),
                  Tab(icon: Icon(Icons.history_outlined, size: 20), text: 'Hóa đơn'),
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
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFC3C6D7)),
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

class _PillTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final ColorScheme cs;

  const _PillTab({required this.label, required this.isActive, required this.cs});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? cs.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: isActive
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 1))]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isActive ? cs.onPrimaryContainer : cs.onSurfaceVariant,
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
              content: Text('Đồng bộ: ${result.synced} thành công, ${result.errors} lỗi'),
              backgroundColor: result.errors > 0 ? const Color(0xFFD97706) : const Color(0xFF059669),
            ),
          );
        }
      },
    );
  }
}
