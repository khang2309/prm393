import 'package:flutter/material.dart';

import '../database/shopping_database.dart';
import '../models/shopping_item.dart';
import '../widgets/item_card.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.refreshToken,
    required this.onChanged,
  });

  final int refreshToken;
  final VoidCallback onChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ShoppingItem>> _items;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshToken != oldWidget.refreshToken) _loadItems();
  }

  void _loadItems() {
    final items = ShoppingDatabase.instance.getAllItems();
    setState(() {
      _items = items;
    });
  }

  Future<void> _openDetail(ShoppingItem item) async {
    final result = await Navigator.of(context).push<DetailResult>(
      MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
    );
    if (!mounted || result == null) return;
    widget.onChanged();
    if (result == DetailResult.deleted) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Item deleted'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Semantics(
                label: 'Shopping wishlist banner',
                image: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 125,
                  child: Image.asset(
                    'assets/images/banner.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
                color: const Color(0xB35A5149),
                child: FutureBuilder<List<ShoppingItem>>(
                  future: _items,
                  builder: (_, snapshot) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Favorite Shopping Items',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${snapshot.data?.length ?? 0} items',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<ShoppingItem>>(
              future: _items,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return MessageState(
                    icon: Icons.error_outline,
                    title: 'Could not load items',
                    subtitle: '${snapshot.error}',
                    onRetry: _loadItems,
                  );
                }
                final items = snapshot.data ?? const [];
                if (items.isEmpty) {
                  return const MessageState(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Chưa có sản phẩm nào',
                    subtitle: 'Nhấn nút “+” để thêm sản phẩm yêu thích',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _loadItems(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 90),
                    itemCount: items.length,
                    itemBuilder: (_, index) => ItemCard(
                      item: items[index],
                      onTap: () => _openDetail(items[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MessageState extends StatelessWidget {
  const MessageState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: const Color(0xFF777777)),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
