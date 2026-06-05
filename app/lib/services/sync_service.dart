import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import 'api_service.dart';
import 'local_db.dart';

class SyncService {
  final ApiService _api;
  bool _syncing = false;

  SyncService(this._api);

  Future<SyncResult> syncPending() async {
    if (_syncing) return const SyncResult(synced: 0, errors: 0);
    _syncing = true;
    int synced = 0;
    int errors = 0;
    try {
      final pending = await LocalDb.getPendingInvoices();
      if (pending.isEmpty) return const SyncResult(synced: 0, errors: 0);

      final batch = pending.map((inv) => CreateInvoiceDto(
        id: inv.id,
        createdAt: inv.createdAt,
        note: inv.note,
        items: inv.items,
      )).toList();

      final result = await _api.syncInvoices(batch);
      final results = result['results'] as List? ?? [];

      for (final r in results) {
        final map = r as Map<String, dynamic>;
        if (map['status'] == 'saved' || map['status'] == 'duplicate') {
          await LocalDb.markSynced(
            map['id'] as String,
            map['invoice_number'] as int,
          );
          synced++;
        } else {
          errors++;
        }
      }
    } catch (e) {
      debugPrint('Sync error: $e');
      errors++;
    } finally {
      _syncing = false;
    }
    return SyncResult(synced: synced, errors: errors);
  }
}

class SyncResult {
  final int synced;
  final int errors;
  const SyncResult({required this.synced, required this.errors});
}
