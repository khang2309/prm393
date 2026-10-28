import 'dart:async';

import 'package:flutter/material.dart';

import '../services/computer_store_service.dart';
import '../models/brand.dart';
import '../models/product_category.dart';
import '../models/computer.dart';
import '../widgets/computer_card.dart';
import 'computer_detail_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({
    super.key,
    this.featuredOnly = false,
    this.showBanner = true,
    this.onDataChanged,
  });

  final bool featuredOnly;
  final bool showBanner;
  final VoidCallback? onDataChanged;

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  static const _stockOptions = <String>[
    'In Stock',
    'Low Stock',
    'Out of Stock',
  ];
  static const _ramOptions = <String>['8 GB', '16 GB', '32 GB or above'];
  static const _storageOptions = <String>['256 GB', '512 GB', '1 TB', '2 TB+'];
  static const _priceOptions = <String>[
    'Less than 500',
    '500 – 1000',
    'Greater than 1000',
  ];
  static const _sortOptions = <String, String>{
    'nameAsc': 'Product Name: A → Z',
    'nameDesc': 'Product Name: Z → A',
    'priceAsc': 'Price: Ascending',
    'priceDesc': 'Price: Descending',
    'soldAsc': 'Sold Quantity: Ascending',
    'soldDesc': 'Sold Quantity: Descending',
    'brandAsc': 'Brand Name: A → Z',
    'brandDesc': 'Brand Name: Z → A',
    'stockAsc': 'Stock: Low → High',
    'stockDesc': 'Stock: High → Low',
  };

  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<Brand> _brands = const [];
  List<ProductCategory> _categories = const [];
  List<Computer> _computers = const [];

  int? _brandId;
  int? _categoryId;
  bool _featuredFilter = false;
  String? _stockStatus;
  String? _ramOption;
  String? _storageOption;
  String? _priceOption;
  String _sortOption = 'nameAsc';

  bool _isLoading = true;
  String? _errorMessage;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait<Object>([
        ComputerStoreService.instance.getBrands(),
        ComputerStoreService.instance.getCategories(),
      ]);
      if (!mounted) return;
      setState(() {
        _brands = results[0] as List<Brand>;
        _categories = results[1] as List<ProductCategory>;
      });
      await _loadComputers();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load store data: $error';
      });
    }
  }

  Future<void> _loadComputers() async {
    final requestId = ++_requestId;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final computers = await ComputerStoreService.instance.getComputers(
        keyword: _searchController.text.trim(),
        brandId: _brandId,
        categoryId: _categoryId,
        featuredOnly: widget.featuredOnly || _featuredFilter,
        stockStatus: _stockStatus,
        ramOption: _ramOption,
        storageOption: _storageOption,
        priceOption: _priceOption,
        sortOption: _sortOption,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _computers = computers;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load computers: $error';
      });
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), _loadComputers);
    setState(() {});
  }

  int get _activeFilterCount {
    return <Object?>[
      _brandId,
      _categoryId,
      if (_featuredFilter) true,
      _stockStatus,
      _ramOption,
      _storageOption,
      _priceOption,
    ].where((value) => value != null).length;
  }

  bool get _canReset {
    return _searchController.text.isNotEmpty ||
        _activeFilterCount > 0 ||
        _sortOption != 'nameAsc';
  }

  void _resetFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _brandId = null;
      _categoryId = null;
      _featuredFilter = false;
      _stockStatus = null;
      _ramOption = null;
      _storageOption = null;
      _priceOption = null;
      _sortOption = 'nameAsc';
    });
    _loadComputers();
  }

  Future<void> _showFilters() async {
    var brandId = _brandId;
    var categoryId = _categoryId;
    var featured = widget.featuredOnly || _featuredFilter;
    var stockStatus = _stockStatus;
    var ramOption = _ramOption;
    var storageOption = _storageOption;
    var priceOption = _priceOption;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  20 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filter Computers',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<int?>(
                      initialValue: brandId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Brand'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All brands'),
                        ),
                        ..._brands.map(
                          (brand) => DropdownMenuItem<int?>(
                            value: brand.id,
                            child: Text(brand.brandName),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setSheetState(() => brandId = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      initialValue: categoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All categories'),
                        ),
                        ..._categories.map(
                          (category) => DropdownMenuItem<int?>(
                            value: category.id,
                            child: Text(category.categoryName),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setSheetState(() => categoryId = value),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: featured,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: const Text('Featured Only'),
                      onChanged: widget.featuredOnly
                          ? null
                          : (value) => setSheetState(() => featured = value),
                    ),
                    const SizedBox(height: 8),
                    _FilterDropdown(
                      label: 'Stock Status',
                      value: stockStatus,
                      options: _stockOptions,
                      onChanged: (value) =>
                          setSheetState(() => stockStatus = value),
                    ),
                    const SizedBox(height: 12),
                    _FilterDropdown(
                      label: 'RAM',
                      value: ramOption,
                      options: _ramOptions,
                      onChanged: (value) =>
                          setSheetState(() => ramOption = value),
                    ),
                    const SizedBox(height: 12),
                    _FilterDropdown(
                      label: 'Storage',
                      value: storageOption,
                      options: _storageOptions,
                      onChanged: (value) =>
                          setSheetState(() => storageOption = value),
                    ),
                    const SizedBox(height: 12),
                    _FilterDropdown(
                      label: 'Price',
                      value: priceOption,
                      options: _priceOptions,
                      onChanged: (value) =>
                          setSheetState(() => priceOption = value),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                              _resetFilters();
                            },
                            child: const Text('Reset Filters'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _brandId = brandId;
                                _categoryId = categoryId;
                                _featuredFilter = widget.featuredOnly
                                    ? false
                                    : featured;
                                _stockStatus = stockStatus;
                                _ramOption = ramOption;
                                _storageOption = storageOption;
                                _priceOption = priceOption;
                              });
                              Navigator.of(sheetContext).pop();
                              _loadComputers();
                            },
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSortOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  'Sort Computers',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              for (final option in _sortOptions.entries)
                ListTile(
                  title: Text(option.value),
                  trailing: _sortOption == option.key
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(Icons.circle_outlined),
                  onTap: () {
                    setState(() => _sortOption = option.key);
                    Navigator.of(sheetContext).pop();
                    _loadComputers();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openComputer(Computer computer) async {
    final id = computer.id;
    if (id == null) return;

    final result = await Navigator.of(context).push<ComputerDetailResult>(
      MaterialPageRoute(builder: (_) => ComputerDetailScreen(computerId: id)),
    );
    if (!mounted || result == null) return;

    if (result == ComputerDetailResult.deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Computer deleted successfully.')),
      );
    }
    await _loadComputers();
    widget.onDataChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showBanner)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 2.4,
                child: Image.asset(
                  'assets/images/banner.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by product, brand, or CPU',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        _loadComputers();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.tune_rounded),
                  label: Text(
                    _activeFilterCount == 0
                        ? 'Filter'
                        : 'Filter ($_activeFilterCount)',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showSortOptions,
                  icon: const Icon(Icons.swap_vert_rounded),
                  label: const Text('Sort'),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 12, 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_computers.length} product${_computers.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6D7488),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _canReset ? _resetFilters : null,
                child: const Text('Reset Filters'),
              ),
            ],
          ),
        ),
        Expanded(child: _buildProductArea()),
      ],
    );
  }

  Widget _buildProductArea() {
    if (_isLoading && _computers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final errorMessage = _errorMessage;
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 44),
              const SizedBox(height: 10),
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadInitialData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_computers.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadComputers,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 70),
            Icon(Icons.computer_rounded, size: 64, color: Color(0xFF9AA2B6)),
            SizedBox(height: 12),
            Center(
              child: Text(
                'No matching computers found.',
                style: TextStyle(color: Color(0xFF6D7488)),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadComputers,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _computers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final computer = _computers[index];
              return ComputerCard(
                computer: computer,
                onTap: () => _openComputer(computer),
              );
            },
          ),
        ),
        if (_isLoading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('All')),
        ...options.map(
          (option) =>
              DropdownMenuItem<String?>(value: option, child: Text(option)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
