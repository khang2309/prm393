import 'package:flutter/material.dart';

import 'add_item_screen.dart';
import 'home_screen.dart';
import 'wishlist_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  int _refreshToken = 0;

  void _refresh() => setState(() => _refreshToken++);

  Future<void> _openAddScreen() async {
    final itemName = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const AddItemScreen()));
    if (!mounted || itemName == null) return;
    _refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added “$itemName” to your shopping items.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(refreshToken: _refreshToken, onChanged: _refresh),
          WishlistScreen(refreshToken: _refreshToken),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _openAddScreen,
              tooltip: 'Add shopping item',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() {
          _selectedIndex = index;
          _refreshToken++;
        }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
        ],
      ),
    );
  }
}
