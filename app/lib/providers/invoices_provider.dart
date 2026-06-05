import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/local_db.dart';
import '../services/sync_service.dart';

class InvoicesProvider extends ChangeNotifier {
  static const _uuid = Uuid();
  final ApiService _api;
  late final SyncService _sync;

  final List<InvoiceDto> _invoices = [];
  bool _creating = false;
  int _pendingCount = 0;

  List<InvoiceDto> get invoices => _invoices;
  bool get creating => _creating;
  int get pendingCount => _pendingCount;

  InvoicesProvider(this._api) {
    _sync = SyncService(_api);
    _refreshPendingCount();
  }

  Future<void> _refreshPendingCount() async {
    final pending = await LocalDb.getPendingInvoices();
    _pendingCount = pending.length;
    notifyListeners();
  }

  /// Create invoice: always save to SQLite first, then try to sync
  Future<({int localNumber, int? serverNumber})> createInvoice(
    Map<String, int> cart,
    List<ProductDto> products, {
    String? note,
  }) async {
    _creating = true;
    notifyListeners();

    try {
      final items = cart.entries.map((e) {
        final product = products.firstWhere((p) => p.id == e.key);
        return CreateInvoiceItemInput(
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: e.value,
        );
      }).toList();

      final dto = CreateInvoiceDto(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        note: note,
        items: items,
      );

      // Step 1: Always persist locally first (works offline)
      final local = await LocalDb.insertPendingInvoice(dto);

      // Step 2: Try immediate sync
      int? serverNumber;
      try {
        final result = await _api.syncInvoices([dto]);
        final results = result['results'] as List? ?? [];
        if (results.isNotEmpty) {
          final r = results.first as Map<String, dynamic>;
          serverNumber = r['invoice_number'] as int?;
          if (serverNumber != null) {
            await LocalDb.markSynced(dto.id, serverNumber);
          }
        }
      } catch (_) {
        // Offline — will sync later
      }

      await _refreshPendingCount();
      return (localNumber: local.localNumber, serverNumber: serverNumber);
    } finally {
      _creating = false;
      notifyListeners();
    }
  }

  /// Sync all pending invoices (call when network comes back)
  Future<SyncResult> syncPending() async {
    final result = await _sync.syncPending();
    await _refreshPendingCount();
    return result;
  }
}
