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
  List<Map<String, dynamic>> _insights = [];
  bool _loading = false;
  bool _insightsLoading = false;
  String? _error;
  String _period = 'month';
  String? _storeId;

  Future<void> _load() async {
    final storeId = _storeId;
    if (storeId == null) return;
    setState(() {
      _loading = true;
      _insightsLoading = true;
      _error = null;
    });
    final api = context.read<ApiService>();
    try {
      final results = await Future.wait([
        api.getTaxEstimate(period: _period, storeId: storeId),
        api.getTaxDeadlines(),
      ]);
      setState(() {
        _estimate = results[0] as Map<String, dynamic>;
        final raw = (results[1] as Map<String, dynamic>)['deadlines'] as List? ?? [];
        _deadlines = raw.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
    // AI insights load riêng — không block UI chính nếu chậm
    try {
      final insights = await api.getAiInsights(storeId: storeId);
      if (mounted) setState(() => _insights = insights);
    } catch (_) {
      // Không hiện lỗi AI — chỉ ẩn section
    } finally {
      if (mounted) setState(() => _insightsLoading = false);
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
        (est['exempt_threshold'] as num?)?.toInt() ?? 100000000;
    final vatAmount = (est['vat_amount'] as num?)?.toInt() ?? 0;
    final pitAmount = (est['pit_amount'] as num?)?.toInt() ?? 0;
    final vatRate = ((est['vat_rate'] as num?)?.toDouble() ?? 0.01) * 100;
    final pitRate = ((est['pit_rate'] as num?)?.toDouble() ?? 0.005) * 100;
    final progress = exemptThreshold > 0
        ? (periodRevenue / exemptThreshold).clamp(0.0, 1.0)
        : 0.0;
    final pctText = '${(progress * 100).round()}%';
    final isNearThreshold = progress >= 0.7;

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
                      label: 'Tháng này',
                      value: 'month',
                      selected: _period,
                      onTap: (v) {
                        setState(() => _period = v);
                        _load();
                      }),
                  _PeriodTab(
                      label: 'Quý này',
                      value: 'quarter',
                      selected: _period,
                      onTap: (v) {
                        setState(() => _period = v);
                        _load();
                      }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tax threshold card
          _ThresholdCard(
            periodRevenue: periodRevenue,
            exemptThreshold: exemptThreshold,
            progress: progress,
            pctText: pctText,
            isNear: isNearThreshold,
            belowThreshold: belowThreshold,
          ),
          const SizedBox(height: 16),

          // AI Insights
          if (_insightsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: _InsightsLoadingCard(),
            )
          else if (_insights.isNotEmpty) ...[
            _AiInsightsSection(insights: _insights, cs: cs),
            const SizedBox(height: 16),
          ],

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
                        'Thuế GTGT ước tính (${vatRate.toStringAsFixed(0)}%)',
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
                        'Thuế TNCN ước tính (${pitRate.toStringAsFixed(1)}%)',
                    amount: '${_currencyFmt.format(pitAmount)}đ',
                    cs: cs,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

class _ThresholdCard extends StatelessWidget {
  final int periodRevenue;
  final int exemptThreshold;
  final double progress;
  final String pctText;
  final bool isNear;
  final bool belowThreshold;

  const _ThresholdCard({
    required this.periodRevenue,
    required this.exemptThreshold,
    required this.progress,
    required this.pctText,
    required this.isNear,
    required this.belowThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final barColor = isNear ? const Color(0xFFFBBF24) : cs.primary;
    final borderColor =
        isNear ? const Color(0xFFFBBF24) : const Color(0xFFC3C6D7);

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
                'Trạng thái ngưỡng thuế',
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
              Text('Doanh thu kỳ này',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              Text(
                '${_currencyFmt.format(periodRevenue)}đ / ${_currencyFmt.format(exemptThreshold)}đ',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0B1C30)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5EEFF),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            belowThreshold
                ? 'Còn ${_currencyFmt.format(exemptThreshold - periodRevenue)}đ đến ngưỡng chịu thuế.'
                : 'Chỉ còn ${_currencyFmt.format(exemptThreshold - periodRevenue)}đ để đạt ngưỡng chịu thuế cao hơn.',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
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
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
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

// ── AI Insights ────────────────────────────────────────────────────────────

class _InsightsLoadingCard extends StatelessWidget {
  const _InsightsLoadingCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C6D7)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Đang phân tích dữ liệu...',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _AiInsightsSection extends StatelessWidget {
  final List<Map<String, dynamic>> insights;
  final ColorScheme cs;

  const _AiInsightsSection({required this.insights, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              'Gợi ý thông minh',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'AI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...insights.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InsightCard(insight: i, cs: cs),
            )),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Map<String, dynamic> insight;
  final ColorScheme cs;

  const _InsightCard({required this.insight, required this.cs});

  @override
  Widget build(BuildContext context) {
    final type = insight['type'] as String? ?? 'info';
    final title = insight['title'] as String? ?? '';
    final body = insight['body'] as String? ?? '';

    final (iconData, bgColor, iconColor) = switch (type) {
      'warning' => (
          Icons.warning_amber_rounded,
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
        ),
      'tip' => (
          Icons.lightbulb_outline_rounded,
          const Color(0xFFECFDF5),
          const Color(0xFF059669),
        ),
      _ => (
          Icons.info_outline_rounded,
          const Color(0xFFEFF4FF),
          const Color(0xFF1976D2),
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
