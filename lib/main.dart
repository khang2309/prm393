import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const StudentListApp());

class StudentListApp extends StatelessWidget {
  const StudentListApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
    home: const HomeScreen(),
  );
}
