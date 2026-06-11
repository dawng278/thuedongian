import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/stores_provider.dart';
import '../../services/api_service.dart';
import 'tax_deadlines_screen.dart';

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
  String? _storeId;

  Future<void> _load() async {
    final storeId = _storeId;
    if (storeId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = context.read<ApiService>();
    try {
      final results = await Future.wait([
        api.getTaxEstimate(period: _period, storeId: storeId),
        api.getTaxDeadlines(),
      ]);
      setState(() {
        _estimate = results[0];
        // ignore: avoid_dynamic_calls
        final raw = ((results[1] as Map)['deadlines'] as List?) ?? [];
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
    final cs = Theme.of(context).colorScheme;
    final storeId = context.watch<StoresProvider>().currentStore?.id;
    if (storeId != null && storeId != _storeId) {
      _storeId = storeId;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }

    if (_loading && _estimate == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _estimate == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    final est = _estimate;
    if (est == null) return const SizedBox.shrink();

    final belowThreshold = est['below_threshold'] as bool? ?? false;
    final periodRevenue = (est['period_revenue'] as num?)?.toInt() ?? 0;
    final exemptThreshold =
        (est['exempt_threshold'] as num?)?.toInt() ?? 200000000;
    final vatAmount = (est['vat_amount'] as num?)?.toInt() ?? 0;
    final pitAmount = (est['pit_amount'] as num?)?.toInt() ?? 0;
    final vatRate = ((est['vat_rate'] as num?)?.toDouble() ?? 0.01) * 100;
    final pitRate = ((est['pit_rate'] as num?)?.toDouble() ?? 0.005) * 100;

    // Ưu tiên dùng year_progress_pct từ server (chính xác hơn cho kỳ tháng/quý)
    final yearRevenue = (est['year_revenue'] as num?)?.toInt() ?? periodRevenue;
    final yearProgressPct = (est['year_progress_pct'] as num?)?.toInt() ??
        (exemptThreshold > 0
            ? ((periodRevenue / exemptThreshold) * 100).round().clamp(0, 100)
            : 0);
    final yearProgress = yearProgressPct / 100.0;

    final pctText = '$yearProgressPct%';
    final isNearThreshold = yearProgress >= 0.7;

    final monthlyBreakdown = (est['monthly_breakdown'] as List?)
        ?.cast<Map<String, dynamic>>() ??
        [];

    return RefreshIndicator(
      color: cs.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Period toggle
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC3C6D7)),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PeriodTab(
                      label: 'Tháng',
                      value: 'month',
                      selected: _period,
                      onTap: (v) {
                        setState(() => _period = v);
                        _load();
                      }),
                  _PeriodTab(
                      label: 'Quý',
                      value: 'quarter',
                      selected: _period,
                      onTap: (v) {
                        setState(() => _period = v);
                        _load();
                      }),
                  _PeriodTab(
                      label: 'Năm',
                      value: 'year',
                      selected: _period,
                      onTap: (v) {
                        setState(() => _period = v);
                        _load();
                      }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Period label
          Center(
            child: Text(
              est['period_label'] as String? ?? '',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),

          // Ngưỡng thuế năm (luôn hiển thị — dùng year_revenue)
          _YearThresholdCard(
            yearRevenue: yearRevenue,
            exemptThreshold: exemptThreshold,
            yearProgress: yearProgress,
            pctText: pctText,
            isNear: isNearThreshold,
            belowThreshold: belowThreshold,
            periodRevenue: periodRevenue,
            period: _period,
          ),
          const SizedBox(height: 16),

          if (!belowThreshold) ...[
            // Tax estimate cards row
            Row(
              children: [
                Expanded(
                  child: _TaxEstCard(
                    icon: Icons.account_balance_wallet_rounded,
                    iconBg: cs.secondaryContainer,
                    iconFg: cs.onSecondaryContainer,
                    label:
                        'Thuế GTGT ước tính\n(${vatRate.toStringAsFixed(0)}%)',
                    amount: '${_currencyFmt.format(vatAmount)}đ',
                    cs: cs,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TaxEstCard(
                    icon: Icons.person_rounded,
                    iconBg: cs.primaryContainer,
                    iconFg: cs.onPrimaryContainer,
                    label:
                        'Thuế TNCN ước tính\n(${pitRate.toStringAsFixed(1)}%)',
                    amount: '${_currencyFmt.format(pitAmount)}đ',
                    cs: cs,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Monthly breakdown (khi chọn quý hoặc năm và có dữ liệu)
          if (monthlyBreakdown.isNotEmpty && _period != 'month') ...[
            _SectionHeader(
              title: _period == 'year'
                  ? 'Doanh thu & thuế theo tháng'
                  : 'Chi tiết theo tháng trong quý',
              cs: cs,
            ),
            const SizedBox(height: 12),
            _MonthlyBreakdownCard(
              breakdown: monthlyBreakdown,
              cs: cs,
              exemptThreshold: exemptThreshold,
            ),
            const SizedBox(height: 16),
          ],

          // Deadline timeline
          if (_deadlines.isNotEmpty) ...[
            Row(
              children: [
                _SectionHeader(title: 'Lịch nộp thuế', cs: cs),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TaxDeadlinesScreen(),
                    ),
                  ),
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DeadlineTimeline(deadlines: _deadlines, cs: cs),
            const SizedBox(height: 16),
          ],

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFC3C6D7).withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    est['disclaimer'] as String? ??
                        'Các số liệu chỉ mang tính ước tính. Tham khảo chuyên gia kế toán trước khi nộp tờ khai.',
                    style: TextStyle(
                        fontSize: 12, color: cs.onSurfaceVariant, height: 1.5),
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

// ── Widgets ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme cs;
  const _SectionHeader({required this.title, required this.cs});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.event_outlined, size: 18, color: cs.primary),
        const SizedBox(width: 6),
        Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.onSurface)),
      ],
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;
  const _PeriodTab(
      {required this.label,
      required this.value,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Card ngưỡng thuế — luôn dùng doanh thu năm để cảnh báo đúng.
class _YearThresholdCard extends StatelessWidget {
  final int yearRevenue;
  final int exemptThreshold;
  final double yearProgress;
  final String pctText;
  final bool isNear;
  final bool belowThreshold;
  final int periodRevenue;
  final String period;

  const _YearThresholdCard({
    required this.yearRevenue,
    required this.exemptThreshold,
    required this.yearProgress,
    required this.pctText,
    required this.isNear,
    required this.belowThreshold,
    required this.periodRevenue,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final barColor = isNear ? const Color(0xFFFBBF24) : cs.primary;
    final borderColor =
        isNear ? const Color(0xFFFBBF24) : const Color(0xFFC3C6D7);

    final remaining = (exemptThreshold - yearRevenue).clamp(0, exemptThreshold);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isNear
            ? [
                BoxShadow(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]
            : [
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
              if (isNear) ...[
                const Icon(Icons.warning_amber_rounded,
                    size: 20, color: Color(0xFFFBBF24)),
                const SizedBox(width: 6),
              ],
              Text(
                'Ngưỡng chịu thuế (cả năm)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B1C30)),
              children: [
                TextSpan(text: belowThreshold ? 'Dưới ngưỡng ' : 'Gần ngưỡng '),
                TextSpan(
                  text: '($pctText)',
                  style: TextStyle(color: barColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Doanh thu năm đến nay',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              Text(
                '${_currencyFmt.format(yearRevenue)}đ',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B1C30)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ngưỡng miễn thuế',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              Text(
                '${_currencyFmt.format(exemptThreshold)}đ/năm',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: yearProgress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5EEFF),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            belowThreshold
                ? 'Còn ${_currencyFmt.format(remaining)}đ đến ngưỡng chịu thuế.'
                : 'Đã vượt ngưỡng miễn thuế — cần kê khai và nộp thuế.',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          // Nếu đang xem kỳ tháng/quý thì thêm dòng doanh thu kỳ hiện tại
          if (period != 'year') ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  period == 'month'
                      ? 'Doanh thu tháng này'
                      : 'Doanh thu quý này',
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant),
                ),
                Text(
                  '${_currencyFmt.format(periodRevenue)}đ',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TaxEstCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final String amount;
  final ColorScheme cs;

  const _TaxEstCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    required this.amount,
    required this.cs,
  });

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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: iconFg),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.4)),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B1C30)),
          ),
        ],
      ),
    );
  }
}

/// Bảng doanh thu + thuế theo từng tháng trong quý/năm.
class _MonthlyBreakdownCard extends StatelessWidget {
  final List<Map<String, dynamic>> breakdown;
  final ColorScheme cs;
  final int exemptThreshold;

  const _MonthlyBreakdownCard({
    required this.breakdown,
    required this.cs,
    required this.exemptThreshold,
  });

  static const _months = [
    'T1', 'T2', 'T3', 'T4', 'T5', 'T6',
    'T7', 'T8', 'T9', 'T10', 'T11', 'T12',
  ];

  @override
  Widget build(BuildContext context) {
    final maxRev = breakdown.fold<int>(
      1,
      (m, r) => ((r['revenue'] as num?)?.toInt() ?? 0) > m
          ? (r['revenue'] as num).toInt()
          : m,
    );

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
        children: breakdown.map((row) {
          final month = (row['month'] as num?)?.toInt() ?? 0;
          final rev = (row['revenue'] as num?)?.toInt() ?? 0;
          final taxAmt = (row['tax_amount'] as num?)?.toInt() ?? 0;
          final below = row['below_threshold'] as bool? ?? true;
          final barW = maxRev > 0 ? (rev / maxRev) : 0.0;
          final label = month >= 1 && month <= 12
              ? _months[month - 1]
              : 'T$month';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bar
                      LayoutBuilder(builder: (ctx, constraints) {
                        return Stack(
                          children: [
                            Container(
                              height: 8,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5EEFF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            Container(
                              height: 8,
                              width: constraints.maxWidth * barW,
                              decoration: BoxDecoration(
                                color: below
                                    ? cs.primary
                                    : const Color(0xFFFBBF24),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currencyFmt.format(rev)}đ',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0B1C30)),
                          ),
                          if (!below)
                            Text(
                              'Thuế: ${_currencyFmt.format(taxAmt)}đ',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFFBBF24),
                                  fontWeight: FontWeight.w600),
                            )
                          else
                            Text(
                              'Miễn thuế',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DeadlineTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> deadlines;
  final ColorScheme cs;
  const _DeadlineTimeline({required this.deadlines, required this.cs});

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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vertical line
            Column(
              children: [
                const SizedBox(height: 6),
                Container(
                    width: 2,
                    color: const Color(0xFFDCE9FF),
                    margin: const EdgeInsets.only(left: 7)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: deadlines.asMap().entries.map((entry) {
                  final d = entry.value;
                  final isFirst = entry.key == 0;
                  final urgent = d['urgent'] as bool? ?? false;
                  final label = d['label'] as String? ?? '';
                  final deadline = d['deadline'] as String? ?? '';
                  return _TimelineItem(
                    label: label,
                    deadline: deadline,
                    isActive: isFirst,
                    urgent: urgent,
                    cs: cs,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final String deadline;
  final bool isActive;
  final bool urgent;
  final ColorScheme cs;

  const _TimelineItem({
    required this.label,
    required this.deadline,
    required this.isActive,
    required this.urgent,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // dot
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
              color: isActive ? cs.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isActive ? cs.primary : const Color(0xFFC3C6D7),
                  width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isActive
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              const Color(0xFFC3C6D7).withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label.toUpperCase(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(deadline,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B1C30))),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(deadline,
                          style: TextStyle(
                              fontSize: 13, color: cs.onSurfaceVariant)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
