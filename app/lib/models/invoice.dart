class InvoiceItemDto {
  final String id;
  final String? productId;
  final String productName;
  final int price;
  final int quantity;
  final int subtotal;

  const InvoiceItemDto({
    required this.id,
    this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory InvoiceItemDto.fromJson(Map<String, dynamic> json) => InvoiceItemDto(
        id: json['id'] as String,
        productId: json['product_id'] as String?,
        productName: json['product_name'] as String,
        price: num.tryParse(json['price']?.toString() ?? '0')?.toInt() ?? 0,
        quantity: num.tryParse(json['quantity']?.toString() ?? '0')?.toInt() ?? 0,
        subtotal: num.tryParse(json['subtotal']?.toString() ?? '0')?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (productId != null) 'product_id': productId,
        'product_name': productName,
        'price': price,
        'quantity': quantity,
        'subtotal': subtotal,
      };
}

class InvoiceDto {
  final String id;
  final String? storeId;
  final int? invoiceNumber;
  final int totalAmount;
  final String? note;
  final String paymentMethod; // cash | transfer
  final DateTime createdAt;
  final DateTime? syncedAt;
  final List<InvoiceItemDto>? items;

  const InvoiceDto({
    required this.id,
    this.storeId,
    this.invoiceNumber,
    required this.totalAmount,
    this.note,
    this.paymentMethod = 'cash',
    required this.createdAt,
    this.syncedAt,
    this.items,
  });

  factory InvoiceDto.fromJson(Map<String, dynamic> json) => InvoiceDto(
        id: json['id'] as String,
        storeId: json['store_id'] as String?,
        invoiceNumber: json['invoice_number'] != null
            ? num.tryParse(json['invoice_number'].toString())?.toInt()
            : null,
        totalAmount: num.tryParse(json['total_amount']?.toString() ?? '0')?.toInt() ?? 0,
        note: json['note'] as String?,
        paymentMethod: json['payment_method'] as String? ?? 'cash',
        createdAt: DateTime.parse(json['created_at'] as String),
        syncedAt: json['synced_at'] != null
            ? DateTime.parse(json['synced_at'] as String)
            : null,
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => InvoiceItemDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (storeId != null) 'store_id': storeId,
        if (invoiceNumber != null) 'invoice_number': invoiceNumber,
        'total_amount': totalAmount,
        if (note != null) 'note': note,
        'payment_method': paymentMethod,
        'created_at': createdAt.toIso8601String(),
        if (syncedAt != null) 'synced_at': syncedAt!.toIso8601String(),
        if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      };
}

class CreateInvoiceItemInput {
  final String? productId;
  final String productName;
  final int price;
  final int quantity;

  const CreateInvoiceItemInput({
    this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        if (productId != null) 'product_id': productId,
        'product_name': productName,
        'price': price,
        'quantity': quantity,
      };
}

class CreateInvoiceDto {
  final String id;
  final String storeId;
  final DateTime createdAt;
  final String? note;
  final String paymentMethod; // cash | transfer
  final List<CreateInvoiceItemInput> items;

  const CreateInvoiceDto({
    required this.id,
    required this.storeId,
    required this.createdAt,
    this.note,
    this.paymentMethod = 'cash',
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'store_id': storeId,
        'created_at': createdAt.toIso8601String(),
        if (note != null) 'note': note,
        'payment_method': paymentMethod,
        'items': items.map((e) => e.toJson()).toList(),
      };
}
