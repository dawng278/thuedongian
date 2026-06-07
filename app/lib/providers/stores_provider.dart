import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/store.dart';
import '../services/api_service.dart';

class StoresProvider extends ChangeNotifier {
  static const _keyCurrentStore = 'current_store_id';

  final ApiService _api;

  List<StoreDto> _stores = [];
  StoreDto? _currentStore;
  bool _loading = false;
  String? _error;

  StoresProvider(this._api);

  List<StoreDto> get stores => _stores;
  StoreDto? get currentStore => _currentStore;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadStores() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final stores = await _api.getStores();
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_keyCurrentStore);

      _stores = stores;
      if (stores.isEmpty) {
        _currentStore = null;
      } else {
        _currentStore = stores.firstWhere(
          (store) => store.id == savedId,
          orElse: () => stores.first,
        );
        await prefs.setString(_keyCurrentStore, _currentStore!.id);
      }
    } catch (e) {
      _error = 'Không tải được danh sách quán';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> switchStore(StoreDto store) async {
    _currentStore = store;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentStore, store.id);
    notifyListeners();
  }

  Future<StoreDto> createStore({
    required String name,
    required String businessType,
    String? taxId,
    String? address,
    String? phone,
  }) async {
    final store = await _api.updateStore({
      'name': name.trim(),
      'business_type': businessType,
      if (taxId != null && taxId.trim().isNotEmpty) 'tax_id': taxId.trim(),
      if (address != null && address.trim().isNotEmpty)
        'address': address.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
    });
    if (!_stores.any((s) => s.id == store.id)) {
      _stores = [..._stores, store];
    }
    await switchStore(store);
    return store;
  }

  /// Cập nhật thông tin quán hiện tại (tên, loại hình, MST, địa chỉ, SĐT).
  Future<StoreDto> updateCurrentStore({
    required String name,
    required String businessType,
    String? taxId,
    String? address,
    String? phone,
  }) async {
    final updated = await _api.updateStore({
      'name': name.trim(),
      'business_type': businessType,
      'tax_id': (taxId != null && taxId.trim().isNotEmpty) ? taxId.trim() : null,
      'address':
          (address != null && address.trim().isNotEmpty) ? address.trim() : null,
      'phone': (phone != null && phone.trim().isNotEmpty) ? phone.trim() : null,
    });
    _stores = _stores.map((s) => s.id == updated.id ? updated : s).toList();
    _currentStore = updated;
    notifyListeners();
    return updated;
  }
}
