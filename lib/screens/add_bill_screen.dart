import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/bill.dart';
import '../utils/dialog_helper.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _billNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dueDateController = TextEditingController();

  String _selectedCategory = Bill.categories.first; // 'Utilities'
  String _selectedStatus = 'Unpaid'; // Defaults to "Unpaid"
  bool _isSaving = false;

  @override
  void dispose() {
    _billNameController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initialDate =
        DateTime.tryParse(_dueDateController.text.trim()) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveBill() async {
    if (_isSaving) return;

    final error = DialogHelper.validateBillInputs(
      billName: _billNameController.text,
      category: _selectedCategory,
      amountText: _amountController.text,
      dueDate: _dueDateController.text,
    );

    if (error != null) {
      await DialogHelper.showMessageDialog(
        context,
        title: 'Validation',
        message: error,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final amount = double.parse(
        _amountController.text.trim().replaceAll(',', ''),
      );
      final newBill = Bill(
        billName: _billNameController.text.trim(),
        category: _selectedCategory,
        amount: amount,
        status: _selectedStatus,
        dueDate: _dueDateController.text.trim(),
      );

      await DatabaseHelper.instance.insertBill(newBill);

      if (!mounted) return;
      await DialogHelper.showMessageDialog(
        context,
        title: 'Success',
        message: 'Bill added successfully',
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF6200EE), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Add New Bill',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Bill Name *'),
                TextFormField(
                  controller: _billNameController,
                  decoration: _inputDecoration(
                    hintText: 'e.g., Electricity - September',
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Category *'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: _inputDecoration(),
                  items: Bill.categories
                      .map(
                        (cat) => DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat, style: const TextStyle(fontSize: 14)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('Amount (VND) *'),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    hintText: 'e.g., 850000',
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Due Date (YYYY-MM-DD) *'),
                TextFormField(
                  controller: _dueDateController,
                  decoration: _inputDecoration(
                    hintText: 'e.g., 2025-10-30',
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      tooltip: 'Pick Due Date',
                      onPressed: _pickDueDate,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Status'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: _inputDecoration(),
                  items: Bill.statuses
                      .map(
                        (st) => DropdownMenuItem<String>(
                          value: st,
                          child: Text(st, style: const TextStyle(fontSize: 14)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveBill,
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text(
                            'Back',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF757575),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
