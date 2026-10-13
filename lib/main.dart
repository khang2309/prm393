import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'screens/home_screen.dart';
import 'screens/student_detail_screen.dart';
import 'screens/student_form_screen.dart';
import 'screens/student_list_screen.dart';

void main() {
  runApp(const StudentManagerApp());
}

class StudentManagerApp extends StatelessWidget {
  const StudentManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Manager',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.studentList: (context) => const StudentListScreen(),
        AppRoutes.studentDetail: (context) => const StudentDetailScreen(),
        AppRoutes.studentForm: (context) => const StudentFormScreen(),
      },
      onGenerateRoute: (settings) {
        debugPrint('onGenerateRoute được gọi với: ${settings.name}');
        return null;
      },
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}
