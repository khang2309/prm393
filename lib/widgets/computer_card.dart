import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/computer.dart';

class ComputerCard extends StatelessWidget {
  const ComputerCard({super.key, required this.computer, required this.onTap});

  final Computer computer;
  final VoidCallback onTap;

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      computer.productName,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (computer.isFeatured)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB300),
                        semanticLabel: 'Featured',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.business_outlined,
                    label:
                        'Brand: ${computer.brandName.isEmpty ? '-' : computer.brandName}',
                  ),
                  _InfoChip(
                    icon: Icons.category_outlined,
                    label:
                        'Category: ${computer.categoryName.isEmpty ? '-' : computer.categoryName}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DetailRow(label: 'CPU', value: computer.cpu),
              _DetailRow(label: 'RAM', value: '${computer.ram} GB'),
              _DetailRow(label: 'Storage', value: '${computer.storage} GB'),
              _DetailRow(
                label: 'Price',
                value: _currency.format(computer.price),
                valueColor: colorScheme.primary,
              ),
              _DetailRow(label: 'Stock', value: '${computer.stock}'),
              _DetailRow(
                label: 'Sold Quantity',
                value: '${computer.soldQuantity}',
              ),
              _DetailRow(
                label: 'Featured',
                value: computer.isFeatured ? 'Yes' : 'No',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 64,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: colorScheme.onSecondaryContainer),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: valueColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
