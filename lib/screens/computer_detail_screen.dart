import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/computer_store_service.dart';
import '../models/computer.dart';
import 'computer_form_screen.dart';

enum ComputerDetailResult { updated, deleted }

class ComputerDetailScreen extends StatefulWidget {
  const ComputerDetailScreen({super.key, required this.computerId});

  final int computerId;

  @override
  State<ComputerDetailScreen> createState() => _ComputerDetailScreenState();
}

class _ComputerDetailScreenState extends State<ComputerDetailScreen> {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
  );

  Computer? _computer;
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _wasUpdated = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadComputer();
  }

  Future<void> _loadComputer() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final computer = await ComputerStoreService.instance.getComputerById(
        widget.computerId,
      );
      if (!mounted) return;
      setState(() {
        _computer = computer;
        _isLoading = false;
        if (computer == null) {
          _loadError = 'Computer not found.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Unable to load computer details.';
      });
    }
  }

  void _close() {
    Navigator.of(context)
        .pop(_wasUpdated ? ComputerDetailResult.updated : null);
  }

  Future<void> _editComputer() async {
    final computer = _computer;
    if (computer == null || _isDeleting) return;

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ComputerFormScreen(computer: computer),
      ),
    );
    if (changed == true && mounted) {
      _wasUpdated = true;
      await _loadComputer();
    }
  }

  Future<void> _deleteComputer() async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await ComputerStoreService.instance.deleteComputer(widget.computerId);
      if (!mounted) return;
      Navigator.of(context).pop(ComputerDetailResult.deleted);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<ComputerDetailResult>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
          title: const Text('Computer Detail'),
          actions: [
            IconButton(
              onPressed: _computer == null || _isDeleting
                  ? null
                  : _editComputer,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: _computer == null || _isDeleting
                  ? null
                  : _deleteComputer,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError case final error?) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 44),
              const SizedBox(height: 12),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadComputer,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final computer = _computer;
    if (computer == null) return const SizedBox.shrink();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Icon(
                        computer.isFeatured
                            ? Icons.star_rounded
                            : Icons.computer,
                        color: computer.isFeatured
                            ? const Color(0xFFFFB300)
                            : null,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            computer.productName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${computer.brandName.isEmpty ? '-' : computer.brandName} · '
                            '${computer.categoryName.isEmpty ? '-' : computer.categoryName}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _DetailSection(
              title: 'Product Information',
              children: [
                _DetailLine(label: 'Product Name', value: computer.productName),
                _DetailLine(
                  label: 'Brand',
                  value: computer.brandName.isEmpty ? '-' : computer.brandName,
                ),
                _DetailLine(
                  label: 'Category',
                  value: computer.categoryName.isEmpty
                      ? '-'
                      : computer.categoryName,
                ),
                _DetailLine(label: 'CPU', value: computer.cpu),
                _DetailLine(label: 'RAM', value: '${computer.ram} GB'),
                _DetailLine(label: 'Storage', value: '${computer.storage} GB'),
                _DetailLine(
                  label: 'Price',
                  value: _currency.format(computer.price),
                ),
                _DetailLine(label: 'Stock', value: '${computer.stock}'),
                _DetailLine(
                  label: 'Sold Quantity',
                  value: '${computer.soldQuantity}',
                ),
                _DetailLine(
                  label: 'Featured',
                  value: computer.isFeatured ? 'Yes' : 'No',
                  trailing: computer.isFeatured
                      ? const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB300),
                          size: 20,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DetailSection(
              title: 'Business Calculations',
              children: [
                _DetailLine(
                  label: 'Revenue',
                  value: _currency.format(computer.revenue),
                ),
                _DetailLine(
                  label: 'Inventory Value',
                  value: _currency.format(computer.inventoryValue),
                ),
                _DetailLine(
                  label: 'Total Units',
                  value: '${computer.totalUnits}',
                ),
              ],
            ),
          ],
        ),
        if (_isDeleting)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 126,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (trailing case final trailing?) ...[
            const SizedBox(width: 6),
            trailing,
          ],
        ],
      ),
    );
  }
}
