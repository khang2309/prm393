import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/shopping_database.dart';
import '../models/shopping_item.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  static const _categories = [
    'Fashion',
    'Electronics',
    'Home',
    'Beauty',
    'Sports',
    'Books',
    'Other',
  ];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _category = _categories.first;
  String _status = ShoppingItem.wishlistStatus;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double? _parsePrice(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_nameController.text.trim().isEmpty) {
      await _showMessage('Error', 'Please enter item name');
      return;
    }
    final price = _parsePrice(_priceController.text);
    if (price == null || price <= 0) {
      await _showMessage('Error', 'Please enter a valid price');
      return;
    }
    setState(() => _saving = true);
    try {
      final item = ShoppingItem(
        itemName: _nameController.text.trim(),
        category: _category,
        price: price,
        status: _status,
      );
      await ShoppingDatabase.instance.insert(item);
      if (mounted) Navigator.pop(context, item.itemName);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save item: $error')));
    }
  }

  Future<void> _showMessage(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Shopping Item')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _FieldLabel('Item Name *'),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'e.g. Nike Air Force 1',
                ),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Category *'),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(),
                items: _categories
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Price (VND) *'),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  hintText: 'e.g. 2500000',
                ),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Status'),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(
                    value: ShoppingItem.wishlistStatus,
                    child: Text('Wishlist'),
                  ),
                  DropdownMenuItem(
                    value: ShoppingItem.purchasedStatus,
                    child: Text('Purchased'),
                  ),
                ],
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF858585),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
    ),
  );
}
