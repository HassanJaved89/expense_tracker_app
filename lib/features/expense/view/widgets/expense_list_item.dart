import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/expense.dart';
import '../../provider/expense_provider.dart';
import '../../../../core/utils/formatters.dart';
import 'expense_detail_sheet.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense});

  final Expense expense;

  Future<void> _confirmDelete(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete expense?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final provider = dialogContext.read<ExpenseProvider>();
                final messenger = ScaffoldMessenger.of(dialogContext);
                Navigator.of(dialogContext).pop();
                provider.deleteExpense(expense).then((_) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Expense deleted')),
                  );
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => ExpenseDetailSheet(expense: expense),
        );
      },
      onLongPress: () => _confirmDelete(context),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.category,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatDate(expense.dateTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (expense.comment?.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Text(
                        expense.comment!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatCurrency(expense.amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
