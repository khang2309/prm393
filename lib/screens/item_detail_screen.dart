import 'package:flutter/material.dart';

import '../database/shopping_database.dart';
import '../models/shopping_item.dart';
import '../utils/formatters.dart';

enum DetailResult { updated, deleted }

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.item});

  final ShoppingItem item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late ShoppingItem _item = widget.item;
  bool _busy = false;
  bool _changed = false;

  Future<void> _toggleStatus() async {
    setState(() => _busy = true);
    final updated = _item.copyWith(
      status: _item.isWishlist
          ? ShoppingItem.purchasedStatus
          : ShoppingItem.wishlistStatus,
    );
    try {
      await ShoppingDatabase.instance.update(updated);
      if (!mounted) return;
      setState(() {
        _item = updated;
        _busy = false;
        _changed = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Marked as ${updated.status}.')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update item: $error')));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Delete “${_item.itemName}” permanently? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ShoppingDatabase.instance.delete(_item.id!);
      if (mounted) Navigator.pop(context, DetailResult.deleted);
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete item: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 44),
                  const SizedBox(height: 10),
                  Text(
                    _item.itemName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.key,
                      label: 'ID',
                      value: '#${_item.id}',
                    ),
                    const Divider(),
                    _DetailRow(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: _item.category,
                    ),
                    const Divider(),
                    _DetailRow(
                      icon: Icons.payments_outlined,
                      label: 'Price',
                      value: formatVnd(_item.price),
                      valueColor: Theme.of(context).colorScheme.primary,
                    ),
                    const Divider(),
                    _DetailRow(
                      icon: Icons.flag_outlined,
                      label: 'Status',
                      value: _item.status,
                      valueColor: _item.isWishlist
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _toggleStatus,
                    icon: const Icon(Icons.sync),
                    label: Text(_item.isWishlist ? 'Purchased' : 'Wishlist'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _busy ? null : _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => Navigator.pop(
                            context,
                            _changed ? DetailResult.updated : null,
                          ),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.w700, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
