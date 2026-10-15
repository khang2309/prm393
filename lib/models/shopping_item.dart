class ShoppingItem {
  const ShoppingItem({
    this.id,
    required this.itemName,
    required this.category,
    required this.price,
    this.status = wishlistStatus,
  });

  static const String wishlistStatus = 'Wishlist';
  static const String purchasedStatus = 'Purchased';

  final int? id;
  final String itemName;
  final String category;
  final double price;
  final String status;

  bool get isWishlist => status == wishlistStatus;

  ShoppingItem copyWith({
    int? id,
    String? itemName,
    String? category,
    double? price,
    String? status,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'itemName': itemName,
    'category': category,
    'price': price,
    'status': status,
  };

  factory ShoppingItem.fromMap(Map<String, Object?> map) {
    return ShoppingItem(
      id: map['id'] as int?,
      itemName: map['itemName'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      status: map['status'] as String,
    );
  }
}
