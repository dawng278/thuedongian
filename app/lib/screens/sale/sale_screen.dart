import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';
import '../../providers/invoices_provider.dart';
import '../../theme/taxeasy_design.dart';
import 'invoice_qr_screen.dart';

final _currencyFmt = NumberFormat('#,###', 'vi_VN');

class SaleScreen extends StatelessWidget {
  const SaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SaleView();
  }
}

class _SaleView extends StatefulWidget {
  const _SaleView();

  @override
  State<_SaleView> createState() => _SaleViewState();
}

class _SaleViewState extends State<_SaleView> {
  final Map<String, int> _cart = {};
  String? _selectedCategory;

  int get _totalAmount {
    final prods = context.read<ProductsProvider>().products;
    return _cart.entries.fold(0, (sum, e) {
      final p =
          prods.firstWhere((p) => p.id == e.key, orElse: () => _emptyProduct);
      return sum + p.price * e.value;
    });
  }

  static final _emptyProduct = ProductDto(
    id: '',
    storeId: '',
    name: '',
    price: 0,
    isActive: false,
    updatedAt: DateTime(2026),
  );

  void _addToCart(ProductDto product) {
    setState(() {
      _cart[product.id] = (_cart[product.id] ?? 0) + 1;
    });
  }

  void _removeFromCart(String productId) {
    setState(() {
      final qty = _cart[productId] ?? 0;
      if (qty <= 1) {
        _cart.remove(productId);
      } else {
        _cart[productId] = qty - 1;
      }
    });
  }

  void _clearCart() => setState(() => _cart.clear());

  List<String> _categories(List<ProductDto> products) {
    final cats = products
        .where((p) => p.category != null && p.category!.isNotEmpty)
        .map((p) => p.category!)
        .toSet()
        .toList();
    return cats;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final allProducts = provider.products;
    final categories = _categories(allProducts);
    final products = _selectedCategory == null
        ? allProducts
        : allProducts.where((p) => p.category == _selectedCategory).toList();
    final cartCount = _cart.values.fold(0, (a, b) => a + b);

    if (provider.loading && allProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            const Text('Chưa có món nào',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              'Thêm món trong chế độ Quản lý',
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Category chips
        if (categories.isNotEmpty)
          SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: 'Tất cả',
                  isActive: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ...categories.map((cat) => _CategoryChip(
                      label: cat,
                      isActive: _selectedCategory == cat,
                      onTap: () => setState(() => _selectedCategory = cat),
                    )),
              ],
            ),
          ),

        // Product grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(16, categories.isNotEmpty ? 0 : 12, 16,
                cartCount > 0 ? 100 : 16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];
              return _ProductCard(
                product: p,
                qty: _cart[p.id] ?? 0,
                onAdd: () => _addToCart(p),
                onRemove: () => _removeFromCart(p.id),
              );
            },
          ),
        ),

        // Cart bar
        if (cartCount > 0)
          _CartBar(
            cart: _cart,
            products: allProducts,
            total: _totalAmount,
            onRemove: _removeFromCart,
            onClear: _clearCart,
          ),
      ],
    );
  }
}

