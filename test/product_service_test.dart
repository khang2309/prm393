import 'package:flutter_test/flutter_test.dart';
import 'package:slot_03_quick_shop/services/product_service.dart';

void main() {
  test('filters products strictly below maximum price', () {
    final service = ProductService();
    final filtered = service.filterByMaxPrice(100);
    expect(filtered.map((p) => p.id).toList(), ['p2', 'p3', 'p4']);
  });
}
