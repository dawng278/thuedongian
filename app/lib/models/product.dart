class ProductDto {
  final String id;
  final String storeId;
  final String name;
  final int price;
  final String? unit;
  final String? category;
  final String? imageUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime updatedAt;

  const ProductDto({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
    this.unit,
    this.category,
    this.imageUrl,
    required this.isActive,
    this.createdAt,
    required this.updatedAt,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) => ProductDto(
        id: json['id'] as String,
        storeId: json['store_id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toInt(),
        unit: json['unit'] as String?,
        category: json['category'] as String?,
        imageUrl: json['image_url'] as String?,
        isActive: json['is_active'] as bool,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'store_id': storeId,
        'name': name,
        'price': price,
        if (unit != null) 'unit': unit,
        if (category != null) 'category': category,
        if (imageUrl != null) 'image_url': imageUrl,
        'is_active': isActive,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
