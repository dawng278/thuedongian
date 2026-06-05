import '../models/user.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/invoice.dart';

abstract class ApiService {
  Future<AuthResponseDto> login(String email, String password);
  Future<AuthResponseDto> register(String email, String password, String name);

  Future<StoreDto> getMyStore();
  Future<StoreDto> updateStore(Map<String, dynamic> data);

  Future<List<ProductDto>> getProducts({bool includeInactive = false});
  Future<ProductDto> createProduct(String name, int price, {String? unit, String? category});
  Future<ProductDto> updateProduct(String id, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);

  Future<InvoiceDto> createInvoice(CreateInvoiceDto dto);
  Future<List<InvoiceDto>> getInvoices({DateTime? from, DateTime? to, int page = 1, int limit = 20});
  Future<InvoiceDto> getInvoice(String id);

  Future<Map<String, dynamic>> syncInvoices(List<CreateInvoiceDto> invoices);

  Future<Map<String, dynamic>> getRevenue({DateTime? from, DateTime? to});

  Future<Map<String, dynamic>> getTaxEstimate({String period = 'month'});
  Future<Map<String, dynamic>> getTaxDeadlines();
}
