import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goToStudentList(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.studentList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Manager - Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _goToStudentList(context),
          child: const Text('Xem danh sách sinh viên'),
        ),
      ),
    );
  }
}
