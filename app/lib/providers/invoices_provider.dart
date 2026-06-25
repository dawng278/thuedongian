import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';
import '../services/api_service.dart';
import '../services/local_db.dart';
import '../services/sync_service.dart';

class InvoicesProvider extends ChangeNotifier {
  static const _uuid = Uuid();
  final ApiService _api;
  late final SyncService _sync;

  final List<InvoiceDto> _invoices = [];
  bool _creating = false;
  bool _autoSyncing = false;
  int _pendingCount = 0;
  String? _storeId;

  Timer? _connTimer;
  bool _wasOnline = false;

  List<InvoiceDto> get invoices => _invoices;
  bool get creating => _creating;
  int get pendingCount => _pendingCount;

  ProductsProvider? _products;

  InvoicesProvider(this._api) {
    _sync = SyncService(_api);
    _startConnectivityPolling();
  }

  void bindProductsProvider(ProductsProvider p) => _products = p;

  /// Poll internet mỗi 10 giây thay vì dùng DBus (không khả dụng trên Linux desktop).
  void _startConnectivityPolling() {
    _connTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final online = await _hasInternet();
      if (online && !_wasOnline && _pendingCount > 0) {
        _autoSync();
      }
      _wasOnline = online;
    });
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _autoSync() async {
    if (_autoSyncing || _storeId == null) return;
    _autoSyncing = true;
    try {
      await syncPending();
    } catch (_) {
      // Mạng chập chờn — lần kết nối sau sẽ thử lại.
    } finally {
      _autoSyncing = false;
    }
  }

  @override
  void dispose() {
    _connTimer?.cancel();
    super.dispose();
  }

  Future<void> setStore(String storeId) async {
    if (_storeId == storeId) return;
    _storeId = storeId;
    await _refreshPendingCount();
  }

  Future<void> _refreshPendingCount() async {
    final storeId = _storeId;
    if (storeId == null) return;
    final pending = await LocalDb.getPendingInvoices(storeId: storeId);
    _pendingCount = pending.length;
    notifyListeners();
  }

  /// Create invoice: always save to SQLite first, then try to sync.
  /// Returns localNumber, optional serverNumber, and the full InvoiceDto for QR display.
  Future<({int localNumber, int? serverNumber, InvoiceDto invoice})>
      createInvoice(
    Map<String, int> cart,
    List<ProductDto> products, {
    String? note,
    String paymentMethod = 'cash',
  }) async {
    _creating = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final invoiceId = _uuid.v4();
      final storeId = _storeId;
      if (storeId == null) {
        throw StateError('Chưa chọn quán');
      }

      final items = cart.entries
          .map((e) {
            final idx = products.indexWhere((p) => p.id == e.key);
            if (idx == -1) return null; // món đã bị ẩn/xoá → bỏ qua
            final product = products[idx];
            return CreateInvoiceItemInput(
              productId: product.id,
              productName: product.name,
              price: product.price,
              quantity: e.value,
            );
          })
          .whereType<CreateInvoiceItemInput>()
          .toList();

      final dto = CreateInvoiceDto(
        id: invoiceId,
        storeId: storeId,
        createdAt: now,
        note: note,
        paymentMethod: paymentMethod,
        items: items,
      );

      // Step 1: Always persist locally first (works offline)
      final local = await LocalDb.insertPendingInvoice(dto);

      // Step 2: Giảm tồn kho local ngay lập tức
      await LocalDb.decreaseStock(cart);
      _products?.reloadFromLocal(storeId);

      // Step 3: Try immediate sync
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

      final invoiceDto = InvoiceDto(
        id: invoiceId,
        storeId: storeId,
        invoiceNumber: serverNumber ?? local.localNumber,
        totalAmount: items.fold(0, (s, i) => s + i.price * i.quantity),
        note: note,
        paymentMethod: paymentMethod,
        createdAt: now,
        items: items
            .map((i) => InvoiceItemDto(
                  id: '',
                  productId: i.productId,
                  productName: i.productName,
                  price: i.price,
                  quantity: i.quantity,
                  subtotal: i.price * i.quantity,
                ))
            .toList(),
      );

      return (
        localNumber: local.localNumber,
        serverNumber: serverNumber,
        invoice: invoiceDto
      );
    } finally {
      _creating = false;
      notifyListeners();
    }
  }

  /// Lấy danh sách hóa đơn chưa đồng bộ (để hiển thị cho người quản lý xem).
  Future<List<LocalInvoice>> pendingInvoices() async {
    final storeId = _storeId;
    if (storeId == null) return [];
    return LocalDb.getPendingInvoices(storeId: storeId);
  }

  /// Sync all pending invoices (call when network comes back)
  Future<SyncResult> syncPending() async {
    final storeId = _storeId;
    if (storeId == null) return const SyncResult(saved: 0, duplicates: 0, errors: 1);
    final result = await _sync.syncPending(storeId);
    await _refreshPendingCount();
    return result;
  }
}
