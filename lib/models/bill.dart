import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Bill {
  final int? id;
  final String billName;
  final String category;
  final double amount;
  final String status;
  final String dueDate;

  const Bill({
    this.id,
    required this.billName,
    required this.category,
    required this.amount,
    required this.status,
    required this.dueDate,
  });

  static const List<String> categories = [
    'Utilities',
    'Subscription',
    'Rent',
    'Finance',
    'Health',
  ];

  static const List<String> statuses = [
    'Unpaid',
    'Paid',
  ];

  Bill copyWith({
    int? id,
    String? billName,
    String? category,
    double? amount,
    String? status,
    String? dueDate,
  }) {
    return Bill(
      id: id ?? this.id,
      billName: billName ?? this.billName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'bill_name': billName,
      'category': category,
      'amount': amount,
      'status': status,
      'due_date': dueDate,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] as int?,
      billName: map['bill_name'] as String? ?? '',
      category: map['category'] as String? ?? 'Utilities',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Unpaid',
      dueDate: map['due_date'] as String? ?? '',
    );
  }

  bool get isPaid => status.toLowerCase() == 'paid';

  String get formattedAmount => formatVnd(amount);

  static String formatVnd(double value) {
    final formatter = NumberFormat.decimalPattern('vi_VN');
    return '${formatter.format(value.round())} ₫';
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Utilities':
        return Icons.lightbulb_outline;
      case 'Subscription':
        return Icons.wifi;
      case 'Rent':
        return Icons.home_outlined;
      case 'Finance':
        return Icons.account_balance_wallet_outlined;
      case 'Health':
        return Icons.medical_services_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}
