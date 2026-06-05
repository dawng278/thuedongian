import 'package:uuid/uuid.dart';
import 'api_service.dart';
import '../models/user.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/invoice.dart';

// Mock trả dữ liệu giả — dùng để app chạy độc lập khi chưa có backend
class MockApiService implements ApiService {
  static const _uuid = Uuid();
  static const _storeId = 'store-demo-001';

  final _store = const StoreDto(
    id: _storeId,
    name: 'Quán Ăn Demo',
    taxId: '0123456789',
    address: '123 Đường Láng, Hà Nội',
    phone: '0901234567',
  );

  final _products = <ProductDto>[
    ProductDto(id: 'p1', storeId: _storeId, name: 'Phở bò tái', price: 50000, unit: 'bát', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p2', storeId: _storeId, name: 'Phở bò chín', price: 50000, unit: 'bát', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p3', storeId: _storeId, name: 'Phở gà', price: 45000, unit: 'bát', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p4', storeId: _storeId, name: 'Bún bò Huế', price: 55000, unit: 'bát', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p5', storeId: _storeId, name: 'Bún riêu', price: 45000, unit: 'bát', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p6', storeId: _storeId, name: 'Bánh mì thịt', price: 25000, unit: 'cái', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p7', storeId: _storeId, name: 'Bánh mì trứng', price: 20000, unit: 'cái', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p8', storeId: _storeId, name: 'Cơm sườn', price: 55000, unit: 'đĩa', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p9', storeId: _storeId, name: 'Cơm tấm bì chả', price: 50000, unit: 'đĩa', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p10', storeId: _storeId, name: 'Trà đá', price: 5000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p11', storeId: _storeId, name: 'Trà chanh', price: 15000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p12', storeId: _storeId, name: 'Cà phê đen', price: 20000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p13', storeId: _storeId, name: 'Cà phê sữa', price: 25000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p14', storeId: _storeId, name: 'Nước cam', price: 30000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p15', storeId: _storeId, name: 'Sinh tố bơ', price: 35000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
  ];

  final _invoices = <InvoiceDto>[];

  @override
  Future<AuthResponseDto> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AuthResponseDto(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      user: UserDto(id: 'user-001', email: email, name: 'Chủ quán Demo'),
    );
  }

  @override
  Future<AuthResponseDto> register(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AuthResponseDto(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      user: UserDto(id: _uuid.v4(), email: email, name: name),
    );
  }

  @override
  Future<StoreDto> getMyStore() async => _store;

  @override
  Future<StoreDto> updateStore(Map<String, dynamic> data) async => _store;

  @override
  Future<List<ProductDto>> getProducts({bool includeInactive = false}) async {
    if (includeInactive) return List.of(_products);
    return _products.where((p) => p.isActive).toList();
  }

  @override
  Future<ProductDto> createProduct(String name, int price, {String? unit, String? category}) async {
    final p = ProductDto(
      id: _uuid.v4(),
      storeId: _storeId,
      name: name,
      price: price,
      unit: unit,
      category: category,
      isActive: true,
      updatedAt: DateTime.now(),
    );
    _products.add(p);
    return p;
  }

