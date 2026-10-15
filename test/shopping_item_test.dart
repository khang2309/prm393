import 'package:flutter_test/flutter_test.dart';
import 'package:lab5/models/shopping_item.dart';

void main() {
  group('ShoppingItem', () {
    test('maps all fields to and from SQLite values', () {
      const item = ShoppingItem(
        id: 7,
        itemName: 'Nike Air Force 1',
        category: 'Fashion',
        price: 2500000,
      );

      expect(ShoppingItem.fromMap(item.toMap()).toMap(), item.toMap());
    });

    test('defaults to Wishlist and can toggle through copyWith', () {
      const item = ShoppingItem(
        itemName: 'Desk',
        category: 'Home',
        price: 3000000,
      );
      expect(item.isWishlist, isTrue);
      expect(
        item.copyWith(status: ShoppingItem.purchasedStatus).isWishlist,
        isFalse,
      );
    });
  });
}
