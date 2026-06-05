import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/user.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/invoice.dart';

class HttpApiService implements ApiService {
  final Dio _dio;

  HttpApiService({String baseUrl = 'http://localhost:3000'})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  @override
  Future<AuthResponseDto> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseDto> register(String email, String password, String name) async {
    final res = await _dio.post('/auth/register', data: {'email': email, 'password': password, 'name': name});
    return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<StoreDto> getMyStore() async {
    final res = await _dio.get('/stores/me');
    return StoreDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<StoreDto> updateStore(Map<String, dynamic> data) async {
    final res = await _dio.patch('/stores/me', data: data);
    return StoreDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<ProductDto>> getProducts({bool includeInactive = false}) async {
    final res = await _dio.get('/products', queryParameters: {
      if (includeInactive) 'include_inactive': 'true',
    });
    return (res.data as List).map((e) => ProductDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ProductDto> createProduct(String name, int price, {String? unit, String? category}) async {
    final res = await _dio.post('/products', data: {
      'name': name,
      'price': price,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
    });
    return ProductDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<ProductDto> updateProduct(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/products/$id', data: data);
    return ProductDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _dio.delete('/products/$id');
  }

  @override
  Future<InvoiceDto> createInvoice(CreateInvoiceDto dto) async {
    final res = await _dio.post('/invoices', data: dto.toJson());
    return InvoiceDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<InvoiceDto>> getInvoices({DateTime? from, DateTime? to, int page = 1, int limit = 20}) async {
    final res = await _dio.get('/invoices', queryParameters: {
      if (from != null) 'from': from.toIso8601String().substring(0, 10),
      if (to != null) 'to': to.toIso8601String().substring(0, 10),
      'page': page,
      'limit': limit,
    });
    final data = res.data as Map<String, dynamic>;
    return (data['data'] as List).map((e) => InvoiceDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<InvoiceDto> getInvoice(String id) async {
    final res = await _dio.get('/invoices/$id');
    return InvoiceDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> syncInvoices(List<CreateInvoiceDto> invoices) async {
    final res = await _dio.post('/sync/invoices', data: {
      'invoices': invoices.map((i) => i.toJson()).toList(),
    });
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getRevenue({DateTime? from, DateTime? to}) async {
    final res = await _dio.get('/reports/revenue', queryParameters: {
      if (from != null) 'from': from.toIso8601String().substring(0, 10),
      if (to != null) 'to': to.toIso8601String().substring(0, 10),
    });
    return res.data as Map<String, dynamic>;
  }
}
