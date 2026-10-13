import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slot_06_student_list/screens/home_screen.dart';

void main() {
  testWidgets('selection and detail navigation are independent', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.byKey(const Key('select-SV01')));
    await tester.pump();
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    await tester.tap(find.text('Nguyễn Văn A'));
    await tester.pumpAndSettle();
    expect(find.text('Student Detail'), findsOneWidget);
    expect(find.text('Email: a@student.edu'), findsOneWidget);
  });
}
