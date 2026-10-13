import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab4_recurring_bills/database/database_helper.dart';
import 'package:lab4_recurring_bills/main.dart';

void main() {
  setUpAll(() {
    DatabaseHelper.ensureInitialized();
  });

  testWidgets('Full LAB4 Recurring Bills workflow test', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final db = await DatabaseHelper.instance.database;
      await db.delete('bills');
    });

    await tester.pumpWidget(const RecurringBillsApp());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    // 1. Verify empty state on first launch
    expect(find.text('No bills yet'), findsOneWidget);
    expect(find.text("Press '+' button to add your recurring bills"), findsOneWidget);

    // 2. Navigate to Add Bill Screen
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Add New Bill'), findsOneWidget);

    // 3. Test validation dialog when Bill Name is empty
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Validation'), findsOneWidget);
    expect(find.text('Please enter bill name'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // 4. Fill in valid bill and Save
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Electricity - October');
    await tester.enterText(textFields.at(1), '850000');
    await tester.enterText(textFields.at(2), '2025-10-25');

    await tester.tap(find.text('Save'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Bill added successfully'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    // 5. Verify Home Screen shows the newly added bill
    expect(find.text('Electricity - October'), findsOneWidget);
    expect(find.text('Utilities'), findsOneWidget);
    expect(find.text('Due: 2025-10-25'), findsOneWidget);

    // 6. Switch to Unpaid Summary tab and verify summary
    await tester.tap(find.byIcon(Icons.error_outline));
    await tester.pumpAndSettle();
    expect(find.text('Unpaid Bills'), findsOneWidget);
    expect(find.text('1 bill unpaid'), findsOneWidget);
    expect(find.text('Outstanding Summary'), findsOneWidget);

    // 7. Switch back to Home tab, tap bill to open Update screen, then Delete
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Electricity - October'));
    await tester.pumpAndSettle();
    expect(find.text('Update Bill'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm Delete'), findsOneWidget);
    expect(find.text('Are you sure you want to delete this bill?'), findsOneWidget);
    await tester.tap(find.text('DELETE'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.text('Bill deleted'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.text('No bills yet'), findsOneWidget);
  });
}
