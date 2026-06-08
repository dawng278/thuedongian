import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/revenue_provider.dart';
import '../../widgets/skeleton.dart';
import 'top_products_screen.dart';

final _currencyFmt = NumberFormat('#,###', 'vi_VN');

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RevenueProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RevenueProvider>();
    final cs = Theme.of(context).colorScheme;

    if (provider.loading && provider.data == null) {
      return const RevenueSkeleton();
    }

    if (provider.error != null && provider.data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 12),
            Text(provider.error ?? 'Lỗi tải dữ liệu',
                style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => provider.load(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final data = provider.data;
    if (data == null) return const SizedBox.shrink();

    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () => provider.load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng quan kinh doanh',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.3),
              ),
              const SizedBox(height: 4),
              Text(
                'Quản lý Doanh thu',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bento grid — hero card
          _HeroStatCard(
            label: 'Doanh thu Hôm nay',
            value: '${_currencyFmt.format(data.todayRevenue)}đ',
            icon: Icons.payments_outlined,
            cash: data.todayCash,
            transfer: data.todayTransfer,
            invoiceCount: data.todayInvoiceCount,
            cs: cs,
          ),
          const SizedBox(height: 12),
          // Two smaller cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Doanh thu tháng này',
                  value: '${_currencyFmt.format(data.monthRevenue)}đ',
                  icon: Icons.calendar_month_outlined,
                  cs: cs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Hóa đơn tháng này',
                  value: '${data.monthInvoiceCount}',
                  icon: Icons.receipt_long_outlined,
                  cs: cs,
                ),
              ),
            ],
          ),

          // Lợi nhuận tháng (chỉ hiện khi đã khai báo giá vốn)
          if (data.monthProfit != null) ...[
            const SizedBox(height: 12),
            _ProfitCard(profit: data.monthProfit!, cs: cs),
          ],

          // Biểu đồ doanh thu — chuyển đổi Tuần / Tháng / Năm
          const SizedBox(height: 24),
          _SectionHeader(title: 'Biểu đồ doanh thu', cs: cs),
          const SizedBox(height: 12),
          _GranularitySelector(
            selected: provider.granularity,
            onChanged: (g) => provider.loadChart(g),
            cs: cs,
          ),
          const SizedBox(height: 12),
          _ChartCard(
            child: SizedBox(
              height: 200,
              child: provider.chartLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.chart.every((p) => p.revenue == 0)
                      ? Center(
                          child: Text('Chưa có doanh thu trong kỳ này',
                              style: TextStyle(color: cs.onSurfaceVariant)))
                      : _RevenueChart(points: provider.chart, cs: cs),
            ),
          ),

          // Top products
          if (data.topProducts.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                _SectionHeader(title: 'Món bán chạy', cs: cs),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TopProductsScreen(),
                    ),
                  ),
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ChartCard(
              child: Column(
                children: data.topProducts.asMap().entries.map((entry) {
                  final p = entry.value;
                  return _TopProductRow(
                    rank: entry.key + 1,
                    name: p.productName,
                    count: p.totalQuantity,
                    revenue: p.totalRevenue,
                    cs: cs,
                    isLast: entry.key == data.topProducts.length - 1,
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme cs;
  const _SectionHeader({required this.title, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;
  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C6D7)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final int cash;
  final int transfer;
  final int invoiceCount;
  final ColorScheme cs;

  const _HeroStatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.cash,
      required this.transfer,
      required this.invoiceCount,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C6D7)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text('$invoiceCount hóa đơn hôm nay',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          const SizedBox(height: 12),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PayBreakdown(
                  label: 'Tiền mặt',
                  icon: Icons.payments_outlined,
                  amount: cash,
                  cs: cs,
                ),
              ),
              Container(width: 1, height: 32, color: cs.outlineVariant),
              Expanded(
                child: _PayBreakdown(
                  label: 'Chuyển khoản',
                  icon: Icons.account_balance_outlined,
                  amount: transfer,
                  cs: cs,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayBreakdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final int amount;
  final ColorScheme cs;

  const _PayBreakdown({
    required this.label,
    required this.icon,
    required this.amount,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 4),
          Text('${_currencyFmt.format(amount)}đ',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
        ],
      ),
    );
  }
}

class _ProfitCard extends StatelessWidget {
  final int profit;
  final ColorScheme cs;

  const _ProfitCard({required this.profit, required this.cs});

  @override
  Widget build(BuildContext context) {
    final positive = profit >= 0;
    final color = positive ? const Color(0xFF059669) : cs.error;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFE8F5EE) : const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.trending_up, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lợi nhuận tháng này (ước tính)',
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text('${_currencyFmt.format(profit)}đ',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme cs;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C6D7)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B1C30),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final int rank;
  final String name;
  final int count;
  final int revenue;
  final ColorScheme cs;
  final bool isLast;

  const _TopProductRow({
    required this.rank,
    required this.name,
    required this.count,
    required this.revenue,
    required this.cs,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: rank == 1
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: rank == 1 ? Colors.white : cs.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0B1C30))),
                    Text('$count lần bán',
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Text(
                '${_currencyFmt.format(revenue)}đ',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.primary),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
      ],
    );
  }
}

// ── Line Chart ─────────────────────────────────────────────────────────────

/// Bộ chọn mốc thời gian biểu đồ: Tuần / Tháng / Năm.
class _GranularitySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final ColorScheme cs;

  const _GranularitySelector({
    required this.selected,
    required this.onChanged,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      ('week', '7 ngày'),
      ('month', '30 ngày'),
      ('year', '12 tháng'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((o) {
          final isSel = selected == o.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(o.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSel ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1))
                        ]
                      : null,
                ),
                child: Text(
                  o.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    color: isSel ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<ChartPoint> points;
  final ColorScheme cs;
  const _RevenueChart({required this.points, required this.cs});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxY = points
        .map((p) => p.revenue.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.revenue.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: (maxY == 0 ? 1 : maxY) * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: cs.outlineVariant.withValues(alpha: 0.6),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (points.length / 6).ceilToDouble().clamp(1, 31),
              getTitlesWidget: (val, _) {
                final idx = val.toInt();
                if (idx < 0 || idx >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(points[idx].label,
                      style:
                          TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (val, _) {
                if (val == 0) return const SizedBox.shrink();
                final m = val >= 1000000
                    ? '${(val / 1000000).toStringAsFixed(1)}tr'
                    : '${(val / 1000).round()}k';
                return Text(m,
                    style:
                        TextStyle(fontSize: 10, color: cs.onSurfaceVariant));
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [cs.primaryContainer, cs.secondary],
            ),
            barWidth: 2.5,
            dotData: FlDotData(
              show: points.length <= 12,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color: cs.primaryContainer,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.12),
                  cs.primary.withValues(alpha: 0)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
