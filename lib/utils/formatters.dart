import 'package:intl/intl.dart';

final NumberFormat _vndFormatter = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
);

String formatVnd(double value) => _vndFormatter.format(value);
