import 'package:flutter/material.dart';

import '../models/student.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Student ID: ${student.id}'),
            const SizedBox(height: 8),
            Text('Email: ${student.email}'),
            const SizedBox(height: 8),
            Text('Major: ${student.major}'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Selected status: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Icon(
                  student.isSelected
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: student.isSelected ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
