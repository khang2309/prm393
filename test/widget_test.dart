import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slot_09_product_dashboard/main.dart';

void main() {
  Future<void> verifyDashboard(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MyApp());
    expect(find.text('Hello, User 👋'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }

  testWidgets('dashboard supports portrait navigation to products', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    await verifyDashboard(tester, const Size(320, 640));
    await tester.tap(find.text('Xem danh sách sản phẩm'));
    await tester.pumpAndSettle();
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Product #0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard does not overflow in phone landscape', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    await verifyDashboard(tester, const Size(640, 320));
  });
}
