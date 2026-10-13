import 'package:flutter/material.dart';

import '../models/student.dart';
import '../routes/app_routes.dart';
import '../widgets/student_tile.dart';
import 'student_form_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final List<Student> _students = [
    const Student(id: 'S001', name: 'Nguyễn Văn A', age: 20),
    const Student(id: 'S002', name: 'Trần Thị B', age: 21),
    const Student(id: 'S003', name: 'Lê Văn C', age: 19),
  ];

  void _goToDetail(Student student) {
    Navigator.pushNamed(
      context,
      AppRoutes.studentDetail,
      arguments: student,
    );
  }

  Future<void> _goToForm() async {
    final result = await Navigator.push<Student?>(
      context,
      MaterialPageRoute(
        builder: (ctx) => const StudentFormScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _students.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sinh viên'),
      ),
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return StudentTile(
            student: student,
            onTap: () => _goToDetail(student),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
