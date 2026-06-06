import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/revenue_provider.dart';

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
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 12),
            Text(provider.error ?? 'Lỗi tải dữ liệu', style: TextStyle(color: cs.onSurfaceVariant)),
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
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, letterSpacing: 0.3),
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
            cs: cs,
          ),
          const SizedBox(height: 12),

          // Two smaller cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Tháng này',
                  value: '${_currencyFmt.format(data.monthRevenue)}đ',
                  icon: Icons.calendar_month_outlined,
                  cs: cs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Số hóa đơn',
                  value: '${data.monthInvoiceCount}',
                  icon: Icons.receipt_long_outlined,
                  cs: cs,
                ),
              ),
            ],
          ),

          // Revenue chart
          if (data.daily.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionHeader(title: 'Doanh thu theo ngày', cs: cs),
            const SizedBox(height: 12),
            _ChartCard(
              child: SizedBox(height: 180, child: _RevenueChart(daily: data.daily, cs: cs)),
            ),
          ],

          // Top products
          if (data.topProducts.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionHeader(title: 'Món bán chạy tháng này', cs: cs),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme cs;

  const _HeroStatCard({required this.label, required this.value, required this.icon, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C6D7)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Trend indicator placeholder
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFC3C6D7)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, size: 14, color: cs.secondary),
                const SizedBox(width: 2),
                Text('hôm nay', style: TextStyle(fontSize: 11, color: cs.secondary, fontWeight: FontWeight.w600)),
              ],
            ),
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

  const _StatCard({required this.label, required this.value, required this.icon, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C6D7)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: cs.primary),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.primary,
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
                  color: rank == 1 ? const Color(0xFFFBBF24) : const Color(0xFFEFF4FF),
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
                    Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0B1C30))),
                    Text('$count lần bán', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Text(
                '${_currencyFmt.format(revenue)}đ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.primary),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
      ],
    );
  }
}

// ── Line Chart ─────────────────────────────────────────────────────────────

class _RevenueChart extends StatelessWidget {
  final List<DailyRevenue> daily;
  final ColorScheme cs;
  const _RevenueChart({required this.daily, required this.cs});

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    final maxY = daily.map((d) => d.revenue.toDouble()).reduce((a, b) => a > b ? a : b);
    final spots = daily.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.revenue.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY * 1.2,
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
              interval: (daily.length / 5).ceilToDouble().clamp(1, 31),
              getTitlesWidget: (val, _) {
                final idx = val.toInt();
                if (idx < 0 || idx >= daily.length) return const SizedBox.shrink();
                final day = daily[idx].date.substring(8);
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(day, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
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
                return Text(
                  '${(val / 1000).round()}k',
                  style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              show: daily.length <= 10,
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
                colors: [cs.primary.withValues(alpha: 0.12), cs.primary.withValues(alpha: 0)],
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
