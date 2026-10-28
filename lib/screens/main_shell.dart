import 'package:flutter/material.dart';

import 'brands_screen.dart';
import 'categories_screen.dart';
import 'computer_form_screen.dart';
import 'statistics_screen.dart';
import 'store_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _titles = <String>[
    'Computer Store',
    'Add Computer',
    'Brands',
    'Categories',
    'Statistics',
    'Featured Products',
  ];

  int _currentIndex = 0;
  int _dataRevision = 0;

  void _selectTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  void _markDataChanged() {
    if (!mounted) return;
    setState(() => _dataRevision++);
  }

  void _handleComputerAdded() {
    if (!mounted) return;
    setState(() {
      _dataRevision++;
      _currentIndex = 0;
    });
  }

  Widget _buildCurrentPage() {
    return switch (_currentIndex) {
      0 => StoreScreen(
        key: ValueKey('store-$_dataRevision'),
        onDataChanged: _markDataChanged,
      ),
      1 => ComputerFormScreen(
        key: ValueKey('add-$_dataRevision'),
        embedded: true,
        onSaved: _handleComputerAdded,
      ),
      2 => BrandsScreen(
        key: ValueKey('brands-$_dataRevision'),
        onDataChanged: _markDataChanged,
      ),
      3 => CategoriesScreen(
        key: ValueKey('categories-$_dataRevision'),
        onDataChanged: _markDataChanged,
      ),
      4 => StatisticsScreen(key: ValueKey('statistics-$_dataRevision')),
      5 => StoreScreen(
        key: ValueKey('featured-$_dataRevision'),
        featuredOnly: true,
        showBanner: false,
        onDataChanged: _markDataChanged,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: ValueKey('content-$_currentIndex-$_dataRevision'),
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Text(_titles[_currentIndex]),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => setState(() => _dataRevision++),
                  icon: const Icon(Icons.refresh_rounded),
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: SafeArea(child: _buildCurrentPage()),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _selectTab,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: const Color(0xFF6D7488),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront_rounded),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box_rounded),
            label: 'Add Computer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business_rounded),
            label: 'Brands',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category_rounded),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.query_stats_outlined),
            activeIcon: Icon(Icons.query_stats_rounded),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline_rounded),
            activeIcon: Icon(Icons.star_rounded),
            label: 'Featured',
          ),
        ],
      ),
    );
  }
}
