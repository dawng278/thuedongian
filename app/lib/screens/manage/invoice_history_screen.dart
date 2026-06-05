import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/invoice.dart';
import '../../services/api_service.dart';
import '../sale/invoice_qr_screen.dart';

final _currencyFmt = NumberFormat('#,###', 'vi_VN');
final _dateFmt = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  final List<InvoiceDto> _invoices = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 1;
  static const _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final api = context.read<ApiService>();
      final result = await api.getInvoices(page: _page, limit: _limit);
      setState(() {
        _invoices.addAll(result);
        _page++;
        if (result.length < _limit) _hasMore = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải lịch sử: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _invoices.clear();
      _page = 1;
      _hasMore = true;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _invoices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_invoices.isEmpty) {
      return const Center(child: Text('Chưa có hóa đơn nào'));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        itemCount: _invoices.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == _invoices.length) {
            if (!_loading) _loadMore();
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _InvoiceTile(invoice: _invoices[i]);
        },
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  final InvoiceDto invoice;
  const _InvoiceTile({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final num = invoice.invoiceNumber;
    return ListTile(
      leading: CircleAvatar(child: Text('#${num ?? '?'}')),
      title: Text(
        '${_currencyFmt.format(invoice.totalAmount)}đ',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(_dateFmt.format(invoice.createdAt)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDetail(context),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _InvoiceDetailSheet(invoice: invoice),
    );
  }
}

class _InvoiceDetailSheet extends StatelessWidget {
  final InvoiceDto invoice;
  const _InvoiceDetailSheet({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final num = invoice.invoiceNumber;
    final items = invoice.items ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scroll) => Column(
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
                Text('Hóa đơn #${num ?? '?'}', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  tooltip: 'Xem QR',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InvoiceQrScreen(invoice: invoice)),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _dateFmt.format(invoice.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ...items.map(
                  (item) => ListTile(
                    dense: true,
                    title: Text('${item.productName} x${item.quantity}'),
                    trailing: Text('${_currencyFmt.format(item.subtotal)}đ'),
                  ),
                ),
                const Divider(),
                ListTile(
                  dense: true,
                  title: const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(
                    '${_currencyFmt.format(invoice.totalAmount)}đ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color.primary),
                  ),
                ),
                if (invoice.note != null && invoice.note!.isNotEmpty)
                  ListTile(
                    dense: true,
                    title: const Text('Ghi chú'),
                    subtitle: Text(invoice.note!),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }
}
