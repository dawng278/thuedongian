import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/stores_provider.dart';
import '../../theme/taxeasy_design.dart';

/// Kiểm tra mã số thuế Việt Nam: rỗng (cho phép) hoặc đúng 10 / 13 chữ số.
/// MST 13 số có dạng 10 số + '-' + 3 số đơn vị phụ thuộc; ở đây chấp nhận
/// cả khi người dùng nhập liền không dấu gạch.
String? validateTaxId(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  final digits = v.replaceAll('-', '');
  if (!RegExp(r'^\d+$').hasMatch(digits)) {
    return 'Mã số thuế chỉ gồm chữ số';
  }
  if (digits.length != 10 && digits.length != 13) {
    return 'Mã số thuế phải có 10 hoặc 13 chữ số';
  }
  return null;
}

/// Màn hình sửa thông tin quán: tên, loại hình, MST, địa chỉ, SĐT.
/// MST bắt buộc để xuất được hóa đơn điện tử hợp lệ.
class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _taxIdCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  String _businessType = 'food_beverage';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final store = context.read<StoresProvider>().currentStore;
    _nameCtrl = TextEditingController(text: store?.name ?? '');
    _taxIdCtrl = TextEditingController(text: store?.taxId ?? '');
    _addressCtrl = TextEditingController(text: store?.address ?? '');
    _phoneCtrl = TextEditingController(text: store?.phone ?? '');
    _businessType = store?.businessType ?? 'food_beverage';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taxIdCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<StoresProvider>().updateCurrentStore(
            name: _nameCtrl.text,
            businessType: _businessType,
            taxId: _taxIdCtrl.text,
            address: _addressCtrl.text,
            phone: _phoneCtrl.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu thông tin quán'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lưu thất bại: $e'),
            backgroundColor: TaxEasyColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt quán')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên quán *',
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập tên quán' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _businessType,
              decoration: const InputDecoration(
                labelText: 'Loại hình kinh doanh',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'food_beverage', child: Text('Ăn uống')),
                DropdownMenuItem(value: 'goods', child: Text('Hàng hóa')),
                DropdownMenuItem(value: 'services', child: Text('Dịch vụ')),
              ],
              onChanged: (v) =>
                  setState(() => _businessType = v ?? 'food_beverage'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _taxIdCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Mã số thuế',
                hintText: '10 hoặc 13 chữ số — cần cho hóa đơn điện tử',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: validateTaxId,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Đang lưu...' : 'Lưu thông tin'),
            ),
          ],
        ),
      ),
    );
  }
}
