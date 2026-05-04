import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/expense_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../widgets/expense_list_item.dart';

class CategoryExpensesScreen extends StatelessWidget {
  const CategoryExpensesScreen({
    super.key,
    required this.category,
    required this.timeRange,
    required this.selectedDate,
  });

  final String category;
  final String timeRange;
  final DateTime selectedDate;

  String _rangeLabel() {
    if (timeRange == 'today') {
      return 'Today';
    }
    if (timeRange == 'weekly') {
      return 'Week';
    }
    return 'Month';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category • ${_rangeLabel()}'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final expenses = provider.getExpensesForCategory(category, timeRange, selectedDate);
          final total = provider.getTotalForExpenses(expenses);

          return Column(
            children: [
              Container(
                height: 4,
                color: Theme.of(context).colorScheme.primary,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(total),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${expenses.length} item${expenses.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary.withAlpha((0.7 * 255).round()),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No expenses in this category',
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: expenses.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return ExpenseTile(expense: expense);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
