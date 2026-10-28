import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/computer_store_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 2,
  );

  Map<String, Object?> _general = const {};
  List<Map<String, Object?>> _brandStatistics = const [];
  List<Map<String, Object?>> _categoryStatistics = const [];
  Map<String, Object?> _bestSelling = const {};
  Map<String, Object?> _mostExpensive = const {};
  List<Map<String, Object?>> _lowStock = const [];
  Map<String, Object?> _topBrand = const {};
  Map<String, Object?> _featured = const {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final values = await Future.wait<Object?>([
        ComputerStoreService.instance.getStatistics(),
        ComputerStoreService.instance.getBrandStatistics(),
        ComputerStoreService.instance.getCategoryStatistics(),
        ComputerStoreService.instance.getBestSellingProduct(),
        ComputerStoreService.instance.getMostExpensiveProduct(),
        ComputerStoreService.instance.getLowStockProducts(),
        ComputerStoreService.instance.getTopBrand(),
        ComputerStoreService.instance.getFeaturedStatistics(),
      ]);
      if (!mounted) return;

      setState(() {
        _general = _asMap(values[0]);
        _brandStatistics = _asMapList(values[1]);
        _categoryStatistics = _asMapList(values[2]);
        _bestSelling = _asMap(values[3]);
        _mostExpensive = _asMap(values[4]);
        _lowStock = _asMapList(values[5]);
        _topBrand = _asMap(values[6]);
        _featured = _asMap(values[7]);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to calculate statistics: $error';
      });
    }
  }

  Map<String, Object?> _asMap(Object? value) {
    if (value is! Map) return const {};
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  List<Map<String, Object?>> _asMapList(Object? value) {
    if (value is! List) return const [];
    return value.map(_asMap).toList(growable: false);
  }

  num _number(Map<String, Object?> source, String key) {
    return source[key] is num ? source[key]! as num : 0;
  }

  String _text(Map<String, Object?> source, String key) {
    return source[key]?.toString() ?? '—';
  }

  String _wholeNumber(num value) =>
      NumberFormat.decimalPattern('en_US').format(value);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
                onPressed: _loadStatistics,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _SectionTitle(
            title: 'General Statistics',
            icon: Icons.analytics_outlined,
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricCard(
                    width: width,
                    label: 'Total Products',
                    value: _wholeNumber(_number(_general, 'totalProducts')),
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFF3157D5),
                  ),
                  _MetricCard(
                    width: width,
                    label: 'Total Revenue',
                    value: _currency.format(_number(_general, 'totalRevenue')),
                    icon: Icons.payments_outlined,
                    color: const Color(0xFF168A62),
                  ),
                  _MetricCard(
                    width: width,
                    label: 'Total Sold Quantity',
                    value: _wholeNumber(_number(_general, 'totalSoldQuantity')),
                    icon: Icons.shopping_bag_outlined,
                    color: const Color(0xFFB15D00),
                  ),
                  _MetricCard(
                    width: width,
                    label: 'Average Product Price',
                    value: _currency.format(_number(_general, 'averagePrice')),
                    icon: Icons.price_check_outlined,
                    color: const Color(0xFF7A45B8),
                  ),
                  _MetricCard(
                    width: constraints.maxWidth,
                    label: 'Total Inventory Value',
                    value: _currency.format(
                      _number(_general, 'totalInventoryValue'),
                    ),
                    icon: Icons.warehouse_outlined,
                    color: const Color(0xFF0A7180),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            title: 'Business Highlights',
            icon: Icons.emoji_events_outlined,
          ),
          const SizedBox(height: 10),
          _HighlightCard(
            icon: Icons.local_fire_department_outlined,
            title: 'Best Selling Product',
            primary: _text(_bestSelling, 'productName'),
            secondary:
                '${_wholeNumber(_number(_bestSelling, 'soldQuantity'))} sold',
          ),
          const SizedBox(height: 10),
          _HighlightCard(
            icon: Icons.diamond_outlined,
            title: 'Most Expensive Product',
            primary: _text(_mostExpensive, 'productName'),
            secondary: _currency.format(_number(_mostExpensive, 'price')),
          ),
          const SizedBox(height: 10),
          _HighlightCard(
            icon: Icons.military_tech_outlined,
            title: 'Top Brand',
            primary: _text(_topBrand, 'brandName'),
            secondary:
                '${_wholeNumber(_number(_topBrand, 'totalSold'))} units sold',
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            title: 'Featured Statistics',
            icon: Icons.star_outline_rounded,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DataRow(
                    label: 'Total Featured Products',
                    value: _wholeNumber(
                      _number(_featured, 'totalFeaturedProducts'),
                    ),
                  ),
                  const Divider(height: 22),
                  _DataRow(
                    label: 'Total Featured Revenue',
                    value: _currency.format(
                      _number(_featured, 'totalFeaturedRevenue'),
                    ),
                  ),
                  const Divider(height: 22),
                  _DataRow(
                    label: 'Total Featured Sold Quantity',
                    value: _wholeNumber(
                      _number(_featured, 'totalFeaturedSoldQuantity'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            title: 'Statistics by Brand',
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: 10),
          ..._brandStatistics.map(
            (brand) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _text(brand, 'brandName'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      _DataRow(
                        label: 'Number of Products',
                        value: _wholeNumber(_number(brand, 'totalProducts')),
                      ),
                      _DataRow(
                        label: 'Total Sold Quantity',
                        value: _wholeNumber(_number(brand, 'totalSold')),
                      ),
                      _DataRow(
                        label: 'Total Revenue',
                        value: _currency.format(_number(brand, 'revenue')),
                      ),
                      _DataRow(
                        label: 'Inventory Value',
                        value: _currency.format(
                          _number(brand, 'inventoryValue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _SectionTitle(
            title: 'Statistics by Category',
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 10),
          ..._categoryStatistics.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _text(category, 'categoryName'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      _DataRow(
                        label: 'Total Products',
                        value: _wholeNumber(_number(category, 'totalProducts')),
                      ),
                      _DataRow(
                        label: 'Total Revenue',
                        value: _currency.format(_number(category, 'revenue')),
                      ),
                      _DataRow(
                        label: 'Total Sold',
                        value: _wholeNumber(_number(category, 'totalSold')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _SectionTitle(
            title: 'Low Stock Products',
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 10),
          if (_lowStock.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('No low stock products.'),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (var index = 0; index < _lowStock.length; index++) ...[
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.computer_rounded),
                      ),
                      title: Text(_text(_lowStock[index], 'productName')),
                      subtitle: Text(_text(_lowStock[index], 'brandName')),
                      trailing: Text(
                        'Stock: ${_wholeNumber(_number(_lowStock[index], 'stock'))}',
                        style: const TextStyle(
                          color: Color(0xFFB3261E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (index != _lowStock.length - 1)
                      const Divider(height: 1, indent: 72),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: color, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: const Color(0xFF6D7488)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.primary,
    required this.secondary,
  });

  final IconData icon;
  final String title;
  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(
          primary,
          style: const TextStyle(
            color: Color(0xFF17213D),
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Text(
          secondary,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6D7488)),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
