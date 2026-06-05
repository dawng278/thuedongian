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

    if (provider.loading && provider.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(provider.error ?? 'Lỗi tải dữ liệu'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => provider.load(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final data = provider.data;
    if (data == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: () => provider.load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Hôm nay', value: '${_currencyFmt.format(data.todayRevenue)}đ', icon: Icons.today)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Tháng này', value: '${_currencyFmt.format(data.monthRevenue)}đ', icon: Icons.calendar_month)),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
            label: 'Số hóa đơn tháng này',
            value: '${data.monthInvoiceCount} hóa đơn',
            icon: Icons.receipt_long,
          ),
          const SizedBox(height: 24),

          // Revenue chart
          if (data.daily.isNotEmpty) ...[
            Text('Doanh thu theo ngày', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(height: 200, child: _RevenueChart(daily: data.daily)),
            const SizedBox(height: 24),
          ],

          // Top products
          if (data.topProducts.isNotEmpty) ...[
            Text('Món bán chạy tháng này', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...data.topProducts.map(
              (p) => ListTile(
                dense: true,
                leading: const Icon(Icons.local_fire_department, color: Colors.orange),
                title: Text(p.productName),
                subtitle: Text('${p.totalQuantity} lần'),
                trailing: Text(
                  '${_currencyFmt.format(p.totalRevenue)}đ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<DailyRevenue> daily;
  const _RevenueChart({required this.daily});

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    final color = Theme.of(context).colorScheme;
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
          getDrawingHorizontalLine: (_) => FlLine(color: color.outlineVariant, strokeWidth: 1),
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
                final day = daily[idx].date.substring(8); // DD
                return Text(day, style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (val, _) {
                if (val == 0) return const SizedBox.shrink();
                return Text('${(val / 1000).round()}k', style: const TextStyle(fontSize: 10));
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
            color: color.primary,
            barWidth: 2,
            dotData: FlDotData(show: daily.length <= 7),
            belowBarData: BarAreaData(
              show: true,
              color: color.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
