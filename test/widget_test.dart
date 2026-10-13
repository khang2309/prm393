import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slot_02_daily_planner/screens/home_screen.dart';

void main() {
  testWidgets('planner adds, completes, and deletes tasks via input field', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Chưa có công việc nào!'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Học Flutter');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Học Flutter'), findsOneWidget);
    expect(find.text('Hoàn thành: 0 / 1'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(find.text('Hoàn thành: 1 / 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(find.text('Chưa có công việc nào!'), findsOneWidget);
  });
}
