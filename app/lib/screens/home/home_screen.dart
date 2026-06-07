import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/invoices_provider.dart';
import '../../providers/revenue_provider.dart';
import '../../providers/stores_provider.dart';
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
  String? _activeStoreId;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoresProvider>().loadStores();
    });
  }

  void _bindStore(String storeId) {
    if (_activeStoreId == storeId) return;
    _activeStoreId = storeId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future.wait([
        context.read<ProductsProvider>().setStore(storeId),
        context.read<InvoicesProvider>().setStore(storeId),
        context.read<RevenueProvider>().setStore(storeId),
      ]);
    });
  }

  void _showStoreSwitcher() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Consumer<StoresProvider>(
        builder: (context, stores, _) {
          final current = stores.currentStore;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TaxEasyColors.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Chọn quán',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  ...stores.stores.map(
                    (store) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        current?.id == store.id
                            ? Icons.check_circle
                            : Icons.storefront_outlined,
                        color: current?.id == store.id
                            ? TaxEasyColors.primary
                            : TaxEasyColors.outline,
                      ),
                      title: Text(
                        store.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(_businessTypeLabel(store.businessType)),
                      onTap: () async {
                        await stores.switchStore(store);
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showCreateStoreSheet();
                    },
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Tạo quán mới'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateStoreSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _CreateStoreSheet(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stores = context.watch<StoresProvider>();
    final currentStore = stores.currentStore;
    final cs = Theme.of(context).colorScheme;

    if (stores.loading && currentStore == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentStore == null) {
      return _NoStoreView(onCreateStore: _showCreateStoreSheet);
    }

    _bindStore(currentStore.id);

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
        title: _StoreTitle(
            storeName: currentStore.name, onTap: _showStoreSwitcher),
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
          ? SaleScreen(key: ValueKey(currentStore.id))
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
  final VoidCallback onTap;

  const _StoreTitle({required this.storeName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
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

String _businessTypeLabel(String? value) {
  return switch (value) {
    'goods' => 'Hàng hóa',
    'services' => 'Dịch vụ',
    _ => 'Ăn uống',
  };
}

class _NoStoreView extends StatelessWidget {
  final VoidCallback onCreateStore;

  const _NoStoreView({required this.onCreateStore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaxEasyColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: TaxEasyColors.surfaceLow,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: TaxEasyColors.outlineVariant),
                    ),
                    child: const Icon(
                      Icons.add_business_outlined,
                      size: 64,
                      color: TaxEasyColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tạo quán đầu tiên',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: TaxEasyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Mỗi quán có sản phẩm, hóa đơn, báo cáo và thuế riêng.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.5,
                      color: TaxEasyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: onCreateStore,
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo quán'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateStoreSheet extends StatefulWidget {
  const _CreateStoreSheet();

  @override
  State<_CreateStoreSheet> createState() => _CreateStoreSheetState();
}

class _CreateStoreSheetState extends State<_CreateStoreSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _businessType = 'food_beverage';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<StoresProvider>().createStore(
            name: _nameCtrl.text,
            businessType: _businessType,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không tạo được quán: $e'),
            backgroundColor: TaxEasyColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TaxEasyColors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tạo quán mới',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên quán',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nhập tên quán'
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _businessType,
                decoration: const InputDecoration(
                  labelText: 'Loại hình kinh doanh',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'food_beverage', child: Text('Ăn uống')),
                  DropdownMenuItem(value: 'goods', child: Text('Hàng hóa')),
                  DropdownMenuItem(value: 'services', child: Text('Dịch vụ')),
                ],
                onChanged: (value) =>
                    setState(() => _businessType = value ?? 'food_beverage'),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.arrow_forward),
                label: Text(_loading ? 'Đang tạo...' : 'Tạo quán và bắt đầu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
