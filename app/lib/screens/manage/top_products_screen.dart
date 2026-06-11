import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/revenue_provider.dart';
import '../../theme/taxeasy_design.dart';

final _currencyFmt = NumberFormat('#,###', 'vi_VN');

/// Trang chi tiết sản phẩm bán chạy: bảng xếp hạng đầy đủ theo doanh thu,
/// kèm % đóng góp và số lượng bán. Dữ liệu lấy từ RevenueProvider (tháng này).
class TopProductsScreen extends StatelessWidget {
  const TopProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = context.watch<RevenueProvider>().data;
    final products = data?.topProducts ?? [];

    // Tổng doanh thu của các món để tính % đóng góp.
    final totalRevenue =
        products.fold<int>(0, (s, p) => s + p.totalRevenue);
    final totalQuantity =
        products.fold<int>(0, (s, p) => s + p.totalQuantity);

    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      appBar: AppBar(title: const Text('Sản phẩm bán chạy')),
      body: products.isEmpty
          ? _empty(cs)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // Tóm tắt
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Mặt hàng',
                        value: '${products.length}',
                        icon: Icons.category_outlined,
                        cs: cs,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Tổng đã bán',
                        value: '$totalQuantity',
                        icon: Icons.shopping_bag_outlined,
                        cs: cs,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'XẾP HẠNG THEO DOANH THU (THÁNG NÀY)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                ...products.asMap().entries.map((e) {
                  final rank = e.key + 1;
                  final p = e.value;
                  final pct = totalRevenue == 0
                      ? 0.0
                      : p.totalRevenue / totalRevenue;
                  return _RankRow(
                    rank: rank,
                    name: p.productName,
                    quantity: p.totalQuantity,
                    revenue: p.totalRevenue,
                    pct: pct,
                    cs: cs,
                  );
                }),
              ],
            ),
    );
  }

  Widget _empty(ColorScheme cs) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights_outlined, size: 56, color: cs.outline),
            const SizedBox(height: 12),
            Text('Chưa có dữ liệu bán hàng',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme cs;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final int rank;
  final String name;
  final int quantity;
  final int revenue;
  final double pct;
  final ColorScheme cs;

  const _RankRow({
    required this.rank,
    required this.name,
    required this.quantity,
    required this.revenue,
    required this.pct,
    required this.cs,
  });

  // Màu huy chương cho top 3.
  Color get _rankColor => switch (rank) {
        1 => const Color(0xFFFFB300), // vàng
        2 => const Color(0xFF90A4AE), // bạc
        3 => const Color(0xFFA1887F), // đồng
        _ => cs.outline,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaxEasyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3
              ? _rankColor.withValues(alpha: 0.4)
              : TaxEasyColors.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Hạng
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? _rankColor.withValues(alpha: 0.15)
                      : TaxEasyColors.surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: rank <= 3
                    ? Icon(Icons.emoji_events, size: 18, color: _rankColor)
                    : Text('$rank',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_currencyFmt.format(revenue)}đ',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: TaxEasyColors.primary)),
                  Text('$quantity đã bán',
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Thanh % đóng góp doanh thu
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: TaxEasyColors.surfaceLow,
                    valueColor: AlwaysStoppedAnimation(
                      rank <= 3 ? _rankColor : cs.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${(pct * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
