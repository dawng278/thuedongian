import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class InvoicesProvider extends ChangeNotifier {
  static const _uuid = Uuid();
  final ApiService _api;

  List<InvoiceDto> _invoices = [];
  bool _creating = false;

  List<InvoiceDto> get invoices => _invoices;
  bool get creating => _creating;

  InvoicesProvider(this._api);

  Future<InvoiceDto> createInvoice(Map<String, int> cart, List<ProductDto> products, {String? note}) async {
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

      final invoice = await _api.createInvoice(dto);
      _invoices = [invoice, ..._invoices];
      notifyListeners();
      return invoice;
    } finally {
      _creating = false;
      notifyListeners();
    }
  }
}
