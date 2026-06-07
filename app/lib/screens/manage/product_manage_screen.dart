import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';

final _fmt = NumberFormat('#,###', 'vi_VN');

class ProductManageScreen extends StatefulWidget {
  const ProductManageScreen({super.key});

  @override
  State<ProductManageScreen> createState() => _ProductManageScreenState();
}

class _ProductManageScreenState extends State<ProductManageScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> _categories(List<ProductDto> products) {
    final cats = products
        .map((p) => p.category ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    return cats;
  }

  List<ProductDto> _filtered(List<ProductDto> products) {
    var list = products;
    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  void _showProductDialog(BuildContext context, ProductDto? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductFormSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final cs = Theme.of(context).colorScheme;
    final allProducts = provider.products;
    final cats = _categories(allProducts);
    final filtered = _filtered(allProducts);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: provider.loading && allProducts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Sticky search + filter header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchHeaderDelegate(
                    searchCtrl: _searchCtrl,
                    categories: cats,
                    selectedCategory: _selectedCategory,
                    cs: cs,
                    onSearch: (v) => setState(() => _searchQuery = v),
                    onCategory: (v) => setState(() => _selectedCategory = v),
                  ),
                ),

                // Product list
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 56, color: cs.outline),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Không tìm thấy sản phẩm'
                                : 'Chưa có sản phẩm',
                            style: TextStyle(
                                fontSize: 14, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ProductTile(
                            product: filtered[i],
                            onEdit: () =>
                                _showProductDialog(context, filtered[i]),
                            onHide: () async {
                              await provider.deleteProduct(filtered[i].id);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Đã ẩn "${filtered[i].name}"')),
                                );
                              }
                            },
                          ),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton:
          _AddFab(onTap: () => _showProductDialog(context, null), cs: cs),
    );
  }
}

// ── Sticky header ──────────────────────────────────────────────────────────

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchCtrl;
  final List<String> categories;
  final String? selectedCategory;
  final ColorScheme cs;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onCategory;

  const _SearchHeaderDelegate({
    required this.searchCtrl,
    required this.categories,
    required this.selectedCategory,
    required this.cs,
    required this.onSearch,
    required this.onCategory,
  });

  @override
  double get minExtent => categories.isEmpty ? 68.0 : 112.0;
  @override
  double get maxExtent => categories.isEmpty ? 68.0 : 112.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF8F9FF),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // Search bar
          SizedBox(
            height: 44,
            child: TextField(
              controller: searchCtrl,
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon:
                    Icon(Icons.search, size: 20, color: cs.onSurfaceVariant),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFC3C6D7)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFC3C6D7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: Color(0xFF004AC6), width: 2),
                ),
              ),
            ),
          ),
          // Category chips
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: 'Tất cả',
                    isActive: selectedCategory == null,
                    onTap: () => onCategory(null),
                    cs: cs,
                  ),
                  ...categories.map((cat) => _FilterChip(
                        label: cat,
                        isActive: selectedCategory == cat,
                        onTap: () => onCategory(cat),
                        cs: cs,
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchHeaderDelegate old) =>
      old.categories != categories || old.selectedCategory != selectedCategory;
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _FilterChip(
      {required this.label,
      required this.isActive,
      required this.onTap,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? cs.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: isActive ? cs.primary : const Color(0xFFC3C6D7)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── Product tile ──────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  final ProductDto product;
  final VoidCallback onEdit;
  final VoidCallback onHide;

  const _ProductTile(
      {required this.product, required this.onEdit, required this.onHide});

  String _initials() {
    final parts = product.name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    return product.name
        .substring(0, product.name.length.clamp(1, 2))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isHidden = !product.isActive;

    return Opacity(
      opacity: isHidden ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC3C6D7)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            // Thumbnail / Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _initials(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (product.category != null &&
                          product.category!.isNotEmpty)
                        product.category!,
                      if (product.unit != null && product.unit!.isNotEmpty)
                        product.unit!,
                    ].join(' • '),
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${_fmt.format(product.price)}đ',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cs.primary),
                      ),
                      const Spacer(),
                      _StatusBadge(isHidden: isHidden, cs: cs),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') {
                  onEdit();
                } else if (v == 'hide') {
                  onHide();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Sửa thông tin')),
                PopupMenuItem(value: 'hide', child: Text('Ẩn sản phẩm')),
              ],
              icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant, size: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isHidden;
  final ColorScheme cs;
  const _StatusBadge({required this.isHidden, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isHidden ? const Color(0xFFD3E4FE) : const Color(0xFFE5EEFF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isHidden ? 'Đã ẩn' : 'Đang bán',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isHidden ? cs.onSurfaceVariant : cs.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── FAB ────────────────────────────────────────────────────────────────────

class _AddFab extends StatelessWidget {
  final VoidCallback onTap;
  final ColorScheme cs;
  const _AddFab({required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: cs.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Thêm món',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form Sheet (kept from original, restyled) ──────────────────────────────

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
  late final TextEditingController _costPriceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _categoryCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name);
    _priceCtrl = TextEditingController(text: p != null ? '${p.price}' : '');
    _costPriceCtrl =
        TextEditingController(text: p?.costPrice != null ? '${p!.costPrice}' : '');
    _stockCtrl =
        TextEditingController(text: p?.stock != null ? '${p!.stock}' : '');
    _unitCtrl = TextEditingController(text: p?.unit);
    _categoryCtrl = TextEditingController(text: p?.category);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _costPriceCtrl.dispose();
    _stockCtrl.dispose();
    _unitCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  int? _parseIntField(TextEditingController c) {
    final raw = c.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final provider = context.read<ProductsProvider>();
      final price =
          int.parse(_priceCtrl.text.replaceAll(',', '').replaceAll('.', ''));
      final stock = _parseIntField(_stockCtrl);
      final costPrice = _parseIntField(_costPriceCtrl);
      if (widget.existing == null) {
        await provider.createProduct(
          _nameCtrl.text.trim(),
          price,
          unit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
          category: _categoryCtrl.text.trim().isEmpty
              ? null
              : _categoryCtrl.text.trim(),
          stock: stock,
          costPrice: costPrice,
        );
      } else {
        await provider.updateProduct(widget.existing!.id, {
          'name': _nameCtrl.text.trim(),
          'price': price,
          if (_unitCtrl.text.trim().isNotEmpty) 'unit': _unitCtrl.text.trim(),
          if (_categoryCtrl.text.trim().isNotEmpty)
            'category': _categoryCtrl.text.trim(),
          if (stock != null) 'stock': stock,
          if (costPrice != null) 'cost_price': costPrice,
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
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.existing != null;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B1C30)),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Tên món *', hintText: 'Cà phê đen đá...'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Nhập tên món' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Giá (đồng) *', suffixText: 'đ'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nhập giá';
                final n =
                    int.tryParse(v.replaceAll(',', '').replaceAll('.', ''));
                if (n == null || n <= 0) return 'Giá phải lớn hơn 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Đơn vị', hintText: 'ly, cái...'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _categoryCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Nhóm', hintText: 'Đồ uống...'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costPriceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Giá vốn',
                        hintText: 'để tính lợi nhuận',
                        suffixText: 'đ'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Tồn kho', hintText: 'bỏ trống nếu không'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(isEdit ? 'Lưu thay đổi' : 'Thêm món',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