// ── Category Chip ──────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? TaxEasyColors.surfaceLow : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive ? cs.primary : TaxEasyColors.outlineVariant,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: cs.primary.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 3)
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? cs.primary : cs.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Product Card ───────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductDto product;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ProductCard({
    required this.product,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  static const _avatarColors = [
    Color(0xFFDBE1FF), // blue-tinted light
    Color(0xFFC4E7FF), // sky light
    Color(0xFFDAE2FD), // indigo light
    Color(0xFFE5EEFF), // primary-container
    Color(0xFFD3E4FE), // surface-variant
    Color(0xFFEFF4FF), // surface-container-low
  ];

  static const _avatarTextColors = [
    Color(0xFF004AC6),
    Color(0xFF00668A),
    Color(0xFF3F465C),
    Color(0xFF004AC6),
    Color(0xFF004AC6),
    Color(0xFF004AC6),
  ];

  Color _avatarBg() {
    final sum = product.name.codeUnits.fold(0, (a, b) => a + b);
    return _avatarColors[sum % _avatarColors.length];
  }

  Color _avatarTextColor() {
    final sum = product.name.codeUnits.fold(0, (a, b) => a + b);
    return _avatarTextColors[sum % _avatarTextColors.length];
  }

  bool get _hasImage =>
      product.imageUrl != null && product.imageUrl!.trim().isNotEmpty;

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
    final isSelected = qty > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: TaxEasyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? cs.primary : TaxEasyColors.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isSelected ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image / avatar area
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: _hasImage
                      ? Image.network(
                          product.imageUrl!.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _AvatarFallback(
                            initials: _initials(),
                            bg: _avatarBg(),
                            fg: _avatarTextColor(),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const ColoredBox(
                                color: TaxEasyColors.surfaceLow);
                          },
                        )
                      : _AvatarFallback(
                          initials: _initials(),
                          bg: _avatarBg(),
                          fg: _avatarTextColor(),
                        ),
                ),
              ),
              // Info area
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B1C30),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_currencyFmt.format(product.price)}đ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? cs.primary : cs.primary,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 6),
                        _Stepper(qty: qty, onAdd: onAdd, onRemove: onRemove),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Tap overlay for unselected
          if (!isSelected)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onAdd,
                ),
              ),
            ),

          // Badge
          if (isSelected)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.error,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$qty',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initials;
  final Color bg;
  final Color fg;

  const _AvatarFallback({
    required this.initials,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bg,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: fg,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _Stepper(
      {required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _StepBtn(icon: Icons.remove, onTap: onRemove, isAdd: false),
          Expanded(
            child: Center(
              child: Text(
                '$qty',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: onAdd, isAdd: true),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isAdd;

  const _StepBtn(
      {required this.icon, required this.onTap, required this.isAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isAdd ? cs.primary : Colors.white,
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06), blurRadius: 2)
          ],
        ),
        child: Icon(
          icon,
          size: 14,
          color: isAdd ? Colors.white : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Cart Bar ───────────────────────────────────────────────────────────────

class _CartBar extends StatelessWidget {
  final Map<String, int> cart;
  final List<ProductDto> products;
  final int total;
  final void Function(String) onRemove;
  final VoidCallback onClear;

  const _CartBar({
    required this.cart,
    required this.products,
    required this.total,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = cart.values.fold(0, (a, b) => a + b);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: TaxEasyGradients.horizontal,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TaxEasyColors.primary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined,
                  color: Colors.white, size: 24),
              Positioned(
                top: -4,
                right: -6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA1A1A),
                    borderRadius: BorderRadius.circular(999),
                    border:
                        Border.all(color: TaxEasyColors.primary, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$itemCount món',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  '${_currencyFmt.format(total)}đ',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCartSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: TaxEasyColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text(
              'Tính tiền',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CartSheet(
        cart: cart,
        products: products,
        total: total,
        onRemove: onRemove,
        onClear: onClear,
      ),
    );
  }
}

// ── Cart Sheet ─────────────────────────────────────────────────────────────

class _CartSheet extends StatelessWidget {
  final Map<String, int> cart;
  final List<ProductDto> products;
  final int total;
  final void Function(String) onRemove;
  final VoidCallback onClear;

  const _CartSheet({
    required this.cart,
    required this.products,
    required this.total,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final entries = cart.entries.toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Đơn hàng',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onClear();
                    },
                    style: TextButton.styleFrom(foregroundColor: cs.error),
                    child: const Text('Xóa tất cả'),
                  ),
                ],
              ),
            ),
            // Items
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: entries.length,
                itemBuilder: (context, i) {
                  final entry = entries[i];
                  final product = products.firstWhere((p) => p.id == entry.key);
                  return _CartItem(
                    product: product,
                    qty: entry.value,
                    onRemove: () => onRemove(entry.key),
                  );
                },
              ),
            ),
            // Footer
            Container(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.5))),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -4))
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tổng cộng (${cart.values.fold(0, (a, b) => a + b)} món)',
                        style:
                            TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                      Text(
                        '${_currencyFmt.format(total)}đ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _ConfirmSaleButton(
                      cart: cart,
                      products: products,
                      total: total,
                      onClear: onClear),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final ProductDto product;
  final int qty;
  final VoidCallback onRemove;

  const _CartItem(
      {required this.product, required this.qty, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30))),
                Text('${_currencyFmt.format(product.price)}đ × $qty',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text(
            '${_currencyFmt.format(product.price * qty)}đ',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: cs.primary),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.remove_circle_outline, size: 20, color: cs.error),
            onPressed: onRemove,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// ── Confirm Button ─────────────────────────────────────────────────────────

class _ConfirmSaleButton extends StatefulWidget {
  final Map<String, int> cart;
  final List<ProductDto> products;
  final int total;
  final VoidCallback onClear;

  const _ConfirmSaleButton({
    required this.cart,
    required this.products,
    required this.total,
    required this.onClear,
  });

  @override
  State<_ConfirmSaleButton> createState() => _ConfirmSaleButtonState();
}

class _ConfirmSaleButtonState extends State<_ConfirmSaleButton> {
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      final result = await context.read<InvoicesProvider>().createInvoice(
            Map.of(widget.cart),
            widget.products,
          );
      if (mounted) {
        Navigator.pop(context);
        widget.onClear();
        final num = result.serverNumber ?? result.localNumber;
        final offline = result.serverNumber == null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              offline
                  ? 'Hóa đơn #$num (offline) — ${_currencyFmt.format(widget.total)}đ'
                  : 'Hóa đơn #$num — ${_currencyFmt.format(widget.total)}đ',
            ),
            backgroundColor:
                offline ? const Color(0xFFD97706) : const Color(0xFF059669),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Xem QR',
              textColor: Colors.white,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => InvoiceQrScreen(invoice: result.invoice)),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi tạo hóa đơn: $e'),
              backgroundColor: const Color(0xFFBA1A1A)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _loading ? null : _confirm,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF004AC6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      icon: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.check_circle_outline, size: 18),
      label: const Text('Xác nhận bán',
          style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
