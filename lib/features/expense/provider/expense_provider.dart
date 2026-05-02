import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  late Box<Expense> _expenseBox;

  ExpenseProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    _expenseBox = await Hive.openBox<Expense>('expenses');
    notifyListeners();
  }

  List<Expense> get allExpenses => _expenseBox.values.toList();

  List<Expense> get todaysExpenses {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _expenseBox.values.where((expense) {
      return expense.dateTime.isAfter(startOfDay) &&
             expense.dateTime.isBefore(endOfDay);
    }).toList();
  }

  double get todaysTotal {
    return todaysExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get weeklyTotal {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return _expenseBox.values
        .where((expense) => expense.dateTime.isAfter(weekAgo))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<void> addExpense(double amount, String category) async {
    final expense = Expense.create(amount: amount, category: category);
    await _expenseBox.add(expense);
    notifyListeners();
  }

  Future<void> deleteExpense(Expense expense) async {
    await expense.delete();
    notifyListeners();
  }

  @override
  void dispose() {
    _expenseBox.close();
    super.dispose();
  }
}