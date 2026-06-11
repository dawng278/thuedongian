import 'package:flutter/material.dart';
import '../../theme/taxeasy_design.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: TaxEasyColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A6BF5),
                  Color(0xFF004AC6),
                  Color(0xFF002A80),
                ],
              ),
            ),
          ),

          // Decorative blobs
          const Positioned(
            top: -70,
            right: -70,
            child: _Blob(size: 240, opacity: 0.09),
          ),
          Positioned(
            top: size.height * 0.13,
            left: -50,
            child: const _Blob(size: 160, opacity: 0.06),
          ),
          Positioned(
            top: size.height * 0.38,
            right: 16,
            child: const _Blob(size: 90, opacity: 0.10),
          ),
          Positioned(
            top: size.height * 0.22,
            left: size.width * 0.55,
            child: const _Blob(size: 50, opacity: 0.13),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Hero section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🧾', style: TextStyle(fontSize: 50)),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // App name
                        const Text(
                          'ThueDonGian',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Bán hàng rõ ràng · Thuế nhẹ đầu',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Feature chips
                        const Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            _Chip(icon: Icons.bolt_rounded, label: 'Bán nhanh'),
                            _Chip(
                                icon: Icons.wifi_off_rounded, label: 'Offline'),
                            _Chip(
                              icon: Icons.receipt_long_rounded,
                              label: 'Hóa đơn điện tử',
                            ),
                            _Chip(
                              icon: Icons.bar_chart_rounded,
                              label: 'Báo cáo thông minh',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 12),
                  decoration: const BoxDecoration(
                    color: TaxEasyColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(TaxEasyRadii.hero),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x28000000),
                        blurRadius: 32,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TaxEasyGradientButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          icon: Icons.login_rounded,
                          label: 'Đăng nhập',
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.person_add_outlined),
                          label: const Text('Tạo tài khoản mới'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: TaxEasyColors.primary,
                            side: const BorderSide(
                              color: TaxEasyColors.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(TaxEasyRadii.input),
                            ),
                            minimumSize: const Size(double.infinity, 52),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'IT Solution Challenge 2026',
                            style: TextStyle(
                              color: TaxEasyColors.textSecondary
                                  .withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
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

class _Blob extends StatelessWidget {
  final double size;
  final double opacity;

  const _Blob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
