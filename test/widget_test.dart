import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slot_10_responsive_dashboard/main.dart';

void main() {
  for (final entry in {360.0: 2, 700.0: 3, 1000.0: 4}.entries) {
    testWidgets('full dashboard uses ${entry.value} columns at ${entry.key}', (
      tester,
    ) async {
      tester.view.physicalSize = Size(entry.key, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(const ResponsiveDashboardApp());
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, entry.value);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
