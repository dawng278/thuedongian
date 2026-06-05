import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';
import '../../providers/invoices_provider.dart';
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
  // cart: productId → quantity
  final Map<String, int> _cart = {};

  int get _totalAmount {
    final prods = context.read<ProductsProvider>().products;
    return _cart.entries.fold(0, (sum, e) {
      final p = prods.firstWhere((p) => p.id == e.key, orElse: () => _emptyProduct);
      return sum + p.price * e.value;
    });
  }

  static final _emptyProduct = ProductDto(
    id: '', storeId: '', name: '', price: 0, isActive: false,
    updatedAt: DateTime(2026),
  );

  void _tap(ProductDto product) {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final products = provider.products;
    final color = Theme.of(context).colorScheme;
    final cartCount = _cart.values.fold(0, (a, b) => a + b);

    if (provider.loading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: color.outline),
            const SizedBox(height: 16),
            Text('Chưa có món nào', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Thêm món trong chế độ Quản lý'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: products.length,
            itemBuilder: (context, i) => _ProductTile(
              product: products[i],
              qty: _cart[products[i].id] ?? 0,
              onTap: () => _tap(products[i]),
            ),
          ),
        ),
        if (cartCount > 0)
          _CartBar(
            cart: _cart,
            products: products,
            total: _totalAmount,
            onRemove: _removeFromCart,
            onClear: _clearCart,
          ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductDto product;
  final int qty;
  final VoidCallback onTap;

  const _ProductTile({required this.product, required this.qty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final hasQty = qty > 0;

    return Card(
      elevation: hasQty ? 4 : 1,
      color: hasQty ? color.primaryContainer : color.surfaceContainerHighest,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasQty)
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: color.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$qty',
                    style: TextStyle(color: color.onPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                )
              else
                Icon(Icons.fastfood_outlined, size: 28, color: color.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: hasQty ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${_currencyFmt.format(product.price)}đ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: hasQty ? color.primary : color.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final color = Theme.of(context).colorScheme;
    final itemCount = cart.values.fold(0, (a, b) => a + b);

    return Container(
      color: color.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.shopping_cart, color: color.primary),
          const SizedBox(width: 8),
          Text(
            '$itemCount món',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '${_currencyFmt.format(total)}đ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () => _showCartDialog(context),
            icon: const Icon(Icons.receipt_outlined, size: 18),
            label: const Text('Tính tiền'),
          ),
        ],
      ),
    );
  }

  void _showCartDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
    final color = Theme.of(context).colorScheme;
    final entries = cart.entries.toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(color: color.outline, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Đơn hàng', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(onPressed: () { Navigator.pop(context); onClear(); }, child: const Text('Xóa tất cả')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final entry = entries[i];
                final product = products.firstWhere((p) => p.id == entry.key);
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('${_currencyFmt.format(product.price)}đ x ${entry.value}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_currencyFmt.format(product.price * entry.value)}đ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => onRemove(entry.key),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: Row(
              children: [
                Text(
                  'Tổng: ${_currencyFmt.format(total)}đ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color.primary, fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _ConfirmSaleButton(cart: cart, products: products, total: total, onClear: onClear),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
        Navigator.pop(context); // close cart sheet
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
            backgroundColor: offline ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Xem QR',
              textColor: Colors.white,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoiceQrScreen(invoice: result.invoice),
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo hóa đơn: $e'), backgroundColor: Colors.red),
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
      icon: _loading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.check),
      label: const Text('Xác nhận bán'),
    );
  }
}
