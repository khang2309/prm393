class ProductCategory {
  const ProductCategory({
    this.id,
    required this.categoryName,
    this.totalProducts = 0,
  });

  final int? id;
  final String categoryName;
  final int totalProducts;

  ProductCategory copyWith({
    int? id,
    String? categoryName,
    int? totalProducts,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      totalProducts: totalProducts ?? this.totalProducts,
    );
  }

  Map<String, Object?> toMap() {
    final map = <String, Object?>{'category_name': categoryName};
    final value = id;
    if (value != null) map['id'] = value;
    return map;
  }

  factory ProductCategory.fromMap(Map<String, Object?> map) {
    return ProductCategory(
      id: _asInt(map['id']),
      categoryName: map['category_name']?.toString() ?? '',
      totalProducts: _asInt(map['total_products'] ?? map['totalProducts']) ?? 0,
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
