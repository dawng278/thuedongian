import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../providers/stores_provider.dart';
import '../../services/share_helper.dart';
import '../../models/invoice.dart';
import '../../services/api_service.dart';
import '../../theme/taxeasy_design.dart';
import '../../widgets/skeleton.dart';

final _currencyFmt = NumberFormat('#,###', 'vi_VN');
final _dateFmt = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
final _dateFmtShort = DateFormat('dd/MM/yyyy', 'vi_VN');

// Cache theme PDF (font Unicode) — load font 1 lần, dùng lại cho mọi lần xuất.
pw.ThemeData? _cachedPdfTheme;

/// Tạo theme PDF dùng font DejaVu Sans (hỗ trợ đầy đủ tiếng Việt).
Future<pw.ThemeData> _pdfTheme() async {
  if (_cachedPdfTheme != null) return _cachedPdfTheme!;
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/DejaVuSans.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/DejaVuSans-Bold.ttf'),
  );
  _cachedPdfTheme = pw.ThemeData.withFont(
    base: regular,
    bold: bold,
    italic: regular,
    boldItalic: bold,
  );
  return _cachedPdfTheme!;
}

/// Rút gọn đường dẫn để hiển thị (chỉ giữ phần thân thiện với người dùng).
String _displayPath(String fullPath) {
  if (fullPath.contains('/Download')) return 'Thư mục Download';
  final parts = fullPath.split('/');
  return parts.length > 2
      ? '.../${parts[parts.length - 2]}/${parts.last}'
      : fullPath;
}

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
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Lọc client-side trên các hóa đơn đã tải: theo số HĐ, tên sản phẩm,
  /// hoặc số tiền. (Bộ lọc ngày vẫn ở server-side.)
  List<InvoiceDto> get _filteredInvoices {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _invoices;
    return _invoices.where((inv) {
      final num = (inv.invoiceNumber?.toString() ?? '');
      if (num.contains(q)) return true;
      if (inv.totalAmount.toString().contains(q)) return true;
      final items = inv.items ?? [];
      return items.any(
        (it) => it.productName.toLowerCase().contains(q),
      );
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final storeId = context.read<StoresProvider>().currentStore?.id;
    if (storeId != null && storeId != _storeId) {
      _storeId = storeId;
      _refresh();
    }
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
                      ButtonSegment(value: 'xml', label: Text('XML')),
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
                    label: Text(format == 'pdf'
                        ? 'Tạo PDF'
                        : format == 'csv'
                            ? 'Tạo CSV'
                            : 'Tạo XML'),
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
          : format == 'csv'
              ? await _writeCsvReport(report, range)
              : await _writeXmlReport(report, range);
      await shareOrOpenFile(
        file.path,
        mimeType: format == 'pdf' ? 'application/pdf' : 'text/csv',
        subject: format == 'pdf'
            ? 'Báo cáo PDF ThueDonGian'
            : format == 'csv'
                ? 'Báo cáo CSV ThueDonGian'
                : 'Báo cáo XML ThueDonGian',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu báo cáo vào: ${_displayPath(file.path)}'),
            backgroundColor: TaxEasyColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
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

  Future<File> _writeXmlReport(
    Map<String, dynamic> report,
    DateTimeRange range,
  ) async {
    final xml = await context.read<ApiService>().getPeriodReportXml(
          from: range.start,
          to: range.end,
          storeId: _storeId,
        );
    final dir = await resolveSaveDirectory();
    final store = (report['store'] as Map?)?.cast<String, dynamic>() ?? {};
    final file = File(
      '${dir.path}/thuedongian-report_${_slug(store['name'] as String? ?? 'store')}_${DateFormat('yyyyMMdd').format(range.start)}-${DateFormat('yyyyMMdd').format(range.end)}.xml',
    );
    await file.writeAsString(xml, flush: true);
    return file;
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
    final dir = await resolveSaveDirectory();
    final file = File(
      '${dir.path}/thuedongian-report_${_slug(store['name'] as String? ?? 'store')}_${DateFormat('yyyyMMdd').format(range.start)}-${DateFormat('yyyyMMdd').format(range.end)}.csv',
    );
    // Thêm BOM UTF-8 (﻿) để Excel mở CSV hiển thị đúng tiếng Việt.
    await file.writeAsString('﻿${sb.toString()}', flush: true);
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

    // Font Unicode (DejaVu Sans) để hiển thị tiếng Việt đúng dấu trong PDF —
    // font mặc định của package pdf (Helvetica) không có glyph tiếng Việt.
    final theme = await _pdfTheme();
    final doc = pw.Document(theme: theme);

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
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

    final dir = await resolveSaveDirectory();
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
    return Column(
      children: [
        // Ô tìm kiếm
        Container(
          color: const Color(0xFFF8F9FF),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Tìm số HĐ, sản phẩm, số tiền...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Color(0xFFC3C6D7)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: Color(0xFFC3C6D7)),
              ),
            ),
          ),
        ),
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                  8, (_) => const InvoiceRowSkeleton()),
            ),
          )
        else if (_filteredInvoices.isEmpty)
          Expanded(
            child: _InvoiceEmptyState(
              hasFilter: hasFilter || _searchQuery.isNotEmpty,
              cs: cs,
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              color: cs.primary,
              onRefresh: _refresh,
              child: Builder(
                builder: (context) {
                  final searching = _searchQuery.trim().isNotEmpty;
                  final list = _filteredInvoices;
                  // Khi đang tìm kiếm: không phân trang thêm (lọc client trên
                  // dữ liệu đã tải). Khi không tìm: giữ infinite scroll.
                  final showLoadMore = !searching && _hasMore;
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: list.length + (showLoadMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == list.length) {
                        // Defer load: KHÔNG gọi setState trong lúc build —
                        // gây "setState during build" và rebuild lặp (treo).
                        if (!_loading) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) _loadMore();
                          });
                        }
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _InvoiceRow(
                          invoice: list[i],
                          onTap: () => _showDetail(context, list[i]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  void _showDetail(BuildContext context, InvoiceDto invoice) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InvoiceDetailScreen(invoice: invoice),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _InvoiceEmptyState extends StatelessWidget {
  final bool hasFilter;
  final ColorScheme cs;
  const _InvoiceEmptyState({required this.hasFilter, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: TaxEasyColors.surfaceLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilter ? Icons.search_off_rounded : Icons.receipt_long_outlined,
                size: 48,
                color: TaxEasyColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilter
                  ? 'Không có hóa đơn trong khoảng này'
                  : 'Chưa có hóa đơn nào',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: TaxEasyColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Thử chọn khoảng thời gian khác hoặc xóa bộ lọc.'
                  : 'Chuyển sang chế độ Bán hàng và bán món đầu tiên — hóa đơn sẽ hiện ở đây.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

/// Trang chi tiết hóa đơn đầy đủ: QR hiển thị sẵn, danh sách món, tổng tiền,
/// phương thức thanh toán, trạng thái đồng bộ, và nút xuất XML / xem QR lớn.
class InvoiceDetailScreen extends StatelessWidget {
  final InvoiceDto invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  String _qrPayload() => jsonEncode({
        'id': invoice.id,
        'so': invoice.invoiceNumber,
        'ngay': invoice.createdAt.toIso8601String(),
        'tong': invoice.totalAmount,
        'so_mon': invoice.items?.length ?? 0,
      });

  Future<void> _downloadXml(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final store = context.read<StoresProvider>().currentStore;

    // Hóa đơn điện tử bắt buộc có MST người bán — chặn sớm với hướng dẫn rõ ràng.
    if (store?.taxId == null || store!.taxId!.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Cần khai báo Mã số thuế của quán trước khi xuất hóa đơn điện tử. '
              'Vào "Cài đặt quán" để thêm.'),
          backgroundColor: Color(0xFFD97706),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('Đang tạo file XML...')),
    );
    try {
      final xml = await context.read<ApiService>().getInvoiceXml(invoice.id);
      final dir = await resolveSaveDirectory();
      final number = invoice.invoiceNumber ?? invoice.id.substring(0, 8);
      final file = File('${dir.path}/hoadon-$number.xml');
      await file.writeAsString(xml, flush: true);
      await shareOrOpenFile(
        file.path,
        mimeType: 'application/xml',
        subject: 'Hóa đơn điện tử #$number',
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã lưu XML vào: ${_displayPath(file.path)}'),
          backgroundColor: TaxEasyColors.success,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi xuất XML: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final number = invoice.invoiceNumber;
    final items = invoice.items ?? [];
    final isOnline = invoice.syncedAt != null;
    final isCash = invoice.paymentMethod == 'cash';

    return Scaffold(
      backgroundColor: TaxEasyColors.background,
      appBar: AppBar(
        title: Text('Hóa đơn #${number ?? '?'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.code_outlined),
            tooltip: 'Xuất XML',
            onPressed: () => _downloadXml(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // QR + thông tin tóm tắt
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TaxEasyColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: TaxEasyColors.outlineVariant),
            ),
            child: Column(
              children: [
                QrImageView(
                  data: _qrPayload(),
                  version: QrVersions.auto,
                  size: 180,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: cs.primary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Khách quét mã để xem thông tin hóa đơn',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Meta: ngày, thanh toán, trạng thái
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TaxEasyColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TaxEasyColors.outlineVariant),
            ),
            child: Column(
              children: [
                _metaRow(Icons.event_outlined, 'Thời gian',
                    _dateFmt.format(invoice.createdAt), cs),
                const SizedBox(height: 10),
                _metaRow(
                  isCash ? Icons.payments_outlined : Icons.account_balance_outlined,
                  'Thanh toán',
                  isCash ? 'Tiền mặt' : 'Chuyển khoản',
                  cs,
                ),
                const SizedBox(height: 10),
                _metaRow(
                  isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                  'Trạng thái',
                  isOnline ? 'Đã đồng bộ' : 'Chờ đồng bộ (offline)',
                  cs,
                  valueColor: isOnline
                      ? TaxEasyColors.success
                      : const Color(0xFFD97706),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Danh sách món
          Text('CHI TIẾT MÓN',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TaxEasyColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TaxEasyColors.outlineVariant),
            ),
            child: Column(
              children: [
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} ×${item.quantity}',
                            style: const TextStyle(
                                fontSize: 14, color: TaxEasyColors.textPrimary),
                          ),
                        ),
                        Text(
                          '${_currencyFmt.format(item.subtotal)}đ',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: TaxEasyColors.textPrimary),
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
                              color: TaxEasyColors.textPrimary)),
                    ),
                    Text(
                      '${_currencyFmt.format(invoice.totalAmount)}đ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: cs.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (invoice.note != null && invoice.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TaxEasyColors.surfaceLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2_outlined,
                      size: 18, color: TaxEasyColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(invoice.note!,
                        style: const TextStyle(
                            height: 1.4, color: TaxEasyColors.textPrimary)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _downloadXml(context),
            icon: const Icon(Icons.download),
            label: const Text('Xuất XML hóa đơn điện tử'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String label, String value, ColorScheme cs,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? TaxEasyColors.textPrimary)),
      ],
    );
  }
}
