import 'package:flutter/material.dart';

void main() {
  runApp(const TaxEasyApp());
}

class TaxEasyApp extends StatelessWidget {
  const TaxEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaxEasy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSaleMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSaleMode ? 'Bán hàng' : 'Quản lý'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isSaleMode ? Icons.bar_chart : Icons.shopping_cart),
            tooltip: _isSaleMode ? 'Chuyển sang Quản lý' : 'Chuyển sang Bán hàng',
            onPressed: () => setState(() => _isSaleMode = !_isSaleMode),
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
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              _isSaleMode ? 'Chế độ Bán hàng' : 'Chế độ Quản lý',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'TaxEasy — Đang phát triển...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
