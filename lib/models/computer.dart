class Computer {
  const Computer({
    this.id,
    required this.productName,
    required this.brandId,
    required this.categoryId,
    required this.cpu,
    required this.ram,
    required this.storage,
    required this.price,
    required this.stock,
    required this.soldQuantity,
    required this.isFeatured,
    this.brandName = '',
    this.categoryName = '',
  });

  final int? id;
  final String productName;
  final int brandId;
  final int categoryId;
  final String cpu;
  final int ram;
  final int storage;
  final double price;
  final int stock;
  final int soldQuantity;
  final bool isFeatured;
  final String brandName;
  final String categoryName;

  double get revenue => price * soldQuantity;
  double get inventoryValue => price * stock;
  int get totalUnits => stock + soldQuantity;

  Computer copyWith({
    int? id,
    String? productName,
    int? brandId,
    int? categoryId,
    String? cpu,
    int? ram,
    int? storage,
    double? price,
    int? stock,
    int? soldQuantity,
    bool? isFeatured,
    String? brandName,
    String? categoryName,
  }) {
    return Computer(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      cpu: cpu ?? this.cpu,
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      soldQuantity: soldQuantity ?? this.soldQuantity,
      isFeatured: isFeatured ?? this.isFeatured,
      brandName: brandName ?? this.brandName,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      'product_name': productName,
      'brand_id': brandId,
      'category_id': categoryId,
      'cpu': cpu,
      'ram': ram,
      'storage': storage,
      'price': price,
      'stock': stock,
      'sold_quantity': soldQuantity,
      'is_featured': isFeatured ? 1 : 0,
    };
    final value = id;
    if (value != null) map['id'] = value;
    return map;
  }

  factory Computer.fromMap(Map<String, Object?> map) {
    final featuredValue = map['is_featured'];
    return Computer(
      id: _asInt(map['id']),
      productName: map['product_name']?.toString() ?? '',
      brandId: _asInt(map['brand_id']) ?? 0,
      categoryId: _asInt(map['category_id']) ?? 0,
      cpu: map['cpu']?.toString() ?? '',
      ram: _asInt(map['ram']) ?? 0,
      storage: _asInt(map['storage']) ?? 0,
      price: _asDouble(map['price']),
      stock: _asInt(map['stock']) ?? 0,
      soldQuantity: _asInt(map['sold_quantity']) ?? 0,
      isFeatured: featuredValue == true || _asInt(featuredValue) == 1,
      brandName: (map['brand_name'] ?? map['brandName'])?.toString() ?? '',
      categoryName:
          (map['category_name'] ?? map['categoryName'])?.toString() ?? '',
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
