import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stores_provider.dart';
import '../services/api_service.dart';
import '../theme/taxeasy_design.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AssistantBubble
//
// FAB góc phải dưới + chat panel trượt lên. Tự fetch insights khi mở lần đầu
// hoặc khi storeId thay đổi. Không cần truyền gì từ bên ngoài ngoài context.
// ─────────────────────────────────────────────────────────────────────────────

class AssistantBubble extends StatefulWidget {
  const AssistantBubble({super.key});

  @override
  State<AssistantBubble> createState() => _AssistantBubbleState();
}

class _AssistantBubbleState extends State<AssistantBubble>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  bool _loading = false;
  List<Map<String, dynamic>> _insights = [];
  String? _lastStoreId;

  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchInsights(String storeId) async {
    setState(() => _loading = true);
    try {
      final list =
          await context.read<ApiService>().getAiInsights(storeId: storeId);
      if (mounted) setState(() => _insights = list);
    } catch (_) {
      // Giữ _insights cũ nếu lỗi mạng
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggle(String? storeId) {
    if (_open) {
      _animCtrl.reverse().then((_) {
        if (mounted) setState(() => _open = false);
      });
    } else {
      setState(() => _open = true);
      _animCtrl.forward();
      if (storeId != null && storeId != _lastStoreId) {
        _lastStoreId = storeId;
        _fetchInsights(storeId);
      }
    }
  }

  // Số lượng warning để hiển thị badge đỏ trên FAB
  int get _warningCount =>
      _insights.where((i) => i['type'] == 'warning').length;

  @override
  Widget build(BuildContext context) {
    final storeId =
        context.watch<StoresProvider>().currentStore?.id;

    return Stack(
      children: [
        // Panel — nằm dưới FAB trong Stack
        if (_open)
          Positioned(
            right: 16,
            bottom: 90,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                alignment: Alignment.bottomRight,
                child: _ChatPanel(
                  insights: _insights,
                  loading: _loading,
                  onRefresh: storeId != null
                      ? () {
                          _lastStoreId = null;
                          _toggle(storeId);
                          Future.microtask(() => _toggle(storeId));
                        }
                      : null,
                  onClose: () => _toggle(storeId),
                ),
              ),
            ),
          ),

        // FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: _AssistantFab(
            open: _open,
            warningCount: _warningCount,
            onTap: () => _toggle(storeId),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Robot cube lơ lửng
// ─────────────────────────────────────────────────────────────────────────────

class _AssistantFab extends StatefulWidget {
  final bool open;
  final int warningCount;
  final VoidCallback onTap;

  const _AssistantFab({
    required this.open,
    required this.warningCount,
    required this.onTap,
  });

  @override
  State<_AssistantFab> createState() => _AssistantFabState();
}

class _AssistantFabState extends State<_AssistantFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatAnim = CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        // Lơ lửng lên xuống 6px
        final offset = math.sin(_floatAnim.value * math.pi) * 6.0;
        return Transform.translate(
          offset: Offset(0, -offset),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            // Hình cube tròn — bo góc nhiều hơn circle
            borderRadius: BorderRadius.circular(18),
            gradient: widget.open ? null : TaxEasyGradients.brand,
            color: widget.open ? TaxEasyColors.surfaceContainer : null,
            border: widget.open
                ? Border.all(color: TaxEasyColors.outlineVariant)
                : null,
            boxShadow: widget.open
                ? null
                : [
                    BoxShadow(
                      color: TaxEasyColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: TaxEasyColors.secondary.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: widget.open
                  ? Icon(
                      Icons.close_rounded,
                      key: const ValueKey('close'),
                      color: TaxEasyColors.textPrimary,
                      size: 22,
                    )
                  : _RobotFace(key: const ValueKey('robot')),
            ),
          ),
        ),
      ),
    );

    if (widget.warningCount == 0 || widget.open) return child;

    return Badge(
      label: Text('${widget.warningCount}'),
      backgroundColor: TaxEasyColors.error,
      child: child,
    );
  }
}

// Mặt robot nhỏ gọn vẽ bằng widget thuần — không cần asset
class _RobotFace extends StatelessWidget {
  const _RobotFace({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(painter: _RobotPainter()),
    );
  }
}

