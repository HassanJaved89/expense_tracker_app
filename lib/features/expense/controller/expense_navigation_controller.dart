import 'package:flutter/material.dart';

class ExpenseTab {
  const ExpenseTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class ExpenseNavigationController {
  static const tabs = <ExpenseTab>[
    ExpenseTab(label: 'Add Expense', icon: Icons.add_circle_outline),
    ExpenseTab(label: 'Expenses', icon: Icons.list_alt),
    ExpenseTab(label: 'Summary', icon: Icons.insights),
  ];
}
