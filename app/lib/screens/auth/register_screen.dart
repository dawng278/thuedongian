import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/taxeasy_design.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await context.read<AuthProvider>().register(
          _emailCtrl.text.trim(),
          _passCtrl.text,
          _nameCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              context.read<AuthProvider>().errorMessage ?? 'Đăng ký thất bại'),
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
                    title: 'Tạo tài khoản',
                    subtitle:
                        'Tài khoản của bạn có thể quản lý nhiều quán, mỗi quán có sản phẩm và báo cáo riêng.',
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(48),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 448),
                        child: _RegisterForm(
                          formKey: _formKey,
                          nameCtrl: _nameCtrl,
                          emailCtrl: _emailCtrl,
                          passCtrl: _passCtrl,
                          loading: _loading,
                          obscure: _obscure,
                          onBack: () => Navigator.pop(context),
                          onTogglePassword: () =>
                              setState(() => _obscure = !_obscure),
                          onSubmit: _submit,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: (constraints.maxHeight * 0.28).clamp(160.0, 220.0),
                child: const SafeArea(
                  bottom: false,
                  child: TaxEasyAuthVisual(
                    title: 'Tạo tài khoản',
                    subtitle: 'Tạo tài khoản trước, thêm quán sau.',
                    compact: true,
                  ),
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
                      padding: EdgeInsets.fromLTRB(
                        24,
                        28,
                        24,
                        28 + MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: _RegisterForm(
                        formKey: _formKey,
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        passCtrl: _passCtrl,
                        loading: _loading,
                        obscure: _obscure,
                        onBack: () => Navigator.pop(context),
                        onTogglePassword: () =>
                            setState(() => _obscure = !_obscure),
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

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool loading;
  final bool obscure;
  final VoidCallback onBack;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  const _RegisterForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.loading,
    required this.obscure,
    required this.onBack,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tạo tài khoản',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: TaxEasyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chỉ cần thông tin chủ tài khoản. Bạn có thể tạo nhiều quán sau khi đăng nhập.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: TaxEasyColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          _SectionLabel(label: 'Thông tin tài khoản', color: cs.primary),
          const SizedBox(height: 14),
          TextFormField(
            controller: nameCtrl,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nhập họ tên' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: passCtrl,
            obscureText: obscure,
            autofillHints: const [AutofillHints.newPassword],
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
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TaxEasyColors.surfaceLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TaxEasyColors.outlineVariant),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.add_business_outlined,
                    color: TaxEasyColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sau khi đăng ký, bạn có thể tạo quán đầu tiên hoặc thêm quán mới trong app.',
                    style: TextStyle(
                      color: TaxEasyColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          TaxEasyGradientButton(
            onPressed: loading ? null : onSubmit,
            icon: Icons.arrow_forward,
            label: 'Đăng ký tài khoản',
            loading: loading,
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Đã có tài khoản?',
                style: TextStyle(color: TaxEasyColors.textSecondary),
              ),
              TextButton(
                onPressed: onBack,
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: TaxEasyColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
