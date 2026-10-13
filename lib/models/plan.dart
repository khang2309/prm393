import 'package:flutter/material.dart';

class Plan {
  const Plan({required this.title, required this.date, required this.time});
  final String title;
  final DateTime date;
  final TimeOfDay time;
}
