class StoreDto {
  final String id;
  final String name;
  final String? taxId;
  final String? address;
  final String? phone;

  const StoreDto({
    required this.id,
    required this.name,
    this.taxId,
    this.address,
    this.phone,
  });

  factory StoreDto.fromJson(Map<String, dynamic> json) => StoreDto(
        id: json['id'] as String,
        name: json['name'] as String,
        taxId: json['tax_id'] as String?,
        address: json['address'] as String?,
        phone: json['phone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (taxId != null) 'tax_id': taxId,
        if (address != null) 'address': address,
        if (phone != null) 'phone': phone,
      };
}
