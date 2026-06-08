import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/taxeasy_design.dart';
import 'login_screen.dart';

/// Entry point: màn hình nhập email để tìm tài khoản.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);

    final email = _emailCtrl.text.trim().toLowerCase();
    // Mock: chỉ 2 tài khoản demo được coi là tồn tại.
    const knownAccounts = {'owner@taxeasy.vn', 'manager@taxeasy.vn'};
    final found = knownAccounts.contains(email);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => found
            ? _AccountFoundScreen(email: _emailCtrl.text.trim())
            : const _AccountNotFoundScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: TaxEasyColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 56,
                    color: TaxEasyColors.primary,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Tìm tài khoản của bạn',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: TaxEasyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nhập địa chỉ email bạn đã dùng để đăng ký tài khoản TaxEasy.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: TaxEasyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _find(),
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ email',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'example@email.com',
                  ),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
                ),
                const SizedBox(height: 28),
                TaxEasyGradientButton(
                  onPressed: _loading ? null : _find,
                  icon: Icons.search,
                  label: 'Tìm tài khoản',
                  loading: _loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Màn hình: TÌM THẤY tài khoản
// ──────────────────────────────────────────────────────────────

class _AccountFoundScreen extends StatefulWidget {
  final String email;
  const _AccountFoundScreen({required this.email});

  @override
  State<_AccountFoundScreen> createState() => _AccountFoundScreenState();
}

class _AccountFoundScreenState extends State<_AccountFoundScreen> {
  bool _sending = false;

  Future<void> _sendOtp() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _sending = false);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _OtpScreen(email: widget.email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      appBar: AppBar(
        title: const Text('Tài khoản tìm thấy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 56,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Tìm thấy tài khoản!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: TaxEasyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: TaxEasyColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Tài khoản gắn với email\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: TaxEasyColors.textPrimary,
                      ),
                    ),
                    const TextSpan(
                        text: '\nđã được xác nhận. Chúng tôi sẽ gửi mã OTP để đặt lại mật khẩu.'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TaxEasyColors.surfaceLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TaxEasyColors.outlineVariant),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline,
                        color: TaxEasyColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gửi đến',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: TaxEasyColors.textSecondary)),
                          Text(
                            widget.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: TaxEasyColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TaxEasyGradientButton(
                onPressed: _sending ? null : _sendOtp,
                icon: Icons.send_rounded,
                label: 'Gửi mã xác nhận',
                loading: _sending,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Màn hình: KHÔNG TÌM THẤY tài khoản
// ──────────────────────────────────────────────────────────────

class _AccountNotFoundScreen extends StatelessWidget {
  const _AccountNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      appBar: AppBar(
        title: const Text('Không tìm thấy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 56,
                  color: Color(0xFFE65100),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Không tìm thấy tài khoản',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: TaxEasyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Không có tài khoản TaxEasy nào gắn với email này.\nKiểm tra lại email hoặc tạo tài khoản mới.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: TaxEasyColors.textSecondary,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Thử lại'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Về trang đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Màn hình: NHẬP OTP
// ──────────────────────────────────────────────────────────────

class _OtpScreen extends StatefulWidget {
  final String email;
  const _OtpScreen({required this.email});

  @override
  State<_OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<_OtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;

  static const _resendSeconds = 60;
  int _remaining = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _remaining = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_remaining <= 1) {
        t.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _resend() {
    if (_remaining > 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi lại mã xác nhận')),
    );
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  void _onChanged(int i, String val) {
    if (val.length == 1 && i < 5) {
      _nodes[i + 1].requestFocus();
    }
    if (val.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
    setState(() => _error = null);
  }

  Future<void> _verify() async {
    if (_otp.length < 6) {
      setState(() => _error = 'Nhập đủ 6 chữ số');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);

    // Mock: OTP đúng là "123456" hoặc bất kỳ 6 chữ số nào (demo)
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ChangePasswordScreen(email: widget.email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Nhập mã OTP'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Nhập mã xác nhận',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: TaxEasyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: TaxEasyColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Mã 6 chữ số đã gửi đến '),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TaxEasyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 46,
                    height: 56,
                    child: TextFormField(
                      controller: _ctrls[i],
                      focusNode: _nodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _error != null
                                ? TaxEasyColors.error
                                : TaxEasyColors.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: cs.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: TaxEasyColors.background,
                      ),
                      onChanged: (v) => _onChanged(i, v),
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: TaxEasyColors.error,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _remaining > 0 ? null : _resend,
                  child: Text(
                    _remaining > 0
                        ? 'Gửi lại mã sau ${_remaining}s'
                        : 'Gửi lại mã',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TaxEasyGradientButton(
                onPressed: _loading ? null : _verify,
                icon: Icons.verified_user_outlined,
                label: 'Xác nhận',
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Màn hình: ĐỔI MẬT KHẨU
// ──────────────────────────────────────────────────────────────

class _ChangePasswordScreen extends StatefulWidget {
  final String email;
  const _ChangePasswordScreen({required this.email});

  @override
  State<_ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<_ChangePasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded,
            color: Color(0xFF2E7D32), size: 48),
        title: const Text('Đổi mật khẩu thành công!'),
        content: const Text(
            'Mật khẩu của bạn đã được cập nhật. Hãy đăng nhập lại.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (r) => false,
              );
            },
            child: const Text('Về đăng nhập'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Tạo mật khẩu mới',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: TaxEasyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mật khẩu mới phải có ít nhất 6 ký tự.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: TaxEasyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure1,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure1
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Tối thiểu 6 ký tự' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure2,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure2
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  validator: (v) => v != _passCtrl.text
                      ? 'Mật khẩu xác nhận không khớp'
                      : null,
                ),
                const SizedBox(height: 32),
                TaxEasyGradientButton(
                  onPressed: _loading ? null : _submit,
                  icon: Icons.check,
                  label: 'Đổi mật khẩu',
                  loading: _loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
