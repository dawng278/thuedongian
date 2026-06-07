import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/stores_provider.dart';
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
  String? _storeId;

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
      final storeId = _storeId;
      if (storeId == null) return;
      final result = await api.getInvoices(
        from: _fromDate,
        to: _toDate,
        page: _page,
        limit: _limit,
        storeId: storeId,
      );
      setState(() {
        _invoices.addAll(result);
        _page++;
        if (result.length < _limit) _hasMore = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi tải lịch sử: $e'),
              backgroundColor: Colors.red),
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

  DateTimeRange _reportRange() {
    final now = DateTime.now();
    return DateTimeRange(
      start: _fromDate ?? DateTime(now.year, now.month, 1),
      end: _toDate ?? now,
    );
  }

  String _slug(String input) {
    final cleaned = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'store' : cleaned;
  }

  String _businessTypeLabel(String? value) {
    return switch (value) {
      'goods' => 'Hang hoa',
      'services' => 'Dich vu',
      _ => 'An uong',
    };
  }

  Future<void> _showReportSheet() async {
    var format = 'pdf';
    var range = _reportRange();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC3C6D7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Xuất báo cáo kỳ',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2025),
                        lastDate: DateTime.now(),
                        initialDateRange: range,
                      );
                      if (picked != null) setSheetState(() => range = picked);
                    },
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      '${_dateFmtShort.format(range.start)} - ${_dateFmtShort.format(range.end)}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'pdf', label: Text('PDF')),
                      ButtonSegment(value: 'csv', label: Text('CSV')),
                    ],
                    selected: {format},
                    onSelectionChanged: (value) =>
                        setSheetState(() => format = value.first),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _exportPeriodReport(range, format);
                    },
                    icon: const Icon(Icons.ios_share_outlined),
                    label: Text(format == 'pdf' ? 'Tạo PDF' : 'Tạo CSV'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportPeriodReport(DateTimeRange range, String format) async {
    final storeId = _storeId;
    if (storeId == null) return;
    try {
      final report = await context.read<ApiService>().getPeriodReport(
            from: range.start,
            to: range.end,
            storeId: storeId,
          );
      final file = format == 'pdf'
          ? await _writePdfReport(report, range)
          : await _writeCsvReport(report, range);
      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: format == 'pdf' ? 'application/pdf' : 'text/csv',
          ),
        ],
        subject: format == 'pdf'
            ? 'Báo cáo PDF ThueDonGian'
            : 'Báo cáo CSV ThueDonGian',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi xuất báo cáo: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<File> _writeCsvReport(
    Map<String, dynamic> report,
    DateTimeRange range,
  ) async {
    final sb = StringBuffer();
    final store = (report['store'] as Map?)?.cast<String, dynamic>() ?? {};
    final invoices = (report['invoices'] as List? ?? []);
    sb.writeln('ThueDonGian Report');
    sb.writeln('Store,${store['name'] ?? ''}');
    sb.writeln('From,${_dateFmtShort.format(range.start)}');
    sb.writeln('To,${_dateFmtShort.format(range.end)}');
    sb.writeln('Total revenue,${report['total_revenue'] ?? 0}');
    sb.writeln('Invoice count,${report['invoice_count'] ?? 0}');
    sb.writeln('');
    sb.writeln('Invoice No,Date,Total,Items');
    for (final raw in invoices) {
      final inv = raw as Map<String, dynamic>;
      final items = (inv['items'] as List? ?? []).map((item) {
        final map = item as Map<String, dynamic>;
        return '${map['product_name']}x${map['quantity']}';
      }).join(';');
      sb.writeln(
        '${inv['invoice_number'] ?? '?'},${inv['created_at'] ?? ''},${inv['total_amount'] ?? 0},"$items"',
      );
    }
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/thuedongian-report_${_slug(store['name'] as String? ?? 'store')}_${DateFormat('yyyyMMdd').format(range.start)}-${DateFormat('yyyyMMdd').format(range.end)}.csv',
    );
    await file.writeAsString(sb.toString(), flush: true);
    return file;
  }

  Future<File> _writePdfReport(
    Map<String, dynamic> report,
    DateTimeRange range,
  ) async {
    final store = (report['store'] as Map?)?.cast<String, dynamic>() ?? {};
    final tax = (report['tax_estimate'] as Map?)?.cast<String, dynamic>() ?? {};
    final invoices = (report['invoices'] as List? ?? []);
    final topProducts = (report['top_products'] as List? ?? []);
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (_) => pw.Center(
            child: pw.Transform.rotate(
              angle: -0.52,
              child: pw.Opacity(
                opacity: 0.07,
                child: pw.Text(
                  'ThueDonGian',
                  style: pw.TextStyle(
                    fontSize: 64,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey,
                  ),
                ),
              ),
            ),
          ),
        ),
        build: (_) => [
          pw.Text(
            'ThueDonGian',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.Container(
              height: 2,
              color: PdfColors.blue600,
              margin: const pw.EdgeInsets.symmetric(vertical: 10)),
          pw.Text(
            'Bao cao doanh thu & thue uoc tinh',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Store: ${store['name'] ?? ''}'),
          pw.Text(
              'Business type: ${_businessTypeLabel(store['business_type'] as String?)}'),
          pw.Text('Tax ID: ${store['tax_id'] ?? '-'}'),
          pw.Text('Address: ${store['address'] ?? '-'}'),
          pw.Text('Phone: ${store['phone'] ?? '-'}'),
          pw.Text(
              'Period: ${_dateFmtShort.format(range.start)} - ${_dateFmtShort.format(range.end)}'),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _pdfRow('Total revenue',
                  '${_currencyFmt.format((report['total_revenue'] as num?)?.toInt() ?? 0)} VND'),
              _pdfRow('Invoice count', '${report['invoice_count'] ?? 0}'),
              _pdfRow('Estimated tax',
                  '${_currencyFmt.format((tax['total_tax'] as num?)?.toInt() ?? 0)} VND'),
            ],
          ),
          pw.SizedBox(height: 18),
          if (topProducts.isNotEmpty) ...[
            pw.Text('Top products',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: const {
                0: pw.FixedColumnWidth(36),
                1: pw.FlexColumnWidth(),
                2: pw.FixedColumnWidth(64),
                3: pw.FixedColumnWidth(92),
              },
              children: [
                _pdfHeaderRow(['#', 'Product', 'Qty', 'Revenue']),
                ...topProducts.take(10).toList().asMap().entries.map((entry) {
                  final item = entry.value as Map<String, dynamic>;
                  return _pdfCells([
                    '${entry.key + 1}',
                    '${item['product_name'] ?? ''}',
                    '${item['total_quantity'] ?? 0}',
                    _currencyFmt.format(
                      (item['total_revenue'] as num?)?.toInt() ?? 0,
                    ),
                  ]);
                }),
              ],
            ),
            pw.SizedBox(height: 18),
          ],
          pw.Text('Invoices',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: const {
              0: pw.FixedColumnWidth(52),
              1: pw.FlexColumnWidth(),
              2: pw.FixedColumnWidth(92),
            },
            children: [
              _pdfHeaderRow(['No', 'Date', 'Total']),
              ...invoices.take(80).map((raw) {
                final inv = raw as Map<String, dynamic>;
                return _pdfCells([
                  '#${inv['invoice_number'] ?? '?'}',
                  '${inv['created_at'] ?? ''}',
                  _currencyFmt.format(
                    (inv['total_amount'] as num?)?.toInt() ?? 0,
                  ),
                ]);
              }),
            ],
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/thuedongian-report_${_slug(store['name'] as String? ?? 'store')}_${DateFormat('yyyyMMdd').format(range.start)}-${DateFormat('yyyyMMdd').format(range.end)}.pdf',
    );
    await file.writeAsBytes(await doc.save(), flush: true);
    return file;
  }

  pw.TableRow _pdfRow(String label, String value) => _pdfCells([label, value]);

  pw.TableRow _pdfHeaderRow(List<String> values) => pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blue50),
        children: values
            .map(
              (value) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  value,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
            )
            .toList(),
      );

  pw.TableRow _pdfCells(List<String> values) => pw.TableRow(
        children: values
            .map(
              (value) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(value),
              ),
            )
            .toList(),
      );

  @override
  Widget build(BuildContext context) {
    final hasFilter = _fromDate != null || _toDate != null;
    final cs = Theme.of(context).colorScheme;
    final storeId = context.watch<StoresProvider>().currentStore?.id;
    if (storeId != null && storeId != _storeId) {
      _storeId = storeId;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }

    return Column(
      children: [
        // Filter bar
        Container(
          color: const Color(0xFFF8F9FF),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFC3C6D7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            hasFilter
                                ? '${_dateFmtShort.format(_fromDate!)} – ${_dateFmtShort.format(_toDate!)}'
                                : 'HÔM NAY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: hasFilter
                                  ? cs.onSurface
                                  : cs.onSurfaceVariant,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.expand_more,
                            size: 16, color: cs.onSurfaceVariant),
                        if (hasFilter) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _clearFilter,
                            child: Icon(Icons.close,
                                size: 14, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showReportSheet,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.download, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'XUẤT BC',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // List
        if (_loading && _invoices.isEmpty)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_invoices.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 56, color: cs.outline),
                  const SizedBox(height: 12),
                  Text('Chưa có hóa đơn nào',
                      style:
                          TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              color: cs.primary,
              onRefresh: _refresh,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: _invoices.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _invoices.length) {
                    if (!_loading) _loadMore();
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _InvoiceRow(
                      invoice: _invoices[i],
                      onTap: () => _showDetail(context, _invoices[i]),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  void _showDetail(BuildContext context, InvoiceDto invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InvoiceDetailSheet(invoice: invoice),
    );
  }
}

// ── Invoice row ────────────────────────────────────────────────────────────

class _InvoiceRow extends StatelessWidget {
  final InvoiceDto invoice;
  final VoidCallback onTap;
  const _InvoiceRow({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final num = invoice.invoiceNumber;
    final itemCount = invoice.items?.length ?? 0;
    final isOnline = invoice.syncedAt != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: const Color(0xFFC3C6D7).withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // Receipt icon circle
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFE5EEFF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_rounded, size: 22, color: cs.primary),
            ),
            const SizedBox(width: 14),
            // Invoice info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#INV-${num ?? '?'}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_dateFmt.format(invoice.createdAt)}${itemCount > 0 ? ' • $itemCount món' : ''}',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            // Status dot + amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnline
                            ? const Color(0xFF00668A)
                            : const Color(0xFF737686),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline
                            ? const Color(0xFF00668A)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currencyFmt.format(invoice.totalAmount)}đ',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B1C30)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail Sheet ───────────────────────────────────────────────────────────

class _InvoiceDetailSheet extends StatelessWidget {
  final InvoiceDto invoice;
  const _InvoiceDetailSheet({required this.invoice});

  void _downloadXml(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Endpoint XML: GET /invoices/${invoice.id}/xml'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final num = invoice.invoiceNumber;
    final items = invoice.items ?? [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scroll) => Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hóa đơn #${num ?? '?'}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B1C30)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.qr_code_2_outlined, color: cs.primary),
                    tooltip: 'Xem QR',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  InvoiceQrScreen(invoice: invoice)));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.code_outlined, color: cs.primary),
                    tooltip: 'Xuất XML',
                    onPressed: () => _downloadXml(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                _dateFmt.format(invoice.createdAt),
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 12),
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} ×${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF0B1C30)),
                            ),
                          ),
                          Text(
                            '${_currencyFmt.format(item.subtotal)}đ',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B1C30)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                      height: 24,
                      color: cs.outlineVariant.withValues(alpha: 0.5)),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Tổng cộng',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0B1C30))),
                      ),
                      Text(
                        '${_currencyFmt.format(invoice.totalAmount)}đ',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: cs.primary),
                      ),
                    ],
                  ),
                  if (invoice.note != null && invoice.note!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Ghi chú',
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(invoice.note!,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF0B1C30))),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Đóng',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
