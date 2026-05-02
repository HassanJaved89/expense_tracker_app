import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/expense_provider.dart';
import '../widgets/expense_list_item.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final expenses = provider.allExpenses;

          if (expenses.isEmpty) {
            return const Center(
              child: Text('No expenses yet. Add some from the Add Expense tab!'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: expenses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return ExpenseListItem(expense: expenses[index]);
            },
          );
        },
      ),
    );
  }
}
