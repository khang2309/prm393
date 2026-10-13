import 'package:flutter/material.dart';

import '../widgets/responsive_grid.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    final horizontalPadding = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 16),
              _Header(),
              SizedBox(height: 16),
              _SummarySection(),
              SizedBox(height: 24),
              ResponsiveProductGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerFontSize = (screenWidth * 0.06).clamp(20, 32).toDouble();

    return Text(
      'Dashboard',
      style: TextStyle(
        fontSize: headerFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        final cards = [
          const SummaryCard(
            title: 'Revenue',
            value: '\$12,300',
            color: Colors.blue,
          ),
          const SummaryCard(
            title: 'Orders',
            value: '320',
            color: Colors.green,
          ),
          const SummaryCard(
            title: 'Customers',
            value: '89',
            color: Colors.purple,
          ),
        ];

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final card in cards)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: card,
                ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
              const SizedBox(width: 12),
              Expanded(child: cards[2]),
            ],
          );
        }
      },
    );
  }
}
