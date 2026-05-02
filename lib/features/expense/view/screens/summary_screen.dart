import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/expense_provider.dart';
import '../widgets/summary_tile.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ExpenseProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                SummaryTile(
                  label: "Today's Total",
                  value: '\$${provider.todaysTotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 16),
                SummaryTile(
                  label: 'Weekly Total',
                  value: '\$${provider.weeklyTotal.toStringAsFixed(2)}',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
