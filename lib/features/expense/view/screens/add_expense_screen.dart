import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../model/expense.dart';
import '../../provider/expense_provider.dart';
import '../widgets/expense_input_field.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  static const _categories = ['Food', 'Travel', 'Bills', 'Other'];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  String _selectedCategory = _categories.first;
  bool _isLoading = false;
  late final bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.expense != null;
    if (_isEditMode) {
      final expense = widget.expense!;
      _amountController.text = expense.amount.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+?$'), '');
      _selectedCategory = _categories.contains(expense.category) ? expense.category : _categories.first;
      _commentController.text = expense.comment ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final comment = _commentController.text.trim().isEmpty ? null : _commentController.text.trim();

    try {
      if (_isEditMode) {
        final existingExpense = widget.expense!;
        final updatedExpense = Expense(
          id: existingExpense.id,
          amount: amount,
          category: _selectedCategory,
          dateTime: existingExpense.dateTime,
          comment: comment,
        );
        await context.read<ExpenseProvider>().updateExpense(updatedExpense);
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Expense updated')),
        );
        Navigator.of(context).pop();
        return;
      }

      await context.read<ExpenseProvider>().addExpense(amount, _selectedCategory, comment);
      if (!mounted) return;
      _amountController.clear();
      _commentController.clear();
      setState(() => _selectedCategory = _categories.first);
      messenger.showSnackBar(
        const SnackBar(content: Text('Expense added')),
      );
      _amountFocusNode.requestFocus();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error saving expense: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpenseInputField(
              controller: _amountController,
              focusNode: _amountFocusNode,
              autoFocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              label: 'Amount',
              hintText: 'Enter amount',
            ),
            const SizedBox(height: 16),
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: _categories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                hintText: 'Add a note about this expense',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const Spacer(),
            FilledButton(
              onPressed: _isLoading ? null : _saveExpense,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? 'Update Expense' : 'Save Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
