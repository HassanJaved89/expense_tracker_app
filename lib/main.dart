import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app/app_theme.dart';
import 'features/expense/provider/expense_provider.dart';
import 'features/expense/view/screens/expense_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpenseProvider(),
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: AppTheme.light(),
        home: const ExpenseHomeScreen(),
      ),
    );
  }
}
