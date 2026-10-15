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
    final message = result == DetailResult.deleted
        ? 'Item deleted successfully.'
        : 'Item status updated successfully.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Semantics(
            label: 'Favorite Shopping Items banner',
            image: true,
            child: SizedBox(
              width: double.infinity,
              height: 155,
              child: Image.asset('assets/images/banner.png', fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Favorite Shopping Items',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: _loadItems,
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
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
                    title: 'Your list is empty',
                    subtitle: 'Tap + to add your first favorite shopping item.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _loadItems(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
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
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
