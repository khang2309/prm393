import 'package:flutter/material.dart';

import '../services/computer_store_service.dart';
import '../models/product_category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, this.onDataChanged});

  final VoidCallback? onDataChanged;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<ProductCategory> _categories = const [];
  bool _isLoading = true;
  String? _loadError;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories({bool showLoader = false}) async {
    final requestVersion = ++_requestVersion;
    if (mounted && (showLoader || _categories.isEmpty)) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final categories = await ComputerStoreService.instance.getCategories(
        query: _searchController.text.trim(),
      );
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Unable to load categories.';
      });
    }
  }

  Future<void> _openCategoryForm([ProductCategory? category]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CategoryFormDialog(category: category),
    );
    if (saved != true || !mounted) return;

    await _loadCategories();
    if (!mounted) return;
    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category added successfully.')),
      );
    }
    widget.onDataChanged?.call();
  }

  Future<bool> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text('Are you sure you want to delete this category?'),
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

  Future<void> _showCategoryInUseMessage() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text(
          'This category cannot be deleted because one or more products belong to this category.',
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

  Future<void> _deleteCategory(ProductCategory category) async {
    final id = category.id;
    if (id == null || !await _confirmDelete() || !mounted) return;

    try {
      final usageCount = await ComputerStoreService.instance
          .getCategoryUsageCount(id);
      if (!mounted) return;
      if (usageCount > 0) {
        await _showCategoryInUseMessage();
        return;
      }
      await ComputerStoreService.instance.deleteCategory(id);
    } catch (_) {
      if (!mounted) return;
      final usageCount = await ComputerStoreService.instance
          .getCategoryUsageCount(id)
          .catchError((_) => 0);
      if (!mounted) return;
      if (usageCount > 0) {
        await _showCategoryInUseMessage();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete category.')),
        );
      }
      return;
    }

    if (!mounted) return;
    await _loadCategories();
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
                  onChanged: (_) => _loadCategories(),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search by category name',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              _loadCategories();
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
                onPressed: _openCategoryForm,
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
      return _CategoryRetryState(
        message: message,
        onRetry: () => _loadCategories(showLoader: true),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: _categories.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 160),
                Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Center(child: Text('No categories found.')),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    leading: const CircleAvatar(
                      child: Icon(Icons.category_outlined),
                    ),
                    title: Text(
                      category.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('Products: ${category.totalProducts}'),
                    ),
                    trailing: PopupMenuButton<_CategoryAction>(
                      tooltip: 'Category actions',
                      onSelected: (action) async {
                        switch (action) {
                          case _CategoryAction.edit:
                            await _openCategoryForm(category);
                          case _CategoryAction.delete:
                            await _deleteCategory(category);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _CategoryAction.edit,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit'),
                          ),
                        ),
                        PopupMenuItem(
                          value: _CategoryAction.delete,
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

enum _CategoryAction { edit, delete }

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.category});

  final ProductCategory? category;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String? _uniqueError;
  String? _saveError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.category?.categoryName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() {
      _uniqueError = null;
      _saveError = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    final name = _nameController.text.trim();
    final unique = await ComputerStoreService.instance.isCategoryNameUnique(
      name,
      excludeId: widget.category?.id,
    );
    if (!mounted) return;
    if (!unique) {
      setState(() {
        _isSaving = false;
        _uniqueError = 'Category Name must be unique.';
      });
      _formKey.currentState?.validate();
      return;
    }

    final current = widget.category;
    final category = ProductCategory(
      id: current?.id,
      categoryName: name,
      totalProducts: current?.totalProducts ?? 0,
    );
    try {
      if (current == null) {
        await ComputerStoreService.instance.insertCategory(category);
      } else {
        await ComputerStoreService.instance.updateCategory(category);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = 'Unable to save category.';
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  if (_uniqueError != null) {
                    setState(() => _uniqueError = null);
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Category Name is required.';
                  }
                  return _uniqueError;
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

class _CategoryRetryState extends StatelessWidget {
  const _CategoryRetryState({required this.message, required this.onRetry});

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
