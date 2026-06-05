class ProductDto {
  final String id;
  final String name;
  final int price;
  final String? unit;
  final bool isActive;
  final DateTime updatedAt;

  const ProductDto({
    required this.id,
    required this.name,
    required this.price,
    this.unit,
    required this.isActive,
    required this.updatedAt,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) => ProductDto(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toInt(),
        unit: json['unit'] as String?,
        isActive: json['is_active'] as bool,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        if (unit != null) 'unit': unit,
        'is_active': isActive,
        'updated_at': updatedAt.toIso8601String(),
      };
}
