import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slot_01_personal_counter/widgets/counter_widget.dart';
import 'package:slot_01_personal_counter/widgets/hello_widget.dart';
import 'package:slot_01_personal_counter/widgets/profile_card.dart';

void main() {
  testWidgets('hello widget renders Hello Flutter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HelloWidget())),
    );
    expect(find.text('Hello Flutter'), findsOneWidget);
  });

  testWidgets('profile renders supplied personal information', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileCard(
          name: 'Nguyễn Văn A',
          role: 'Flutter Beginner',
          description: 'Why I learn Flutter',
        ),
      ),
    );
    expect(find.text('Nguyễn Văn A'), findsOneWidget);
    expect(find.text('Flutter Beginner'), findsOneWidget);
  });

  testWidgets('counter increments and never becomes negative', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CounterWidget())),
    );
    expect(find.text('Count: 0'), findsOneWidget);
    await tester.tap(find.byKey(const Key('decrement')));
    await tester.pump();
    expect(find.text('Count: 0'), findsOneWidget);
    await tester.tap(find.byKey(const Key('increment')));
    await tester.pump();
    expect(find.text('Count: 1'), findsOneWidget);
  });
}
