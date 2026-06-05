import 'package:uuid/uuid.dart';
import 'api_service.dart';
import '../models/user.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/invoice.dart';

// Mock trả dữ liệu giả — dùng để app chạy độc lập khi chưa có backend
class MockApiService implements ApiService {
  static const _uuid = Uuid();

  final _store = const StoreDto(
    id: 'store-demo-001',
    name: 'Quán Ăn Demo',
    taxId: '0123456789',
    address: '123 Đường Láng, Hà Nội',
    phone: '0901234567',
  );

  final _products = <ProductDto>[
    ProductDto(id: 'p1', name: 'Phở bò tái', price: 50000, unit: 'bát', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p2', name: 'Phở bò chín', price: 50000, unit: 'bát', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p3', name: 'Phở gà', price: 45000, unit: 'bát', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p4', name: 'Bún bò Huế', price: 55000, unit: 'bát', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p5', name: 'Bún riêu', price: 45000, unit: 'bát', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p6', name: 'Bánh mì thịt', price: 25000, unit: 'cái', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p7', name: 'Bánh mì trứng', price: 20000, unit: 'cái', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p8', name: 'Cơm sườn', price: 55000, unit: 'đĩa', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p9', name: 'Cơm tấm bì chả', price: 50000, unit: 'đĩa', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p10', name: 'Trà đá', price: 5000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p11', name: 'Trà chanh', price: 15000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p12', name: 'Cà phê đen', price: 20000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p13', name: 'Cà phê sữa', price: 25000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p14', name: 'Nước cam', price: 30000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
    ProductDto(id: 'p15', name: 'Sinh tố bơ', price: 35000, unit: 'ly', isActive: true, updatedAt: DateTime(2026, 6, 7)),
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
  Future<ProductDto> createProduct(String name, int price, String? unit) async {
    final p = ProductDto(
      id: _uuid.v4(),
      name: name,
      price: price,
      unit: unit,
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
      name: data['name'] as String? ?? old.name,
      price: data['price'] as int? ?? old.price,
      unit: data['unit'] as String? ?? old.unit,
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
      name: _products[idx].name,
      price: _products[idx].price,
      unit: _products[idx].unit,
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
}
