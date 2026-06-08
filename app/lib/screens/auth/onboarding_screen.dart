import 'package:flutter/material.dart';
import '../../theme/taxeasy_design.dart';

class OnboardingScreen extends StatefulWidget {
  /// Gọi khi người dùng hoàn tất/bỏ qua onboarding. AuthGate dùng callback này
  /// để chuyển sang Login/Home — đừng tự push màn hình trong onboarding.
  final VoidCallback onDone;

  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache ảnh các slide để chuyển trang không bị khựng.
    if (!_precached) {
      _precached = true;
      for (final s in _slides) {
        precacheImage(NetworkImage(s.imageUrl), context);
      }
    }
  }

  static const _slides = [
    _Slide(
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=85',
      emoji: '🍜',
      title: 'Bán hàng nhanh\nnhư chớp',
      subtitle:
          'Chạm một cái là xong đơn. Hoạt động offline — không cần lo mất mạng giữa chừng.',
    ),
    _Slide(
      imageUrl:
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&q=85',
      emoji: '📊',
      title: 'Quản lý doanh thu\nchỉ trong một app',
      subtitle:
          'Xem biểu đồ, top sản phẩm, lợi nhuận và ước tính thuế ngay trên điện thoại.',
    ),
    _Slide(
      imageUrl:
          'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=800&q=85',
      emoji: '🧾',
      title: 'Hóa đơn điện tử\nđúng chuẩn',
      subtitle:
          'Xuất XML hóa đơn điện tử, quản lý nhiều quán, nhắc nhở hạn nộp thuế tự động.',
    ),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onDone();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen page view
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _slides.length,
            itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
          ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Primary button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: TaxEasyColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(isLast ? 'Bắt đầu ngay' : 'Tiếp theo'),
                      ),
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.onDone,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withValues(alpha: 0.7),
                        ),
                        child: const Text('Bỏ qua'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final String imageUrl;
  final String emoji;
  final String title;
  final String subtitle;

  const _Slide({
    required this.imageUrl,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;

  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image — fade-in khi tải xong để mượt mắt
        Image.network(
          slide.imageUrl,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, wasSyncLoaded) {
            if (wasSyncLoaded || frame != null) {
              return AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 350),
                child: child,
              );
            }
            return Container(color: TaxEasyColors.primary);
          },
          errorBuilder: (_, __, ___) => Container(
            color: TaxEasyColors.primary,
          ),
        ),

        // Dark gradient overlay (bottom heavy để text đọc được)
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.35, 0.65, 1.0],
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),

        // Text content
        Positioned(
          left: 28,
          right: 28,
          bottom: size.height * 0.24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                slide.emoji,
                style: const TextStyle(fontSize: 44),
              ),
              const SizedBox(height: 14),
              Text(
                slide.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                slide.subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
