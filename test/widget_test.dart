import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slot_08_student_manager/main.dart';
import 'package:slot_08_student_manager/models/student.dart';
import 'package:slot_08_student_manager/routes/app_routes.dart';
import 'package:slot_08_student_manager/screens/student_detail_screen.dart';

void main() {
  testWidgets(
    'student list displays initial students and adds a new student via form',
    (tester) async {
      await tester.pumpWidget(const StudentManagerApp());
      await tester.tap(find.text('Xem danh sách sinh viên'));
      await tester.pumpAndSettle();

      expect(find.text('Nguyễn Văn A'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('student-id')), 'S004');
      await tester.enterText(find.byKey(const Key('student-name')), 'Phạm Văn D');
      await tester.enterText(find.byKey(const Key('student-age')), '22');
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(find.text('Phạm Văn D'), findsOneWidget);
    },
  );

  testWidgets('detail screen validates ModalRoute arguments', (tester) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        routes: {
          AppRoutes.studentDetail: (_) => const StudentDetailScreen(),
        },
        home: const Scaffold(),
      ),
    );

    key.currentState!.pushNamed(
      AppRoutes.studentDetail,
      arguments: const Student(id: 'S001', name: 'Nguyễn Văn A', age: 20),
    );
    await tester.pumpAndSettle();
    expect(find.text('ID: S001'), findsOneWidget);
    expect(find.text('Tên: Nguyễn Văn A'), findsOneWidget);

    key.currentState!.pop();
    key.currentState!.pushNamed(AppRoutes.studentDetail, arguments: 'invalid');
    await tester.pumpAndSettle();
    expect(
      find.text('Không có dữ liệu sinh viên (arguments null hoặc sai kiểu).'),
      findsOneWidget,
    );
  });
}
