import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slot_03_quick_shop/main.dart';

void main() {
  testWidgets('displays cheap products (< 100) and triggers add to cart', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: QuickShopPage()));
    expect(find.text('Chuột không dây'), findsOneWidget);
    expect(find.text('Bàn phím cơ'), findsOneWidget);
    expect(find.text('Lót chuột'), findsOneWidget);
    expect(find.text('Laptop Gaming'), findsNothing);
    expect(find.text('Màn hình 4K'), findsNothing);
    await tester.tap(find.text('Chuột không dây'));
    await tester.pump();
  });
}
