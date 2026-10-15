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

  void _load() =>
      setState(() => _items = ShoppingDatabase.instance.getWishlistItems());

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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
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
                      '${items.length} ${items.length == 1 ? 'item' : 'items'} waiting for you',
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: items.length,
                          itemBuilder: (_, index) =>
                              ItemCard(item: items[index]),
                        ),
                      ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: .25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calculate_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Total estimated cost',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      formatVnd(total),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
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
