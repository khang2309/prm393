import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slot_05_live_counter_stream/screens/home_screen.dart';

void main() {
  testWidgets('screen reacts to stream values', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(stream: Stream<int>.fromIterable([1, 2])),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Counter: 2'), findsOneWidget);
  });
}
