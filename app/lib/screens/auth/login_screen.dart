import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/taxeasy_design.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await context.read<AuthProvider>().login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AuthProvider>().errorMessage ?? 'Đăng nhập thất bại',
          ),
          backgroundColor: TaxEasyColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          if (isWide) {
            return Row(
              children: [
                const Expanded(
                  flex: 5,
                  child: TaxEasyAuthVisual(
                    title: 'ThueDonGian',
                    subtitle:
                        'Bán hàng rõ ràng, quản lý nhiều quán và theo dõi thuế trong một nơi.',
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(48),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 448),
                        child: _LoginForm(
                          formKey: _formKey,
                          emailCtrl: _emailCtrl,
                          passCtrl: _passCtrl,
                          loading: _loading,
                          obscure: _obscure,
                          rememberMe: _rememberMe,
                          onTogglePassword: () =>
                              setState(() => _obscure = !_obscure),
                          onRememberChanged: (value) =>
                              setState(() => _rememberMe = value),
                          onSubmit: _submit,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Layout dọc: hero banner nhỏ phía trên, form cuộn phía dưới
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: (constraints.maxHeight * 0.32).clamp(180.0, 260.0),
                child: const TaxEasyAuthVisual(
                  title: 'ThueDonGian',
                  subtitle: 'Bán hàng rõ ràng. Thuế nhẹ đầu.',
                  compact: true,
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: TaxEasyColors.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(TaxEasyRadii.hero),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 24,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                      child: _LoginForm(
                        formKey: _formKey,
                        emailCtrl: _emailCtrl,
                        passCtrl: _passCtrl,
                        loading: _loading,
                        obscure: _obscure,
                        rememberMe: _rememberMe,
                        showHandle: true,
                        onTogglePassword: () =>
                            setState(() => _obscure = !_obscure),
                        onRememberChanged: (value) =>
                            setState(() => _rememberMe = value),
                        onSubmit: _submit,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool loading;
  final bool obscure;
  final bool rememberMe;
  final bool showHandle;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.loading,
    required this.obscure,
    required this.rememberMe,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onSubmit,
    this.showHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHandle) ...[
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: TaxEasyColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
          const Text(
            'Đăng nhập',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: TaxEasyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tiếp tục quản lý các quán của bạn',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: TaxEasyColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: passCtrl,
            obscureText: obscure,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: cs.onSurfaceVariant,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            validator: (v) => (v == null || v.length < 6)
                ? 'Mật khẩu tối thiểu 6 ký tự'
                : null,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 190),
                child: GestureDetector(
                  onTap: () => onRememberChanged(!rememberMe),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Checkbox(
                          value: rememberMe,
                          onChanged: (value) =>
                              onRememberChanged(value ?? false),
                        ),
                      ),
                      const Flexible(
                        child: Text(
                          'Ghi nhớ đăng nhập',
                          style: TextStyle(color: TaxEasyColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                ),
                child: const Text('Quên mật khẩu?'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          TaxEasyGradientButton(
            onPressed: loading ? null : onSubmit,
            icon: Icons.login,
            label: 'Đăng nhập',
            loading: loading,
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Chưa có tài khoản?',
                style: TextStyle(color: TaxEasyColors.textSecondary),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('Đăng ký ngay'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
