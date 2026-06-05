import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSaleMode = true;

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
            tooltip: _isSaleMode ? 'Chuyển sang Quản lý' : 'Chuyển sang Bán hàng',
            onPressed: () => setState(() => _isSaleMode = !_isSaleMode),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'logout') await context.read<AuthProvider>().logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSaleMode ? Icons.point_of_sale : Icons.analytics,
              size: 80,
              color: color.primary,
            ),
            const SizedBox(height: 16),
            Text(
              _isSaleMode ? 'Chế độ Bán hàng' : 'Chế độ Quản lý',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              storeName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color.primary),
            ),
            const SizedBox(height: 4),
            Text(
              'Task 03 sẽ thêm lưới món và bán hàng',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
