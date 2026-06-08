import 'package:flutter/material.dart';

import '../theme/taxeasy_design.dart';

/// Khối skeleton có hiệu ứng shimmer (sáng quét qua) để báo "đang tải".
/// Mượt hơn spinner vì giữ nguyên bố cục, không nhảy layout khi data về.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 8,
    this.margin,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment(-1.0 - 2 * _ctrl.value, 0),
                end: Alignment(1.0 - 2 * _ctrl.value, 0),
                colors: const [
                  Color(0xFFEDF1FA),
                  Color(0xFFE0E7F5),
                  Color(0xFFEDF1FA),
                ],
                stops: const [0.35, 0.5, 0.65],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton mô phỏng layout dashboard Doanh thu: 1 card lớn + 2 card nhỏ +
/// vùng biểu đồ. Hiển thị trong khi chờ API lần đầu.
class RevenueSkeleton extends StatelessWidget {
  const RevenueSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        SkeletonBox(width: 140, height: 12),
        SizedBox(height: 8),
        SkeletonBox(width: 200, height: 24),
        SizedBox(height: 20),
        // Hero card
        SkeletonBox(height: 132, radius: 20),
        SizedBox(height: 12),
        // Hai card nhỏ
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 92, radius: 16)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 92, radius: 16)),
          ],
        ),
        SizedBox(height: 24),
        SkeletonBox(width: 160, height: 18),
        SizedBox(height: 12),
        // Biểu đồ
        SkeletonBox(height: 200, radius: 20),
        SizedBox(height: 24),
        SkeletonBox(width: 120, height: 18),
        SizedBox(height: 12),
        SkeletonBox(height: 64, radius: 16),
        SizedBox(height: 10),
        SkeletonBox(height: 64, radius: 16),
      ],
    );
  }
}

/// Skeleton cho 1 dòng hóa đơn trong danh sách lịch sử.
class InvoiceRowSkeleton extends StatelessWidget {
  const InvoiceRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaxEasyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TaxEasyColors.outlineVariant),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 44, height: 44, radius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 80, height: 12),
              ],
            ),
          ),
          SkeletonBox(width: 70, height: 18),
        ],
      ),
    );
  }
}