  @override
  Future<ProductDto> updateProduct(String id, Map<String, dynamic> data) async {
    final idx = _products.indexWhere((p) => p.id == id);
    final old = _products[idx];
    final updated = ProductDto(
      id: old.id,
      storeId: old.storeId,
      name: data['name'] as String? ?? old.name,
      price: data['price'] as int? ?? old.price,
      unit: data['unit'] as String? ?? old.unit,
      category: data['category'] as String? ?? old.category,
      isActive: data['is_active'] as bool? ?? old.isActive,
      updatedAt: DateTime.now(),
    );
    _products[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteProduct(String id) async {
    final idx = _products.indexWhere((p) => p.id == id);
    _products[idx] = ProductDto(
      id: _products[idx].id,
      storeId: _products[idx].storeId,
      name: _products[idx].name,
      price: _products[idx].price,
      unit: _products[idx].unit,
      category: _products[idx].category,
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<InvoiceDto> createInvoice(CreateInvoiceDto dto) async {
    final items = dto.items.map((i) => InvoiceItemDto(
          id: _uuid.v4(),
          productId: i.productId,
          productName: i.productName,
          price: i.price,
          quantity: i.quantity,
          subtotal: i.price * i.quantity,
        )).toList();

    final invoice = InvoiceDto(
      id: dto.id,
      totalAmount: items.fold(0, (sum, i) => sum + i.subtotal),
      note: dto.note,
      createdAt: dto.createdAt,
      syncedAt: null,
      items: items,
    );
    _invoices.add(invoice);
    return invoice;
  }

  @override
  Future<List<InvoiceDto>> getInvoices({DateTime? from, DateTime? to, int page = 1, int limit = 20}) async {
    var result = List.of(_invoices);
    if (from != null) result = result.where((i) => !i.createdAt.isBefore(from)).toList();
    if (to != null) result = result.where((i) => !i.createdAt.isAfter(to)).toList();
    final start = (page - 1) * limit;
    return result.skip(start).take(limit).toList();
  }

  @override
  Future<InvoiceDto> getInvoice(String id) async =>
      _invoices.firstWhere((i) => i.id == id);

  @override
  Future<Map<String, dynamic>> syncInvoices(List<CreateInvoiceDto> invoices) async {
    final synced = <String>[];
    for (final inv in invoices) {
      await createInvoice(inv);
      synced.add(inv.id);
    }
    return {'synced': synced, 'skipped': [], 'errors': []};
  }

  @override
  Future<Map<String, dynamic>> getTaxEstimate({String period = 'month'}) async {
    final revenue = (await getRevenue())['month_revenue'] as int;
    const vatRate = 0.03;
    const pitRate = 0.015;
    return {
      'period_label': 'Tháng demo',
      'period_revenue': revenue,
      'annualised_revenue': revenue * 12,
      'below_threshold': revenue * 12 < 100000000,
      'exempt_threshold': 100000000,
      'business_type': 'food_beverage',
      'business_type_label': 'Ăn uống',
      'vat_rate': vatRate,
      'pit_rate': pitRate,
      'vat_amount': (revenue * vatRate).round(),
      'pit_amount': (revenue * pitRate).round(),
      'total_tax': (revenue * (vatRate + pitRate)).round(),
      'source': 'Thông tư 40/2021/TT-BTC',
      'disclaimer': 'Số liệu ước tính tham khảo — không thay thế tư vấn thuế chính thức.',
    };
  }

  @override
  Future<Map<String, dynamic>> getTaxDeadlines() async {
    return {
      'deadlines': [
        {'label': 'Kê khai thuế Q2 (2026)', 'deadline': '2026-07-30', 'daysLeft': 54, 'urgent': false},
        {'label': 'Kê khai thuế Q3 (2026)', 'deadline': '2026-10-30', 'daysLeft': 146, 'urgent': false},
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getRevenue({DateTime? from, DateTime? to}) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);

    final todayRevenue = _invoices
        .where((i) => !i.createdAt.isBefore(todayStart))
        .fold(0, (s, i) => s + i.totalAmount);
    final monthInvoices = _invoices.where((i) => !i.createdAt.isBefore(monthStart)).toList();
    final monthRevenue = monthInvoices.fold(0, (s, i) => s + i.totalAmount);

    final dailyMap = <String, int>{};
    for (final inv in monthInvoices) {
      final day = inv.createdAt.toIso8601String().substring(0, 10);
      dailyMap[day] = (dailyMap[day] ?? 0) + inv.totalAmount;
    }

    return {
      'today_revenue': todayRevenue,
      'month_revenue': monthRevenue,
      'month_invoice_count': monthInvoices.length,
      'daily': dailyMap.entries.map((e) => {'date': e.key, 'revenue': e.value}).toList(),
      'top_products': <Map<String, dynamic>>[],
    };
  }
}
