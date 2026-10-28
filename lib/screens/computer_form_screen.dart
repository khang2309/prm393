import 'package:flutter/material.dart';

import '../services/computer_store_service.dart';
import '../models/brand.dart';
import '../models/computer.dart';
import '../models/product_category.dart';

class ComputerFormScreen extends StatefulWidget {
  const ComputerFormScreen({
    super.key,
    this.computer,
    this.embedded = false,
    this.onSaved,
  });

  final Computer? computer;
  final bool embedded;
  final VoidCallback? onSaved;

  bool get isEditing => computer != null;

  @override
  State<ComputerFormScreen> createState() => _ComputerFormScreenState();
}

class _ComputerFormScreenState extends State<ComputerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _productNameController;
  late final TextEditingController _cpuController;
  late final TextEditingController _ramController;
  late final TextEditingController _storageController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _soldQuantityController;

  List<Brand> _brands = const [];
  List<ProductCategory> _categories = const [];
  int? _selectedBrandId;
  int? _selectedCategoryId;
  bool _isFeatured = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _duplicateProductName = false;
  String? _loadError;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final computer = widget.computer;
    _productNameController = TextEditingController(
      text: computer?.productName ?? '',
    );
    _cpuController = TextEditingController(text: computer?.cpu ?? '');
    _ramController = TextEditingController(
      text: computer == null ? '' : '${computer.ram}',
    );
    _storageController = TextEditingController(
      text: computer == null ? '' : '${computer.storage}',
    );
    _priceController = TextEditingController(
      text: computer == null ? '' : _editableNumber(computer.price),
    );
    _stockController = TextEditingController(
      text: computer == null ? '' : '${computer.stock}',
    );
    _soldQuantityController = TextEditingController(
      text: computer == null ? '' : '${computer.soldQuantity}',
    );
    _selectedBrandId = computer?.brandId;
    _selectedCategoryId = computer?.categoryId;
    _isFeatured = computer?.isFeatured ?? false;
    _loadLookups();
  }

  static String _editableNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _cpuController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _soldQuantityController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final results = await Future.wait<Object>([
        ComputerStoreService.instance.getBrands(),
        ComputerStoreService.instance.getCategories(),
      ]);
      if (!mounted) return;

      final brands = results[0] as List<Brand>;
      final categories = results[1] as List<ProductCategory>;
      setState(() {
        _brands = brands;
        _categories = categories;
        _selectedBrandId ??= brands.isEmpty ? null : brands.first.id;
        _selectedCategoryId ??= categories.isEmpty ? null : categories.first.id;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Unable to load brands and categories.';
      });
    }
  }

  String? _requiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  String? _validateRam(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'RAM is required.';
    final ram = int.tryParse(text);
    if (ram == null || ram < 4 || ram > 128) {
      return 'RAM must be between 4 and 128 GB.';
    }
    return null;
  }

  String? _validateStorage(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Storage is required.';
    final storage = int.tryParse(text);
    if (storage == null || storage < 128 || storage > 4096) {
      return 'Storage must be between 128 and 4096 GB.';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Price is required.';
    final price = double.tryParse(text);
    if (price == null || !price.isFinite || price <= 0) {
      return 'Price must be greater than 0.';
    }
    return null;
  }

  String? _validateNonNegative(
    String? value,
    String requiredMessage,
    String rangeMessage,
  ) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return requiredMessage;
    final number = int.tryParse(text);
    if (number == null || number < 0) return rangeMessage;
    return null;
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() {
      _duplicateProductName = false;
      _saveError = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final brandId = _selectedBrandId;
    final categoryId = _selectedCategoryId;
    if (brandId == null || categoryId == null) return;

    final productName = _productNameController.text.trim();
    final cpu = _cpuController.text.trim();
    final ram = int.parse(_ramController.text.trim());
    final storage = int.parse(_storageController.text.trim());
    final price = double.parse(_priceController.text.trim());
    final stock = int.parse(_stockController.text.trim());
    final soldQuantity = int.parse(_soldQuantityController.text.trim());
    final isFeatured = _isFeatured;

    setState(() => _isSaving = true);
    try {
      final isUnique = await ComputerStoreService.instance.isProductNameUnique(
        productName,
        excludeId: widget.computer?.id,
      );
      if (!mounted) return;
      if (!isUnique) {
        setState(() {
          _duplicateProductName = true;
          _isSaving = false;
        });
        _formKey.currentState?.validate();
        return;
      }

      final computer = Computer(
        id: widget.computer?.id,
        productName: productName,
        brandId: brandId,
        categoryId: categoryId,
        cpu: cpu,
        ram: ram,
        storage: storage,
        price: price,
        stock: stock,
        soldQuantity: soldQuantity,
        isFeatured: isFeatured,
      );

      if (widget.isEditing) {
        await ComputerStoreService.instance.updateComputer(computer);
      } else {
        await ComputerStoreService.instance.insertComputer(computer);
      }
      if (!mounted) return;

      if (!widget.isEditing) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Computer added successfully.')),
          );
      }

      setState(() => _isSaving = false);
      widget.onSaved?.call();
      if (!widget.embedded && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = 'Unable to save computer.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);
    if (widget.embedded) return content;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Computer' : 'Add Computer'),
      ),
      body: content,
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError case final error?) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 44),
              const SizedBox(height: 12),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadLookups,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('productNameField'),
                controller: _productNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.computer),
                ),
                onChanged: (_) {
                  if (_duplicateProductName) {
                    setState(() => _duplicateProductName = false);
                  }
                },
                validator: (value) {
                  final requiredError = _requiredText(
                    value,
                    'Product Name is required.',
                  );
                  if (requiredError != null) return requiredError;
                  if (_duplicateProductName) {
                    return 'Product Name must be unique.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                key: const Key('brandDropdown'),
                isExpanded: true,
                initialValue: _selectedBrandId,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                items: [
                  for (final brand in _brands)
                    if (brand.id != null)
                      DropdownMenuItem<int>(
                        value: brand.id,
                        child: Text(brand.brandName),
                      ),
                ],
                onChanged: (value) => setState(() {
                  _selectedBrandId = value;
                }),
                validator: (value) =>
                    value == null ? 'Brand is required.' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                key: const Key('categoryDropdown'),
                isExpanded: true,
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  for (final category in _categories)
                    if (category.id != null)
                      DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.categoryName),
                      ),
                ],
                onChanged: (value) => setState(() {
                  _selectedCategoryId = value;
                }),
                validator: (value) =>
                    value == null ? 'Category is required.' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('cpuField'),
                controller: _cpuController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'CPU',
                  prefixIcon: Icon(Icons.memory_outlined),
                ),
                validator: (value) => _requiredText(value, 'CPU is required.'),
              ),
              const SizedBox(height: 14),
              _NumberField(
                fieldKey: const Key('ramField'),
                controller: _ramController,
                label: 'RAM (GB)',
                icon: Icons.developer_board_outlined,
                validator: _validateRam,
              ),
              const SizedBox(height: 14),
              _NumberField(
                fieldKey: const Key('storageField'),
                controller: _storageController,
                label: 'Storage (GB)',
                icon: Icons.storage_outlined,
                validator: _validateStorage,
              ),
              const SizedBox(height: 14),
              _NumberField(
                fieldKey: const Key('priceField'),
                controller: _priceController,
                label: 'Price',
                icon: Icons.attach_money,
                allowDecimal: true,
                validator: _validatePrice,
              ),
              const SizedBox(height: 14),
              _NumberField(
                fieldKey: const Key('stockField'),
                controller: _stockController,
                label: 'Stock',
                icon: Icons.inventory_2_outlined,
                validator: (value) => _validateNonNegative(
                  value,
                  'Stock is required.',
                  'Stock must be greater than or equal to 0.',
                ),
              ),
              const SizedBox(height: 14),
              _NumberField(
                fieldKey: const Key('soldQuantityField'),
                controller: _soldQuantityController,
                label: 'Sold Quantity',
                icon: Icons.shopping_cart_outlined,
                validator: (value) => _validateNonNegative(
                  value,
                  'Sold Quantity is required.',
                  'Sold Quantity must be greater than or equal to 0.',
                ),
              ),
              const SizedBox(height: 14),
              SwitchListTile.adaptive(
                key: const Key('featuredSwitch'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: const Text('Featured'),
                secondary: Icon(
                  _isFeatured ? Icons.star_rounded : Icons.star_border_rounded,
                  color: _isFeatured ? const Color(0xFFFFB300) : null,
                ),
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value),
              ),
              if (_saveError case final error?) ...[
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                key: const Key('saveComputerButton'),
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(widget.isEditing ? 'Save Changes' : 'Add Computer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.allowDecimal = false,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: validator,
    );
  }
}
