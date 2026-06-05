import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';

final _currencyFmt = NumberFormat('#,###', 'vi_VN');

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  Map<String, dynamic>? _estimate;
  List<Map<String, dynamic>> _deadlines = [];
  bool _loading = false;
  String? _error;
  String _period = 'month';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiService>();
      final results = await Future.wait([
        api.getTaxEstimate(period: _period),
        api.getTaxDeadlines(),
      ]);
      setState(() {
        _estimate = results[0];
        final raw = results[1]['deadlines'] as List? ?? [];
        _deadlines = raw.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _estimate == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _estimate == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    final est = _estimate;
    if (est == null) return const SizedBox.shrink();

    final belowThreshold = est['below_threshold'] as bool? ?? false;
    final periodRevenue = (est['period_revenue'] as num?)?.toInt() ?? 0;
    final annualisedRevenue = (est['annualised_revenue'] as num?)?.toInt() ?? 0;
    final vatAmount = (est['vat_amount'] as num?)?.toInt() ?? 0;
    final pitAmount = (est['pit_amount'] as num?)?.toInt() ?? 0;
    final totalTax = (est['total_tax'] as num?)?.toInt() ?? 0;
    final vatRate = ((est['vat_rate'] as num?)?.toDouble() ?? 0) * 100;
    final pitRate = ((est['pit_rate'] as num?)?.toDouble() ?? 0) * 100;
    final color = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Period toggle
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'month', label: Text('Tháng này')),
              ButtonSegment(value: 'quarter', label: Text('Quý này')),
            ],
            selected: {_period},
            onSelectionChanged: (s) {
              setState(() => _period = s.first);
              _load();
            },
          ),
          const SizedBox(height: 16),

          // Period label
          Text(
            est['period_label'] as String? ?? '',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            '${est['business_type_label'] ?? ''} — Nguồn: ${est['source'] ?? ''}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // Revenue card
          _TaxCard(
            title: 'Doanh thu kỳ này',
            value: '${_currencyFmt.format(periodRevenue)}đ',
            subtitle: 'Dự tính năm: ${_currencyFmt.format(annualisedRevenue)}đ',
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: 12),

          // Threshold check
          Card(
            color: belowThreshold ? Colors.green.shade50 : Colors.orange.shade50,
            child: ListTile(
              leading: Icon(
                belowThreshold ? Icons.check_circle : Icons.warning_amber,
                color: belowThreshold ? Colors.green : Colors.orange,
              ),
              title: Text(
                belowThreshold
                    ? 'Dưới ngưỡng chịu thuế'
                    : 'Trên ngưỡng chịu thuế',
                style: TextStyle(
                  color: belowThreshold ? Colors.green.shade800 : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Ngưỡng miễn thuế: ${_currencyFmt.format(est['exempt_threshold'] as int? ?? 0)}đ/năm',
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (!belowThreshold) ...[
            _TaxCard(
              title: 'Thuế GTGT ước tính',
              value: '${_currencyFmt.format(vatAmount)}đ',
              subtitle: 'Tỷ lệ $vatRate%',
              icon: Icons.receipt_outlined,
            ),
            const SizedBox(height: 8),
            _TaxCard(
              title: 'Thuế TNCN ước tính',
              value: '${_currencyFmt.format(pitAmount)}đ',
              subtitle: 'Tỷ lệ $pitRate%',
              icon: Icons.person_outlined,
            ),
            const SizedBox(height: 8),
            Card(
              color: color.errorContainer,
              child: ListTile(
                leading: Icon(Icons.calculate, color: color.onErrorContainer),
                title: Text(
                  'Tổng thuế ước tính',
                  style: TextStyle(color: color.onErrorContainer, fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '${_currencyFmt.format(totalTax)}đ',
                  style: TextStyle(
                    color: color.onErrorContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Deadlines
          if (_deadlines.isNotEmpty) ...[
            Text('Các mốc hạn kê khai', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._deadlines.map((d) {
              final urgent = d['urgent'] as bool? ?? false;
              final daysLeft = d['daysLeft'] as int? ?? 0;
              return Card(
                color: urgent ? Colors.red.shade50 : null,
                child: ListTile(
                  leading: Icon(
                    urgent ? Icons.alarm : Icons.event,
                    color: urgent ? Colors.red : color.primary,
                  ),
                  title: Text(d['label'] as String? ?? ''),
                  subtitle: Text('Hạn: ${d['deadline'] as String? ?? ''}'),
                  trailing: Chip(
                    label: Text(
                      '$daysLeft ngày',
                      style: TextStyle(color: urgent ? Colors.white : null),
                    ),
                    backgroundColor: urgent ? Colors.red : null,
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: color.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    est['disclaimer'] as String? ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.outline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;

  const _TaxCard({required this.title, required this.value, this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color.primary),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
