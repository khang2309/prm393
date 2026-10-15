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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final item = ShoppingItem(
        itemName: _nameController.text.trim(),
        category: _category,
        price: _parsePrice(_priceController.text)!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Shopping Item')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Create a favorite item',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add something you love or plan to buy.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter item name'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Price (VND) *',
                  prefixIcon: Icon(Icons.payments_outlined),
                  hintText: 'e.g. 2500000',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = _parsePrice(value);
                  if (price == null || price <= 0) {
                    return 'Price must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
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
                    child: OutlinedButton.icon(
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
