import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';

final _fmt = NumberFormat('#,###', 'vi_VN');

class ProductManageScreen extends StatelessWidget {
  const ProductManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: provider.loading && provider.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: color.outline),
                      const SizedBox(height: 16),
                      const Text('Chưa có sản phẩm'),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: provider.products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = provider.products[i];
                    return _ProductRow(product: p);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Thêm món'),
      ),
    );
  }

  void _showProductDialog(BuildContext context, ProductDto? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProductFormSheet(existing: existing),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final ProductDto product;
  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.primaryContainer,
        child: Text(
          product.name.substring(0, 1).toUpperCase(),
          style: TextStyle(color: color.onPrimaryContainer, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(product.name),
      subtitle: Text(
        '${_fmt.format(product.price)}đ${product.unit != null ? " / ${product.unit}" : ""}',
        style: TextStyle(color: color.primary),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          final provider = context.read<ProductsProvider>();
          if (v == 'edit') {
            _showEdit(context, product);
          } else if (v == 'hide') {
            await provider.deleteProduct(product.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã ẩn "${product.name}"')),
              );
            }
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Sửa')),
          PopupMenuItem(value: 'hide', child: Text('Ẩn')),
        ],
      ),
    );
  }

  void _showEdit(BuildContext context, ProductDto p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProductFormSheet(existing: p),
    );
  }
}

class _ProductFormSheet extends StatefulWidget {
  final ProductDto? existing;
  const _ProductFormSheet({this.existing});

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _categoryCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name);
    _priceCtrl = TextEditingController(text: p != null ? '${p.price}' : '');
    _unitCtrl = TextEditingController(text: p?.unit);
    _categoryCtrl = TextEditingController(text: p?.category);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _unitCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final provider = context.read<ProductsProvider>();
      final price = int.parse(_priceCtrl.text.replaceAll(',', '').replaceAll('.', ''));
      if (widget.existing == null) {
        await provider.createProduct(
          _nameCtrl.text.trim(),
          price,
          unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
          category: _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
        );
      } else {
        await provider.updateProduct(widget.existing!.id, {
          'name': _nameCtrl.text.trim(),
          'price': price,
          if (_unitCtrl.text.trim().isNotEmpty) 'unit': _unitCtrl.text.trim(),
          if (_categoryCtrl.text.trim().isNotEmpty) 'category': _categoryCtrl.text.trim(),
        });
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Tên món *', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.isEmpty) ? 'Nhập tên món' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Giá (đồng) *', border: OutlineInputBorder(), suffixText: 'đ'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nhập giá';
                final n = int.tryParse(v.replaceAll(',', '').replaceAll('.', ''));
                if (n == null || n < 0) return 'Giá không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(labelText: 'Đơn vị (tuỳ chọn)', border: OutlineInputBorder(), hintText: 'cái, ly, tô...'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _categoryCtrl,
                    decoration: const InputDecoration(labelText: 'Nhóm (tuỳ chọn)', border: OutlineInputBorder(), hintText: 'Đồ uống...'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Lưu thay đổi' : 'Thêm món'),
            ),
          ],
        ),
      ),
    );
  }
}
