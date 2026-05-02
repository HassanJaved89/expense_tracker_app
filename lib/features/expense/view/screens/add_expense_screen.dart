import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/expense_provider.dart';
import '../widgets/expense_category_dropdown.dart';
import '../widgets/expense_input_field.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
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

    try {
      await context.read<ExpenseProvider>().addExpense(amount, _selectedCategory);
      _amountController.clear();
      setState(() => _selectedCategory = 'Food');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding expense: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpenseInputField(
              controller: _amountController,
              label: 'Amount',
              hintText: 'Enter amount',
            ),
            const SizedBox(height: 16),
            ExpenseCategoryDropdown(
              selectedCategory: _selectedCategory,
              onChanged: (category) {
                if (category != null) {
                  setState(() => _selectedCategory = category);
                }
              },
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
                    : const Text('Save Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
