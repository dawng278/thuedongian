import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import 'api_service.dart';
import 'local_db.dart';

class SyncService {
  final ApiService _api;
  bool _syncing = false;

  SyncService(this._api);

  Future<SyncResult> syncPending(String storeId) async {
    if (_syncing) return const SyncResult(saved: 0, duplicates: 0, errors: 0);
    _syncing = true;
    int saved = 0;
    int duplicates = 0;
    int errors = 0;
    try {
      final pending = await LocalDb.getPendingInvoices(storeId: storeId);
      if (pending.isEmpty) {
        return const SyncResult(saved: 0, duplicates: 0, errors: 0);
      }

      final batch = pending
          .map((inv) => CreateInvoiceDto(
                id: inv.id,
                storeId: inv.storeId,
                createdAt: inv.createdAt,
                note: inv.note,
                items: inv.items,
              ))
          .toList();

      final result = await _api.syncInvoices(batch);
      final results = result['results'] as List? ?? [];

      for (final r in results) {
        final map = r as Map<String, dynamic>;
        if (map['status'] == 'saved') {
          saved++;
          await LocalDb.markSynced(
            map['id'] as String,
            map['invoice_number'] as int,
          );
        } else if (map['status'] == 'duplicate') {
          duplicates++;
          await LocalDb.markSynced(
            map['id'] as String,
            map['invoice_number'] as int,
          );
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
    return SyncResult(saved: saved, duplicates: duplicates, errors: errors);
  }
}

class SyncResult {
  final int saved;
  final int duplicates;
  final int errors;
  const SyncResult({
    required this.saved,
    required this.duplicates,
    required this.errors,
  });
}