class _RobotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Đầu robot — hình chữ nhật bo góc
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.12, w * 0.84, h * 0.6),
      Radius.circular(w * 0.2),
    );
    final bodyPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(headRect, bodyPaint);

    // Viền mỏng
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(headRect, borderPaint);

    // Mắt trái
    final eyePaint = Paint()..color = const Color(0xFF004AC6);
    canvas.drawCircle(Offset(w * 0.33, h * 0.41), w * 0.1, eyePaint);

    // Mắt phải
    canvas.drawCircle(Offset(w * 0.67, h * 0.41), w * 0.1, eyePaint);

    // Điểm sáng trong mắt
    final glowPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(w * 0.36, h * 0.38), w * 0.04, glowPaint);
    canvas.drawCircle(Offset(w * 0.70, h * 0.38), w * 0.04, glowPaint);

    // Miệng — nụ cười nhỏ
    final smilePath = Path()
      ..moveTo(w * 0.33, h * 0.59)
      ..quadraticBezierTo(w * 0.5, h * 0.70, w * 0.67, h * 0.59);
    final smilePaint = Paint()
      ..color = const Color(0xFF004AC6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(smilePath, smilePaint);

    // Anten — que nhỏ trên đầu
    final antenPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.12), Offset(w * 0.5, h * 0.02),
        antenPaint);
    canvas.drawCircle(
        Offset(w * 0.5, h * 0.02), w * 0.05, Paint()..color = Colors.white);

    // Chân / đế nhỏ
    final legPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.38, h * 0.72), Offset(w * 0.38, h * 0.88), legPaint);
    canvas.drawLine(
        Offset(w * 0.62, h * 0.72), Offset(w * 0.62, h * 0.88), legPaint);
    canvas.drawLine(
        Offset(w * 0.30, h * 0.88), Offset(w * 0.46, h * 0.88), legPaint);
    canvas.drawLine(
        Offset(w * 0.54, h * 0.88), Offset(w * 0.70, h * 0.88), legPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat panel
// ─────────────────────────────────────────────────────────────────────────────

class _ChatPanel extends StatelessWidget {
  final List<Map<String, dynamic>> insights;
  final bool loading;
  final VoidCallback? onRefresh;
  final VoidCallback onClose;

  const _ChatPanel({
    required this.insights,
    required this.loading,
    required this.onRefresh,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenW = MediaQuery.of(context).size.width;
    final panelW = (screenW - 32).clamp(0.0, 340.0);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: Container(
        width: panelW,
        constraints: const BoxConstraints(maxHeight: 480),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TaxEasyColors.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _PanelHeader(cs: cs, onRefresh: onRefresh, onClose: onClose),

            // Bot greeting bubble
            _BotBubble(
              text: loading
                  ? 'Đang phân tích dữ liệu kinh doanh của bạn...'
                  : insights.isEmpty
                      ? 'Mọi thứ đang ổn! Không có vấn đề gì cần chú ý lúc này.'
                      : 'Tôi phát hiện ${insights.length} điều cần lưu ý${_countWarnings(insights) > 0 ? ', trong đó ${_countWarnings(insights)} cảnh báo quan trọng' : ''}:',
              loading: loading,
              cs: cs,
            ),

            if (!loading && insights.isNotEmpty) ...[
              const Divider(height: 1, indent: 16, endIndent: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  itemCount: insights.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _InsightMessage(
                    insight: insights[i],
                    cs: cs,
                  ),
                ),
              ),
            ],

            if (!loading && insights.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 18, color: TaxEasyColors.success),
                    SizedBox(width: 8),
                    Text(
                      'Kinh doanh đang tốt!',
                      style: TextStyle(
                        fontSize: 13,
                        color: TaxEasyColors.success,
                        fontWeight: FontWeight.w600,
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

  int _countWarnings(List<Map<String, dynamic>> list) =>
      list.where((i) => i['type'] == 'warning').length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  final ColorScheme cs;
  final VoidCallback? onRefresh;
  final VoidCallback onClose;

  const _PanelHeader({
    required this.cs,
    required this.onRefresh,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
      decoration: const BoxDecoration(
        gradient: TaxEasyGradients.brand,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TaxEasy AI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Trợ lý kinh doanh thông minh',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  size: 20, color: Colors.white),
              tooltip: 'Cập nhật',
              onPressed: onRefresh,
              visualDensity: VisualDensity.compact,
            ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 20, color: Colors.white),
            tooltip: 'Đóng',
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _BotBubble extends StatelessWidget {
  final String text;
  final bool loading;
  final ColorScheme cs;

  const _BotBubble({
    required this.text,
    required this.loading,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 48, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              gradient: TaxEasyGradients.brand,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded,
                size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: TaxEasyColors.surfaceLow,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                border:
                    Border.all(color: TaxEasyColors.outlineVariant),
              ),
              child: loading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: TaxEasyColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightMessage extends StatelessWidget {
  final Map<String, dynamic> insight;
  final ColorScheme cs;

  const _InsightMessage({required this.insight, required this.cs});

  @override
  Widget build(BuildContext context) {
    final type = insight['type'] as String? ?? 'info';
    final title = insight['title'] as String? ?? '';
    final body = insight['body'] as String? ?? '';

    final (icon, bgColor, accentColor) = switch (type) {
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
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 8),
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
                      height: 1.45,
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

