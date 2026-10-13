import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/bill.dart';
import '../utils/dialog_helper.dart';

class UpdateBillScreen extends StatefulWidget {
  final Bill bill;

  const UpdateBillScreen({
    super.key,
    required this.bill,
  });

  @override
  State<UpdateBillScreen> createState() => _UpdateBillScreenState();
}

class _UpdateBillScreenState extends State<UpdateBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _billNameController;
  late final TextEditingController _amountController;
  late final TextEditingController _dueDateController;

  late String _selectedCategory;
  late String _selectedStatus;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _billNameController = TextEditingController(text: widget.bill.billName);
    final rawAmount = widget.bill.amount % 1 == 0
        ? widget.bill.amount.toInt().toString()
        : widget.bill.amount.toString();
    _amountController = TextEditingController(text: rawAmount);
    _dueDateController = TextEditingController(text: widget.bill.dueDate);

    _selectedCategory = Bill.categories.contains(widget.bill.category)
        ? widget.bill.category
        : Bill.categories.first;
    _selectedStatus = Bill.statuses.contains(widget.bill.status)
        ? widget.bill.status
        : 'Unpaid';
  }

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

  Future<void> _updateBill() async {
    if (_isProcessing) return;

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

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(
        _amountController.text.trim().replaceAll(',', ''),
      );
      final updatedBill = widget.bill.copyWith(
        billName: _billNameController.text.trim(),
        category: _selectedCategory,
        amount: amount,
        status: _selectedStatus,
        dueDate: _dueDateController.text.trim(),
      );

      await DatabaseHelper.instance.updateBill(updatedBill);

      if (!mounted) return;
      await DialogHelper.showMessageDialog(
        context,
        title: 'Success',
        message: 'Bill updated successfully',
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _deleteBill() async {
    if (_isProcessing || widget.bill.id == null) return;

    final confirmed = await DialogHelper.showConfirmDeleteDialog(context);
    if (!confirmed || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      await DatabaseHelper.instance.deleteBill(widget.bill.id!);

      if (!mounted) return;
      await DialogHelper.showMessageDialog(
        context,
        title: 'Success',
        message: 'Bill deleted',
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
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
          'Update Bill',
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
                    hintText: 'e.g., Internet - Viettel',
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
                    hintText: 'e.g., 250000',
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Due Date (YYYY-MM-DD) *'),
                TextFormField(
                  controller: _dueDateController,
                  decoration: _inputDecoration(
                    hintText: 'e.g., 2025-11-01',
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

                _buildLabel('Status *'),
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
                          onPressed: _isProcessing ? null : _updateBill,
                          icon: const Icon(Icons.save_outlined, size: 17),
                          label: const Text(
                            'Update',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _deleteBill,
                          icon: const Icon(Icons.delete_outline, size: 17),
                          label: const Text(
                            'Delete',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF44336),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.arrow_back, size: 17),
                          label: const Text(
                            'Back',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF757575),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
