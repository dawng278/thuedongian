import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/invoices_provider.dart';
import '../../providers/revenue_provider.dart';
import '../../providers/stores_provider.dart';
import '../sale/sale_screen.dart';
import '../sale/pending_sync_screen.dart';
import '../manage/product_manage_screen.dart';
import '../manage/revenue_screen.dart';
import '../manage/invoice_history_screen.dart';
import '../manage/tax_screen.dart';
import '../manage/store_settings_screen.dart';
import '../manage/profile_screen.dart';
import '../manage/inventory_screen.dart';
import '../../theme/taxeasy_design.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSaleMode = true;
  String? _activeStoreId;
  int _manageTabIndex = 0;

  @override
  void initState() {
    super.initState();
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
      ], eagerError: false);
    });
  }

  void _showStoreSwitcher() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Consumer<StoresProvider>(
        builder: (context, stores, _) {
          final current = stores.currentStore;
          // Giới hạn chiều cao tối đa ~85% màn hình; danh sách quán cuộn được.
          final maxH = MediaQuery.of(sheetContext).size.height * 0.85;
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
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
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: stores.stores
                            .map(
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                subtitle:
                                    Text(_businessTypeLabel(store.businessType)),
                                onTap: () async {
                                  await stores.switchStore(store);
                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (current != null)
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const StoreSettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Cài đặt quán hiện tại'),
                      ),
                    const SizedBox(height: 8),
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

  Widget _manageBody() {
    return switch (_manageTabIndex) {
      0 => const RevenueScreen(),
      1 => const TaxScreen(),
      2 => const ProductManageScreen(),
      3 => const InvoiceHistoryScreen(),
      _ => const RevenueScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final stores = context.watch<StoresProvider>();
    final currentStore = stores.currentStore;

    if (stores.loading && currentStore == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentStore == null) {
      return _NoStoreView(onCreateStore: _showCreateStoreSheet);
    }

    _bindStore(currentStore.id);

    if (_isSaleMode) {
      return Scaffold(
        backgroundColor: TaxEasyColors.surface,
        appBar: AppBar(
          backgroundColor: TaxEasyColors.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          scrolledUnderElevation: 2,
          flexibleSpace: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DecoratedBox(
                decoration:
                    BoxDecoration(gradient: TaxEasyGradients.horizontal),
                child: SizedBox(height: 3, width: double.infinity),
              ),
            ],
          ),
          title: _StoreTitle(
              storeName: currentStore.name, onTap: _showStoreSwitcher),
          actions: [
            _ModeToggle(
              isSaleMode: _isSaleMode,
              onToggle: () => setState(() => _isSaleMode = !_isSaleMode),
            ),
            _SyncBadge(),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'Tài khoản',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProfileScreen(),
                ),
              ),
            ),
          ],
        ),
        body: SaleScreen(key: ValueKey(currentStore.id)),
      );
    }

    // Manage mode
    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      appBar: AppBar(
        backgroundColor: TaxEasyColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        scrolledUnderElevation: 2,
        flexibleSpace: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DecoratedBox(
              decoration:
                  BoxDecoration(gradient: TaxEasyGradients.horizontal),
              child: SizedBox(height: 3, width: double.infinity),
            ),
          ],
        ),
        title: _StoreTitle(
            storeName: currentStore.name, onTap: _showStoreSwitcher),
        actions: [
          _ModeToggle(
            isSaleMode: _isSaleMode,
            onToggle: () => setState(() => _isSaleMode = !_isSaleMode),
          ),
          _SyncBadge(),
          // Tồn kho — chỉ hiện ở tab Sản phẩm.
          if (_manageTabIndex == 2)
            IconButton(
              icon: const Icon(Icons.inventory_outlined),
              tooltip: 'Quản lý tồn kho',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const InventoryScreen(),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Tài khoản',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProfileScreen(),
              ),
            ),
          ),
        ],
      ),
      body: _manageBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _manageTabIndex,
        onTap: (index) => setState(() => _manageTabIndex = index),
        selectedItemColor: const Color(0xFF004AC6),
        unselectedItemColor: const Color(0xFF737686),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            label: 'Doanh thu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Thuế',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Sản phẩm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'Hóa đơn',
          ),
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
                icon: Icons.point_of_sale_outlined,
                isActive: isSaleMode,
                cs: cs,
              ),
              _PillTab(
                label: 'Quản lý',
                icon: Icons.bar_chart_outlined,
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
  final IconData icon;
  final bool isActive;
  final ColorScheme cs;

  const _PillTab(
      {required this.label,
      required this.icon,
      required this.isActive,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 15,
              color: isActive ? Colors.white : cs.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : cs.onSurfaceVariant,
            ),
          ),
        ],
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
        child: const Icon(Icons.cloud_off_outlined),
      ),
      tooltip: 'Xem $pending hóa đơn chờ đồng bộ',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const PendingSyncScreen()),
      ),
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
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<AuthProvider>().logout(),
                    child: const Text('Đăng xuất'),
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
  final _taxIdCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _businessType = 'food_beverage';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taxIdCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<StoresProvider>().createStore(
            name: _nameCtrl.text,
            businessType: _businessType,
            taxId: _taxIdCtrl.text,
            address: _addressCtrl.text,
            phone: _phoneCtrl.text,
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
              const SizedBox(height: 14),
              TextFormField(
                controller: _taxIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mã số thuế (cần cho hóa đơn điện tử)',
                  hintText: '10 hoặc 13 chữ số',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: validateTaxId,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
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
