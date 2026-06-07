import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DailyRevenue {
  final String date;
  final int revenue;
  const DailyRevenue({required this.date, required this.revenue});
}

class TopProduct {
  final String productName;
  final int totalRevenue;
  final int totalQuantity;
  const TopProduct({
    required this.productName,
    required this.totalRevenue,
    required this.totalQuantity,
  });
}

class RevenueData {
  final int todayRevenue;
  final int todayCash;
  final int todayTransfer;
  final int todayInvoiceCount;
  final int monthRevenue;
  final int monthInvoiceCount;
  final int? monthProfit; // null = chưa khai báo giá vốn món nào
  final List<DailyRevenue> daily;
  final List<TopProduct> topProducts;

  const RevenueData({
    required this.todayRevenue,
    required this.todayCash,
    required this.todayTransfer,
    required this.todayInvoiceCount,
    required this.monthRevenue,
    required this.monthInvoiceCount,
    this.monthProfit,
    required this.daily,
    required this.topProducts,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) => RevenueData(
        todayRevenue: num.tryParse(json['today_revenue']?.toString() ?? '0')?.toInt() ?? 0,
        todayCash: num.tryParse(json['today_cash']?.toString() ?? '0')?.toInt() ?? 0,
        todayTransfer: num.tryParse(json['today_transfer']?.toString() ?? '0')?.toInt() ?? 0,
        todayInvoiceCount: num.tryParse(json['today_invoice_count']?.toString() ?? '0')?.toInt() ?? 0,
        monthRevenue: num.tryParse(json['month_revenue']?.toString() ?? '0')?.toInt() ?? 0,
        monthInvoiceCount: num.tryParse(json['month_invoice_count']?.toString() ?? '0')?.toInt() ?? 0,
        monthProfit: json['month_profit'] != null
            ? num.tryParse(json['month_profit'].toString())?.toInt()
            : null,
        daily: ((json['daily'] as List?) ?? [])
            .map((e) => DailyRevenue(
                  date: e['date'] as String? ?? '',
                  revenue: num.tryParse(e['revenue']?.toString() ?? '0')?.toInt() ?? 0,
                ))
            .toList(),
        topProducts: ((json['top_products'] as List?) ?? [])
            .map((e) => TopProduct(
                  productName: e['product_name'] as String? ?? '',
                  totalRevenue: num.tryParse(e['total_revenue']?.toString() ?? '0')?.toInt() ?? 0,
                  totalQuantity: num.tryParse(e['total_quantity']?.toString() ?? '0')?.toInt() ?? 0,
                ))
            .toList(),
      );
}

class RevenueProvider extends ChangeNotifier {
  final ApiService _api;

  RevenueData? _data;
  bool _loading = false;
  String? _error;
  String? _storeId;

  RevenueData? get data => _data;
  bool get loading => _loading;
  String? get error => _error;

  RevenueProvider(this._api);

  Future<void> setStore(String storeId) async {
    if (_storeId == storeId && _data != null) return;
    _storeId = storeId;
    await load();
  }

  Future<void> load({DateTime? from, DateTime? to}) async {
    final storeId = _storeId;
    if (storeId == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final json = await _api.getRevenue(from: from, to: to, storeId: storeId);
      _data = RevenueData.fromJson(json);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
