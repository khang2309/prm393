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
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text('Added "$itemName" to wishlist'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
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
              backgroundColor: const Color(0xFF7000F5),
              foregroundColor: Colors.white,
              onPressed: _openAddScreen,
              tooltip: 'Add shopping item',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF7000F5),
        unselectedItemColor: const Color(0xFF888888),
        selectedFontSize: 11,
        unselectedFontSize: 11,
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
