import 'package:flutter/material.dart';

import '../models/shopping_item.dart';
import '../utils/formatters.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.leadingIndex,
  });

  final ShoppingItem item;
  final VoidCallback? onTap;
  final int? leadingIndex;

  @override
  Widget build(BuildContext context) {
    final color = item.isWishlist ? Colors.orange : Colors.green;
    final categoryIcon = switch (item.category) {
      'Fashion' => Icons.checkroom_outlined,
      'Electronics' => Icons.smartphone_outlined,
      'Home' => Icons.chair_outlined,
      'Beauty' => Icons.spa_outlined,
      'Sports' => Icons.sports_basketball_outlined,
      'Books' => Icons.menu_book_outlined,
      _ => Icons.shopping_bag_outlined,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              if (leadingIndex != null) ...[
                CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.orange,
                  child: Text(
                    '$leadingIndex',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  categoryIcon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.category,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatVnd(item.price),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
