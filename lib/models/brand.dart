class Brand {
  const Brand({
    this.id,
    required this.brandName,
    required this.country,
    required this.foundedYear,
    this.totalProducts = 0,
  });

  final int? id;
  final String brandName;
  final String country;
  final int foundedYear;
  final int totalProducts;

  Brand copyWith({
    int? id,
    String? brandName,
    String? country,
    int? foundedYear,
    int? totalProducts,
  }) {
    return Brand(
      id: id ?? this.id,
      brandName: brandName ?? this.brandName,
      country: country ?? this.country,
      foundedYear: foundedYear ?? this.foundedYear,
      totalProducts: totalProducts ?? this.totalProducts,
    );
  }

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      'brand_name': brandName,
      'country': country,
      'founded_year': foundedYear,
    };
    final value = id;
    if (value != null) map['id'] = value;
    return map;
  }

  factory Brand.fromMap(Map<String, Object?> map) {
    return Brand(
      id: _asInt(map['id']),
      brandName: map['brand_name']?.toString() ?? '',
      country: map['country']?.toString() ?? '',
      foundedYear: _asInt(map['founded_year']) ?? 0,
      totalProducts: _asInt(map['total_products'] ?? map['totalProducts']) ?? 0,
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
