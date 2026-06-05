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
  final int monthRevenue;
  final int monthInvoiceCount;
  final List<DailyRevenue> daily;
  final List<TopProduct> topProducts;

  const RevenueData({
    required this.todayRevenue,
    required this.monthRevenue,
    required this.monthInvoiceCount,
    required this.daily,
    required this.topProducts,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) => RevenueData(
        todayRevenue: (json['today_revenue'] as num).toInt(),
        monthRevenue: (json['month_revenue'] as num).toInt(),
        monthInvoiceCount: (json['month_invoice_count'] as num).toInt(),
        daily: (json['daily'] as List)
            .map((e) => DailyRevenue(
                  date: e['date'] as String,
                  revenue: (e['revenue'] as num).toInt(),
                ))
            .toList(),
        topProducts: (json['top_products'] as List)
            .map((e) => TopProduct(
                  productName: e['product_name'] as String,
                  totalRevenue: (e['total_revenue'] as num).toInt(),
                  totalQuantity: (e['total_quantity'] as num).toInt(),
                ))
            .toList(),
      );
}

class RevenueProvider extends ChangeNotifier {
  final ApiService _api;

  RevenueData? _data;
  bool _loading = false;
  String? _error;

  RevenueData? get data => _data;
  bool get loading => _loading;
  String? get error => _error;

  RevenueProvider(this._api);

  Future<void> load({DateTime? from, DateTime? to}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final json = await _api.getRevenue(from: from, to: to);
      _data = RevenueData.fromJson(json);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
