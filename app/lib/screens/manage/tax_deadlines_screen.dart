import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../theme/taxeasy_design.dart';

final _dateFmt = DateFormat('dd/MM/yyyy', 'vi_VN');

/// Trang Nhắc hạn nộp thuế: danh sách các hạn kê khai sắp tới, cảnh báo nổi bật
/// cho hạn gần nhất, kèm checklist chuẩn bị hồ sơ.
class TaxDeadlinesScreen extends StatefulWidget {
  const TaxDeadlinesScreen({super.key});

  @override
  State<TaxDeadlinesScreen> createState() => _TaxDeadlinesScreenState();
}

class _TaxDeadlinesScreenState extends State<TaxDeadlinesScreen> {
  List<Map<String, dynamic>> _deadlines = [];
  bool _loading = true;
  String? _error;

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
      final res = await context.read<ApiService>().getTaxDeadlines();
      final raw = res['deadlines'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _deadlines = raw.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tải được lịch nộp thuế';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      appBar: AppBar(title: const Text('Nhắc hạn nộp thuế')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView(cs)
              : RefreshIndicator(
                  color: cs.primary,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      if (_deadlines.isNotEmpty) _nextDeadlineBanner(cs),
                      const SizedBox(height: 20),
                      Text('CÁC HẠN SẮP TỚI',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      ..._deadlines.map((d) => _DeadlineCard(data: d, cs: cs)),
                      const SizedBox(height: 24),
                      _checklist(cs),
                    ],
                  ),
                ),
    );
  }

  Widget _errorView(ColorScheme cs) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 12),
            Text(_error ?? '', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );

  Widget _nextDeadlineBanner(ColorScheme cs) {
    final next = _deadlines.first;
    final daysLeft = (next['daysLeft'] as num?)?.toInt() ?? 0;
    final urgent = next['urgent'] == true || daysLeft <= 14;
    final label = next['label'] as String? ?? 'Hạn nộp thuế';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: urgent
              ? [const Color(0xFFD32F2F), const Color(0xFFE57373)]
              : [TaxEasyColors.primary, TaxEasyColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(urgent ? Icons.warning_amber_rounded : Icons.event_available,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(urgent ? 'HẠN GẦN NHẤT — KHẨN' : 'HẠN GẦN NHẤT',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'Còn $daysLeft ngày · hạn ${_fmtDate(next['deadline'])}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _checklist(ColorScheme cs) {
    const items = [
      'Tổng hợp doanh thu kỳ kê khai (xem tab Doanh thu)',
      'Xuất báo cáo doanh thu nếu cần đối chiếu',
      'Kiểm tra Mã số thuế của quán đã khai báo',
      'Nộp tờ khai qua Cổng thuế điện tử hoặc ứng dụng eTax',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaxEasyColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist_rtl,
                  size: 18, color: TaxEasyColors.primary),
              SizedBox(width: 8),
              Text('Chuẩn bị hồ sơ',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: TaxEasyColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.radio_button_unchecked,
                      size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(t,
                        style: const TextStyle(
                            height: 1.4,
                            color: TaxEasyColors.textPrimary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(dynamic raw) {
    final s = raw as String?;
    if (s == null) return '';
    final d = DateTime.tryParse(s);
    return d != null ? _dateFmt.format(d) : s;
  }
}

class _DeadlineCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final ColorScheme cs;
  const _DeadlineCard({required this.data, required this.cs});

  @override
  Widget build(BuildContext context) {
    final daysLeft = (data['daysLeft'] as num?)?.toInt() ?? 0;
    final urgent = data['urgent'] == true || daysLeft <= 14;
    final label = data['label'] as String? ?? '';
    final deadline = data['deadline'] as String?;
    final dateStr = deadline != null
        ? (DateTime.tryParse(deadline) != null
            ? _dateFmt.format(DateTime.parse(deadline))
            : deadline)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaxEasyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: urgent
              ? const Color(0xFFD32F2F).withValues(alpha: 0.4)
              : TaxEasyColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: urgent
                  ? const Color(0xFFD32F2F).withValues(alpha: 0.12)
                  : TaxEasyColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              urgent ? Icons.priority_high : Icons.event_outlined,
              color: urgent ? const Color(0xFFD32F2F) : TaxEasyColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Hạn: $dateStr',
                    style: TextStyle(
                        fontSize: 13, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: urgent
                  ? const Color(0xFFD32F2F).withValues(alpha: 0.12)
                  : TaxEasyColors.surfaceLow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Còn $daysLeft ngày',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color:
                    urgent ? const Color(0xFFD32F2F) : TaxEasyColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
