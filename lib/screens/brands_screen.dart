import 'package:flutter/material.dart';

import '../services/computer_store_service.dart';
import '../models/brand.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key, this.onDataChanged});

  final VoidCallback? onDataChanged;

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Brand> _brands = const [];
  bool _isLoading = true;
  String? _loadError;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands({bool showLoader = false}) async {
    final requestVersion = ++_requestVersion;
    if (mounted && (showLoader || _brands.isEmpty)) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final brands = await ComputerStoreService.instance.getBrands(
        query: _searchController.text.trim(),
      );
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _brands = brands;
        _isLoading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Unable to load brands.';
      });
    }
  }

  Future<void> _openBrandForm([Brand? brand]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BrandFormDialog(brand: brand),
    );
    if (saved != true || !mounted) return;

    await _loadBrands();
    if (!mounted) return;
    if (brand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brand added successfully.')),
      );
    }
    widget.onDataChanged?.call();
  }

  Future<bool> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text('Are you sure you want to delete this brand?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _showBrandInUseMessage() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text(
          'This brand cannot be deleted because it is currently used by one or more products.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBrand(Brand brand) async {
    final id = brand.id;
    if (id == null || !await _confirmDelete() || !mounted) return;

    try {
      final usageCount = await ComputerStoreService.instance.getBrandUsageCount(
        id,
      );
      if (!mounted) return;
      if (usageCount > 0) {
        await _showBrandInUseMessage();
        return;
      }
      await ComputerStoreService.instance.deleteBrand(id);
    } catch (_) {
      if (!mounted) return;
      final usageCount = await ComputerStoreService.instance
          .getBrandUsageCount(id)
          .catchError((_) => 0);
      if (!mounted) return;
      if (usageCount > 0) {
        await _showBrandInUseMessage();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete brand.')),
        );
      }
      return;
    }

    if (!mounted) return;
    await _loadBrands();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Delete successfully.')));
    widget.onDataChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _loadBrands(),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by brand name or country',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              _loadBrands();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _openBrandForm,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError case final message?) {
      return _RetryState(
        message: message,
        onRetry: () => _loadBrands(showLoader: true),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBrands,
      child: _brands.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 160),
                Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Center(child: Text('No brands found.')),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _brands.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final brand = _brands[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    leading: CircleAvatar(
                      child: Text(
                        brand.brandName.isEmpty
                            ? '?'
                            : brand.brandName.substring(0, 1).toUpperCase(),
                      ),
                    ),
                    title: Text(
                      brand.brandName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Country: ${brand.country}\n'
                        'Founded: ${brand.foundedYear}\n'
                        'Products: ${brand.totalProducts}',
                      ),
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<_BrandAction>(
                      tooltip: 'Brand actions',
                      onSelected: (action) async {
                        switch (action) {
                          case _BrandAction.edit:
                            await _openBrandForm(brand);
                          case _BrandAction.delete:
                            await _deleteBrand(brand);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _BrandAction.edit,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit'),
                          ),
                        ),
                        PopupMenuItem(
                          value: _BrandAction.delete,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            title: Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

enum _BrandAction { edit, delete }

class _BrandFormDialog extends StatefulWidget {
  const _BrandFormDialog({this.brand});

  final Brand? brand;

  @override
  State<_BrandFormDialog> createState() => _BrandFormDialogState();
}

class _BrandFormDialogState extends State<_BrandFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _yearController;
  String? _duplicateError;
  String? _saveError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final brand = widget.brand;
    _nameController = TextEditingController(text: brand?.brandName ?? '');
    _countryController = TextEditingController(text: brand?.country ?? '');
    _yearController = TextEditingController(
      text: brand == null ? '' : brand.foundedYear.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() {
      _duplicateError = null;
      _saveError = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final country = _countryController.text.trim();
    final year = int.parse(_yearController.text.trim());
    final current = widget.brand;
    setState(() => _isSaving = true);
    final unique = await ComputerStoreService.instance.isBrandNameUnique(
      name,
      excludeId: current?.id,
    );
    if (!mounted) return;
    if (!unique) {
      setState(() {
        _isSaving = false;
        _duplicateError = 'Duplicate Brand Name is not allowed.';
      });
      _formKey.currentState?.validate();
      return;
    }

    final brand = Brand(
      id: current?.id,
      brandName: name,
      country: country,
      foundedYear: year,
      totalProducts: current?.totalProducts ?? 0,
    );

    try {
      if (current == null) {
        await ComputerStoreService.instance.insertBrand(brand);
      } else {
        await ComputerStoreService.instance.updateBrand(brand);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = 'Unable to save brand.';
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.brand == null ? 'Add Brand' : 'Edit Brand'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) {
                    if (_duplicateError != null) {
                      setState(() => _duplicateError = null);
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(labelText: 'Brand Name'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Brand Name cannot be empty.';
                    }
                    return _duplicateError;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _countryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Country'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Country cannot be empty.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Founded Year'),
                  validator: (value) {
                    final year = int.tryParse((value ?? '').trim());
                    if (year == null || year <= 1900) {
                      return 'Founded Year must be greater than 1900.';
                    }
                    return null;
                  },
                ),
                if (_saveError case final message?) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _RetryState extends StatelessWidget {
  const _RetryState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
