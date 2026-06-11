import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/products_provider.dart';
import '../../theme/taxeasy_design.dart';

final _currencyFmt = NumberFormat('#,###', 'vi_VN');

/// Ngưỡng tồn kho coi là "sắp hết" để cảnh báo.
const _lowStockThreshold = 10;

/// Trang Quản lý tồn kho: theo dõi số lượng tồn từng sản phẩm, cảnh báo
/// sắp hết, tổng giá trị tồn (theo giá vốn), và cập nhật nhanh số lượng.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<ProductsProvider>();
    // Chỉ sản phẩm CÓ theo dõi tồn kho (stock != null).
    final tracked =
        provider.products.where((p) => p.stock != null).toList()
          ..sort((a, b) => (a.stock ?? 0).compareTo(b.stock ?? 0));

    final lowStock =
        tracked.where((p) => (p.stock ?? 0) <= _lowStockThreshold).length;
    final totalValue = tracked.fold<int>(
        0, (s, p) => s + (p.stock ?? 0) * (p.costPrice ?? 0));

    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      appBar: AppBar(title: const Text('Quản lý tồn kho')),
      body: provider.loading && provider.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : tracked.isEmpty
              ? _empty(cs)
              : RefreshIndicator(
                  color: cs.primary,
                  onRefresh: () => provider.loadProducts(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: 'Mặt hàng theo dõi',
                              value: '${tracked.length}',
                              icon: Icons.inventory_2_outlined,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Sắp hết',
                              value: '$lowStock',
                              icon: Icons.warning_amber_rounded,
                              color: lowStock > 0
                                  ? const Color(0xFFD97706)
                                  : cs.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ValueCard(totalValue: totalValue, cs: cs),
                      const SizedBox(height: 20),
                      Text('TỒN KHO (sắp hết hiện trước)',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      ...tracked.map((p) => _StockRow(product: p, cs: cs)),
                    ],
                  ),
                ),
    );
  }

  Widget _empty(ColorScheme cs) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 56, color: cs.outline),
              const SizedBox(height: 12),
              const Text('Chưa có sản phẩm theo dõi tồn kho',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Mở Sản phẩm → sửa một món → nhập số lượng tồn để bắt đầu '
                'theo dõi kho.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, height: 1.5),
              ),
            ],
          ),
        ),
      );
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaxEasyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TaxEasyColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final int totalValue;
  final ColorScheme cs;
  const _ValueCard({required this.totalValue, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: TaxEasyGradients.brand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Giá trị tồn kho (theo giá vốn)',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 2),
              Text('${_currencyFmt.format(totalValue)}đ',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final ProductDto product;
  final ColorScheme cs;
  const _StockRow({required this.product, required this.cs});

  bool get _low => (product.stock ?? 0) <= _lowStockThreshold;

  Future<void> _adjust(BuildContext context, int delta) async {
    final current = product.stock ?? 0;
    final next = (current + delta).clamp(0, 999999);
    if (next == current) return;
    await context
        .read<ProductsProvider>()
        .updateProduct(product.id, {'stock': next});
  }

  @override
  Widget build(BuildContext context) {
    final stock = product.stock ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaxEasyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _low
              ? const Color(0xFFD97706).withValues(alpha: 0.4)
              : TaxEasyColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (_low) ...[
                      const Icon(Icons.warning_amber_rounded,
                          size: 14, color: Color(0xFFD97706)),
                      const SizedBox(width: 4),
                      const Text('Sắp hết',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFD97706),
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                    ],
                    Text('Còn $stock ${product.unit ?? ''}',
                        style: TextStyle(
                            fontSize: 13, color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          // Nút chỉnh nhanh
          _StepButton(
              icon: Icons.remove, onTap: () => _adjust(context, -1)),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text('$stock',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          _StepButton(icon: Icons.add, onTap: () => _adjust(context, 1)),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: TaxEasyColors.surfaceLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: TaxEasyColors.primary),
      ),
    );
  }
}
