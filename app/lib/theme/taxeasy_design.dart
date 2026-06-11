import 'package:flutter/material.dart';

class TaxEasyColors {
  static const primary = Color(0xFF004AC6);
  static const primaryStrong = Color(0xFF003EA8);
  static const primaryContainer = Color(0xFF2563EB);
  static const secondary = Color(0xFF40C2FD);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8F9FF);
  static const surfaceLow = Color(0xFFEFF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const textPrimary = Color(0xFF0B1C30);
  static const textSecondary = Color(0xFF434655);
  static const outline = Color(0xFF737686);
  static const outlineVariant = Color(0xFFC3C6D7);
  static const success = Color(0xFF059669);
  static const warning = Color(0xFFD97706);
  static const error = Color(0xFFBA1A1A);
}

class TaxEasyGradients {
  static const brand = LinearGradient(
    colors: [TaxEasyColors.primary, TaxEasyColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const horizontal = LinearGradient(
    colors: [TaxEasyColors.primary, TaxEasyColors.secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class TaxEasyRadii {
  static const input = 16.0;
  static const card = 16.0;
  static const hero = 32.0;
  static const sheet = 28.0;
}

class TaxEasyShadow {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.045),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> floating = [
    BoxShadow(
      color: TaxEasyColors.primary.withValues(alpha: 0.22),
      blurRadius: 26,
      offset: const Offset(0, 10),
    ),
  ];
}

class TaxEasyGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool loading;

  const TaxEasyGradientButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : TaxEasyGradients.horizontal,
        color: onPressed == null ? Theme.of(context).disabledColor : null,
        borderRadius: BorderRadius.circular(TaxEasyRadii.input),
        boxShadow: onPressed == null ? null : TaxEasyShadow.floating,
      ),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TaxEasyRadii.input),
            ),
          ),
          icon: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, size: 20),
          label: loading
              ? const Text('Đang xử lý...')
              : Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }
}

class TaxEasyAuthVisual extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool compact;

  const TaxEasyAuthVisual({
    super.key,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: TaxEasyGradients.brand),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _ReceiptPatternPainter(),
              isComplex: true,
              willChange: false,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.08),
                Colors.black.withValues(alpha: 0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 28,
            vertical: compact ? 16 : 40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!compact)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.34)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.receipt_long,
                      size: 42, color: Colors.white),
                ),
              if (!compact) const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 24 : 34,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: compact ? 13 : 16,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReceiptPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final fill = Paint()..color = Colors.white.withValues(alpha: 0.045);

    for (double y = -30; y < size.height + 80; y += 120) {
      for (double x = -20; x < size.width + 80; x += 120) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 54, 68),
          const Radius.circular(12),
        );
        canvas.drawRRect(rect, fill);
        canvas.drawRRect(rect, paint);
        canvas.drawLine(Offset(x + 12, y + 22), Offset(x + 42, y + 22), paint);
        canvas.drawLine(Offset(x + 12, y + 36), Offset(x + 36, y + 36), paint);
        canvas.drawLine(Offset(x + 12, y + 50), Offset(x + 44, y + 50), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
