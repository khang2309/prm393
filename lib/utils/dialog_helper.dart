import 'package:flutter/material.dart';

class DialogHelper {
  static Future<void> showMessageDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF00897B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool> showConfirmDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Confirm Delete',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to delete this bill?',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Color(0xFF00897B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'DELETE',
              style: TextStyle(
                color: Color(0xFF00897B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Validates bill form inputs and returns an error message if invalid, or null if valid.
  static String? validateBillInputs({
    required String billName,
    required String category,
    required String amountText,
    required String dueDate,
  }) {
    if (billName.trim().isEmpty) {
      return 'Please enter bill name';
    }
    if (category.trim().isEmpty) {
      return 'Please select a category';
    }
    if (amountText.trim().isEmpty) {
      return 'Please enter amount';
    }
    final normalizedAmount = amountText.trim().replaceAll(',', '');
    final parsedAmount = double.tryParse(normalizedAmount);
    if (parsedAmount == null || parsedAmount <= 0) {
      return 'Please enter a valid positive amount';
    }
    if (dueDate.trim().isEmpty) {
      return 'Please enter due date (YYYY-MM-DD)';
    }
    final isoDateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!isoDateRegex.hasMatch(dueDate.trim())) {
      return 'Due date must be in YYYY-MM-DD format (e.g., 2025-10-30)';
    }
    final parsedDate = DateTime.tryParse(dueDate.trim());
    if (parsedDate == null) {
      return 'Please enter a valid calendar date (YYYY-MM-DD)';
    }
    return null;
  }
}
