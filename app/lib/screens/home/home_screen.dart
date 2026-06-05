import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';
import '../sale/sale_screen.dart';
import '../manage/product_manage_screen.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text(_isSaleMode ? storeName : 'Quản lý — $storeName'),
        backgroundColor: color.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isSaleMode ? Icons.bar_chart : Icons.point_of_sale),
            tooltip: _isSaleMode ? 'Chế độ Quản lý' : 'Chế độ Bán hàng',
            onPressed: () => setState(() => _isSaleMode = !_isSaleMode),
          ),
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
                  Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Sản phẩm'),
                  Tab(icon: Icon(Icons.analytics_outlined), text: 'Doanh thu'),
                ],
              ),
      ),
      body: _isSaleMode
          ? const SaleScreen()
          : TabBarView(
              controller: _tabController,
              children: [
                const ProductManageScreen(),
                _RevenueStub(),
              ],
            ),
    );
  }
}

class _RevenueStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('Doanh thu', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Task 08/10 sẽ bổ sung biểu đồ & xuất báo cáo'),
        ],
      ),
    );
  }
}
