import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slot_04_async_product_loader/models/item.dart';
import 'package:slot_04_async_product_loader/screens/home_screen.dart';

void main() {
  testWidgets(
    'loader transitions from loading to item list and supports reload',
    (tester) async {
      final pending = Completer<List<Item>>();
      int calls = 0;
      final results = <Future<List<Item>> Function()>[
        () => pending.future,
        () => Future.value(const [Item(name: 'Xoài', price: 20000)]),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(fetcher: () => results[calls++]()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      pending.complete(const [
        Item(name: 'Táo', price: 10000),
        Item(name: 'Cam', price: 15000),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Táo'), findsOneWidget);
      expect(find.text('10000.0 VND'), findsOneWidget);

      await tester.tap(find.byKey(const Key('reload-products')));
      await tester.pumpAndSettle();

      expect(find.text('Xoài'), findsOneWidget);
      expect(calls, 2);
    },
  );

  testWidgets('error state renders error message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          fetcher: () => Future<List<Item>>.error('Network error'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Có lỗi xảy ra'), findsOneWidget);
  });
}
