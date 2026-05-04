import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/expense_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../widgets/summary_tile.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final categoryTotals = provider.categoryTotals;

          return Column(
            children: [
              Container(
                height: 4,
                color: Theme.of(context).colorScheme.primary,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Text(
                      'Totals',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SummaryTile(
                      label: "Today's Total",
                      value: formatCurrency(provider.todaysTotal),
                    ),
                    const SizedBox(height: 16),
                    SummaryTile(
                      label: 'Weekly Total',
                      value: formatCurrency(provider.weeklyTotal),
                    ),
                    const SizedBox(height: 16),
                    SummaryTile(
                      label: 'Monthly Total',
                      value: formatCurrency(provider.monthlyTotal),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Category Breakdown',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (categoryTotals.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48.0),
                          child: Text(
                            'No data available',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ...categoryTotals.entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: SummaryTile(
                              label: entry.key,
                              value: formatCurrency(entry.value),
                            ),
                          )),
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
