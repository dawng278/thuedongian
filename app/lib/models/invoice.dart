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
        price: (json['price'] as num).toInt(),
        quantity: json['quantity'] as int,
        subtotal: (json['subtotal'] as num).toInt(),
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
  final int? invoiceNumber;
  final int totalAmount;
  final String? note;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final List<InvoiceItemDto>? items;

  const InvoiceDto({
    required this.id,
    this.invoiceNumber,
    required this.totalAmount,
    this.note,
    required this.createdAt,
    this.syncedAt,
    this.items,
  });

  factory InvoiceDto.fromJson(Map<String, dynamic> json) => InvoiceDto(
        id: json['id'] as String,
        invoiceNumber: json['invoice_number'] as int?,
        totalAmount: (json['total_amount'] as num).toInt(),
        note: json['note'] as String?,
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
        if (invoiceNumber != null) 'invoice_number': invoiceNumber,
        'total_amount': totalAmount,
        if (note != null) 'note': note,
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
  final DateTime createdAt;
  final String? note;
  final List<CreateInvoiceItemInput> items;

  const CreateInvoiceDto({
    required this.id,
    required this.createdAt,
    this.note,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        if (note != null) 'note': note,
        'items': items.map((e) => e.toJson()).toList(),
      };
}
