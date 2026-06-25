import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/user.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/invoice.dart';

class HttpApiService implements ApiService {
  late final Dio _dio;

  String? _refreshToken;
  // Gọi khi refresh thành công (để AuthProvider lưu token mới) / thất bại (để logout).
  void Function(String accessToken, String refreshToken)? onTokensRefreshed;
  void Function()? onAuthExpired;
  bool _isRefreshing = false;

  HttpApiService({String baseUrl = 'http://localhost:3000'}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 7),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ));
    _dio.interceptors.add(InterceptorsWrapper(onError: _onError));
  }

  /// Khi gặp 401 (token hết hạn): tự gọi /auth/refresh rồi retry request gốc.
  /// Không áp dụng cho chính các route /auth để tránh lặp vô hạn.
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    final isAuthRoute = path.contains('/auth/');
    final alreadyRetried = err.requestOptions.extra['__retried'] == true;

    if (status != 401 ||
        isAuthRoute ||
        alreadyRetried ||
        _refreshToken == null) {
      return handler.next(err);
    }

    try {
      if (!_isRefreshing) {
        _isRefreshing = true;
        final newAccess = await _doRefresh();
        _isRefreshing = false;
        if (newAccess == null) {
          onAuthExpired?.call();
          return handler.next(err);
        }
      }
      // Retry request gốc với token mới.
      final opts = err.requestOptions;
      opts.extra['__retried'] = true;
      opts.headers['Authorization'] = _dio.options.headers['Authorization'];
      final clone = await _dio.fetch(opts);
      return handler.resolve(clone);
    } catch (_) {
      _isRefreshing = false;
      onAuthExpired?.call();
      return handler.next(err);
    }
  }

  /// Gọi /auth/refresh bằng refresh token; trả access token mới hoặc null nếu thất bại.
  Future<String?> _doRefresh() async {
    try {
      final res = await _dio.post(
        '/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $_refreshToken'},
        ),
      );
      final data = res.data as Map<String, dynamic>;
      final access = data['access_token'] as String?;
      final refresh = data['refresh_token'] as String? ?? _refreshToken;
      if (access == null) return null;
      setToken(access);
      _refreshToken = refresh;
      onTokensRefreshed?.call(access, refresh!);
      return access;
    } catch (_) {
      return null;
    }
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void setRefreshToken(String? token) {
    _refreshToken = token;
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
    _refreshToken = null;
  }

  @override
  Future<AuthResponseDto> login(String email, String password) async {
    final res = await _dio
        .post('/auth/login', data: {'email': email, 'password': password});
    return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseDto> register(
      String email, String password, String name) async {
    final res = await _dio.post('/auth/register',
        data: {'email': email, 'password': password, 'name': name});
    return AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<UserDto> updateProfile({String? name, String? email}) async {
    final res = await _dio.patch('/auth/me', data: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    });
    return UserDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _dio.post('/auth/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  @override
  Future<List<StoreDto>> getStores() async {
    final res = await _dio.get('/stores');
    return (res.data as List)
        .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StoreDto> createStore(Map<String, dynamic> data) async {
    final res = await _dio.post('/stores', data: data);
    return StoreDto.fromJson(res.data as Map<String, dynamic>);
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
  Future<List<ProductDto>> getProducts(
      {bool includeInactive = false, String? storeId}) async {
    final res = await _dio.get('/products', queryParameters: {
      if (includeInactive) 'include_inactive': 'true',
      if (storeId != null) 'store_id': storeId,
    });
    return (res.data as List)
        .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductDto> createProduct(String name, int price,
      {String? unit,
      String? category,
      int? stock,
      int? costPrice,
      String? imageUrl,
      String? storeId}) async {
    final res = await _dio.post('/products', data: {
      'name': name,
      'price': price,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
      if (stock != null) 'stock': stock,
      if (costPrice != null) 'cost_price': costPrice,
      if (imageUrl != null) 'image_url': imageUrl,
      if (storeId != null) 'store_id': storeId,
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
  Future<List<InvoiceDto>> getInvoices(
      {DateTime? from,
      DateTime? to,
      int page = 1,
      int limit = 20,
      String? storeId}) async {
    final res = await _dio.get('/invoices', queryParameters: {
      if (from != null) 'from': from.toIso8601String().substring(0, 10),
      if (to != null) 'to': to.toIso8601String().substring(0, 10),
      if (storeId != null) 'store_id': storeId,
      'page': page,
      'limit': limit,
    });
    final data = res.data as Map<String, dynamic>;
    return (data['data'] as List)
        .map((e) => InvoiceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InvoiceDto> getInvoice(String id) async {
    final res = await _dio.get('/invoices/$id');
    return InvoiceDto.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<String> getInvoiceXml(String id) async {
    final res = await _dio.get<String>(
      '/invoices/$id/xml',
      options: Options(responseType: ResponseType.plain),
    );
    return res.data ?? '';
  }

  @override
  Future<Map<String, dynamic>> syncInvoices(
      List<CreateInvoiceDto> invoices) async {
    final res = await _dio.post('/sync/invoices', data: {
      'invoices': invoices.map((i) => i.toJson()).toList(),
    });
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getRevenue(
      {DateTime? from, DateTime? to, String? storeId}) async {
    final res = await _dio.get('/reports/revenue', queryParameters: {
      if (from != null) 'from': from.toIso8601String().substring(0, 10),
      if (to != null) 'to': to.toIso8601String().substring(0, 10),
      if (storeId != null) 'store_id': storeId,
    });
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getChart(
      {String granularity = 'week', String? storeId}) async {
    final res = await _dio.get('/reports/chart', queryParameters: {
      'granularity': granularity,
      if (storeId != null) 'store_id': storeId,
    });
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getPeriodReport(
      {required DateTime from, required DateTime to, String? storeId}) async {
    final res = await _dio.get('/reports/period', queryParameters: {
      'from': from.toIso8601String().substring(0, 10),
      'to': to.toIso8601String().substring(0, 10),
      if (storeId != null) 'store_id': storeId,
    });
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<String> getPeriodReportXml(
      {required DateTime from, required DateTime to, String? storeId}) async {
    final res = await _dio.get<String>('/reports/period/xml',
        queryParameters: {
          'from': from.toIso8601String().substring(0, 10),
          'to': to.toIso8601String().substring(0, 10),
          if (storeId != null) 'store_id': storeId,
        },
        options: Options(responseType: ResponseType.plain));
    return res.data ?? '';
  }

  @override
  Future<Map<String, dynamic>> getTaxEstimate(
      {String period = 'month', String? storeId}) async {
    final res = await _dio.get('/tax/estimate', queryParameters: {
      'period': period,
      if (storeId != null) 'store_id': storeId,
    });
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getTaxDeadlines() async {
    final res = await _dio.get('/tax/deadlines');
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getAiInsights({String? storeId}) async {
    final res = await _dio.get('/ai/insights', queryParameters: {
      if (storeId != null) 'store_id': storeId,
    });
    final data = res.data;
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }
}
