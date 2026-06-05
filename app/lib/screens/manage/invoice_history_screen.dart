import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/invoice.dart';
import '../../services/api_service.dart';
import '../sale/invoice_qr_screen.dart';

final _currencyFmt = NumberFormat('#,###', 'vi_VN');
final _dateFmt = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
final _dateFmtShort = DateFormat('dd/MM/yyyy', 'vi_VN');

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

  DateTime? _fromDate;
  DateTime? _toDate;

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
      final result = await api.getInvoices(
        from: _fromDate,
        to: _toDate,
        page: _page,
        limit: _limit,
      );
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

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: now,
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _refresh();
    }
  }

  void _clearFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _refresh();
  }

  Future<void> _exportCsv() async {
    // Build CSV from current loaded invoices
    final sb = StringBuffer();
    sb.writeln('Số HĐ,Ngày,Tổng tiền,Ghi chú,Các mặt hàng');
    for (final inv in _invoices) {
      final items = (inv.items ?? []).map((i) => '${i.productName}x${i.quantity}').join(';');
      final note = inv.note?.replaceAll(',', ' ') ?? '';
      sb.writeln('${inv.invoiceNumber ?? '?'},${_dateFmtShort.format(inv.createdAt)},${inv.totalAmount},$note,"$items"');
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/taxeasy_invoices.csv');
      await file.writeAsString(sb.toString(), flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Lịch sử hóa đơn TaxEasy',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xuất báo cáo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = _fromDate != null || _toDate != null;
    final color = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    hasFilter
                        ? '${_dateFmtShort.format(_fromDate!)} – ${_dateFmtShort.format(_toDate!)}'
                        : 'Lọc theo ngày',
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: _pickDateRange,
                ),
              ),
              if (hasFilter)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  tooltip: 'Xóa bộ lọc',
                  onPressed: _clearFilter,
                ),
              IconButton(
                icon: const Icon(Icons.download_outlined),
                tooltip: 'Xuất CSV',
                onPressed: _invoices.isEmpty ? null : _exportCsv,
              ),
            ],
          ),
        ),

        if (_loading && _invoices.isEmpty)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_invoices.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: color.outline),
                  const SizedBox(height: 12),
                  const Text('Chưa có hóa đơn nào'),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
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
            ),
          ),
      ],
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
      leading: CircleAvatar(
        child: Text('#${num ?? '?'}', style: const TextStyle(fontSize: 12)),
      ),
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

  void _downloadXml(BuildContext context) {
    // XML endpoint: GET /invoices/:id/xml — returns application/xml file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Endpoint XML: GET /invoices/${invoice.id}/xml'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

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
                IconButton(
                  icon: const Icon(Icons.code_outlined),
                  tooltip: 'Xuất XML',
                  onPressed: () => _downloadXml(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _dateFmt.format(invoice.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
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
