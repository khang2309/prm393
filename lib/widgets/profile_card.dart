import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String description;

  const ProfileCard({
    super.key,
    this.name = 'Nguyễn Văn A',
    this.role = 'Flutter Beginner',
    this.description = 'Why I learn Flutter: Xây dựng ứng dụng đa nền tảng.',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(role),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
