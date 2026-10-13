import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slot_07_simple_planner/screens/create_plan_screen.dart';

void main() {
  testWidgets('incomplete plan cannot be saved', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreatePlanScreen()));
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Title is required'), findsOneWidget);
  });
}
