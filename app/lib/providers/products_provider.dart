import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/local_db.dart';

class ProductsProvider extends ChangeNotifier {
  final ApiService _api;

  List<ProductDto> _products = [];
  bool _loading = false;
  String? _error;
  String? _storeId;

  List<ProductDto> get products => _products;
  bool get loading => _loading;
  String? get error => _error;

  ProductsProvider(this._api);

  Future<void> setStore(String storeId) async {
    if (_storeId == storeId && _products.isNotEmpty) return;
    _storeId = storeId;
    _products = [];
    await loadProducts();
  }

  Future<void> loadProducts() async {
    final storeId = _storeId;
    if (storeId == null) return;
    // Load from cache first for instant display
    try {
      final cached = await LocalDb.getActiveProducts(storeId: storeId);
      if (cached.isNotEmpty) {
        _products = cached;
        notifyListeners();
      }
    } catch (_) {}

    // Then fetch from API
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final fresh = await _api.getProducts(storeId: storeId);
      _products = fresh;
      await LocalDb.upsertProducts(fresh);
    } catch (e) {
      if (_products.isEmpty) {
        _error = 'Không tải được danh mục';
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct(String name, int price,
      {String? unit,
      String? category,
      int? stock,
      int? costPrice,
      String? imageUrl}) async {
    final storeId = _storeId;
    if (storeId == null) throw StateError('Chưa chọn quán');
    final p = await _api.createProduct(name, price,
        unit: unit,
        category: category,
        stock: stock,
        costPrice: costPrice,
        imageUrl: imageUrl,
        storeId: storeId);
    _products = [..._products, p];
    await LocalDb.upsertProducts([p]);
    notifyListeners();
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    final updated = await _api.updateProduct(id, data);
    _products = _products.map((p) => p.id == id ? updated : p).toList();
    await LocalDb.upsertProducts([updated]);
    notifyListeners();
  }

  /// Reload danh sách sản phẩm từ SQLite local (sau khi giảm tồn kho).
  Future<void> reloadFromLocal(String storeId) async {
    try {
      final cached = await LocalDb.getActiveProducts(storeId: storeId);
      if (cached.isNotEmpty) {
        _products = cached;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> deleteProduct(String id) async {
    await _api.deleteProduct(id);
    _products = _products.where((p) => p.id != id).toList();
    notifyListeners();
  }
}
