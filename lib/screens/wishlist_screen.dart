import 'package:flutter/material.dart';

import '../database/shopping_database.dart';
import '../models/shopping_item.dart';
import '../utils/formatters.dart';
import '../widgets/item_card.dart';
import 'home_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key, required this.refreshToken});

  final int refreshToken;

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<List<ShoppingItem>> _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant WishlistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshToken != oldWidget.refreshToken) _load();
  }

  void _load() {
    final items = ShoppingDatabase.instance.getWishlistItems();
    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<ShoppingItem>>(
        future: _items,
        builder: (context, snapshot) {
          final waiting = snapshot.connectionState != ConnectionState.done;
          final items = snapshot.data ?? const <ShoppingItem>[];
          final total = items.fold<double>(0, (sum, item) => sum + item.price);
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFF7000F5), width: 2)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: .14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.orange,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Wishlist',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${items.length} ${items.length == 1 ? 'item' : 'items'} in wishlist',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: waiting
                    ? const Center(child: CircularProgressIndicator())
                    : snapshot.hasError
                    ? MessageState(
                        icon: Icons.error_outline,
                        title: 'Could not load wishlist',
                        subtitle: '${snapshot.error}',
                        onRetry: _load,
                      )
                    : items.isEmpty
                    ? const MessageState(
                        icon: Icons.favorite_border,
                        title: 'Your wishlist is empty',
                        subtitle: 'Items marked Wishlist will appear here.',
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _load(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                          itemCount: items.length,
                          itemBuilder: (_, index) =>
                              ItemCard(
                                item: items[index],
                                leadingIndex: index + 1,
                              ),
                        ),
                      ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calculate, color: Color(0xFF7000F5), size: 20),
                        SizedBox(width: 8),
                        Text('Total Estimate', style: TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Text('Number of items:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const Spacer(),
                        Text('${items.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Total cost:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const Spacer(),
                        Text(formatVnd(total), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(9),
                      color: const Color(0xFFF3F3F3),
                      child: const Text(
                        '●  This is the estimated total for items you want to buy',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
