import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../model/expense.dart';

class CategorySummary {
  final String category;
  final double totalAmount;
  final int itemCount;

  const CategorySummary({
    required this.category,
    required this.totalAmount,
    required this.itemCount,
  });
}

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

  List<Expense> get recentExpenses {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return _expenseBox.values
        .where((expense) => !expense.dateTime.isBefore(sixMonthsAgo))
        .toList();
  }

  List<Expense> get todaysExpenses {
    final today = DateTime.now();
    return getExpensesForDay(today);
  }

  // Helper methods for local date operations
  DateTime toLocalDateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  bool isSameDayLocal(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime getWeekStartLocal(DateTime date) {
    // Assuming Monday is start of week (weekday = 1)
    final dayOfWeek = date.weekday;
    final daysToSubtract = dayOfWeek - 1; // Monday = 1, so subtract 0 for Monday
    return toLocalDateOnly(date.subtract(Duration(days: daysToSubtract)));
  }

  List<Expense> getExpensesForRange(String range, DateTime date) {
    switch (range) {
      case 'today':
        return getExpensesForDay(date);
      case 'weekly':
        return getExpensesForWeek(date);
      case 'monthly':
        return getExpensesForMonth(date);
      default:
        return recentExpenses;
    }
  }

  List<CategorySummary> getCategoryTotals(String range, DateTime date) {
    final Map<String, CategorySummary> totals = {};
    final expenses = getExpensesForRange(range, date);

    for (final expense in expenses) {
      final existing = totals[expense.category];
      if (existing != null) {
        totals[expense.category] = CategorySummary(
          category: expense.category,
          totalAmount: existing.totalAmount + expense.amount,
          itemCount: existing.itemCount + 1,
        );
      } else {
        totals[expense.category] = CategorySummary(
          category: expense.category,
          totalAmount: expense.amount,
          itemCount: 1,
        );
      }
    }

    final summary = totals.values.toList();
    summary.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return summary;
  }

  List<Expense> getExpensesForCategory(String category, String range, DateTime date) {
    final expenses = getExpensesForRange(range, date);
    if (category == 'All') return expenses;
    return expenses.where((expense) => expense.category == category).toList();
  }

  double get todaysTotal {
    return todaysExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get weeklyTotal {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return recentExpenses
        .where((expense) => expense.dateTime.isAfter(weekAgo))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get monthlyTotal {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return recentExpenses
        .where((expense) => expense.dateTime.isAfter(startOfMonth))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final expense in recentExpenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<Expense> getExpensesByTimeRange(String range) {
    final now = DateTime.now();
    DateTime startDate;

    switch (range) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'monthly':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        return recentExpenses;
    }

    return recentExpenses.where((expense) => expense.dateTime.isAfter(startDate)).toList();
  }

  List<Expense> getExpensesByCategory(String category) {
    if (category == 'All') return recentExpenses;
    return recentExpenses.where((expense) => expense.category == category).toList();
  }

  List<Expense> getExpensesByTimeAndCategory(String range, String category) {
    final timeFiltered = getExpensesByTimeRange(range);
    if (category == 'All') return timeFiltered;
    return timeFiltered.where((expense) => expense.category == category).toList();
  }

  DateTime getStartOfWeek(DateTime date) {
    final dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  List<Expense> getExpensesForDay(DateTime date) {
    final targetDate = toLocalDateOnly(date);
    return recentExpenses.where((expense) {
      final expenseDate = toLocalDateOnly(expense.dateTime);
      return isSameDayLocal(expenseDate, targetDate);
    }).toList();
  }

  List<Expense> getExpensesForWeek(DateTime date) {
    final startOfWeek = getWeekStartLocal(date);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return recentExpenses.where((expense) {
      final expenseDate = toLocalDateOnly(expense.dateTime);
      return (isSameDayLocal(expenseDate, startOfWeek) || expenseDate.isAfter(startOfWeek)) &&
             expenseDate.isBefore(endOfWeek);
    }).toList();
  }

  List<Expense> getExpensesForMonth(DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 1);
    return recentExpenses.where((expense) {
      final expenseDate = toLocalDateOnly(expense.dateTime);
      return (isSameDayLocal(expenseDate, startOfMonth) || expenseDate.isAfter(startOfMonth)) &&
             expenseDate.isBefore(endOfMonth);
    }).toList();
  }

  double getTotalForExpenses(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<void> addExpense(double amount, String category, [String? comment]) async {
    final expense = Expense.create(amount: amount, category: category, comment: comment);
    await _expenseBox.add(expense);
    notifyListeners();
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    final key = _expenseBox.keys.cast<dynamic>().firstWhere(
      (expenseKey) => _expenseBox.get(expenseKey)?.id == updatedExpense.id,
      orElse: () => null,
    );
    if (key != null) {
      await _expenseBox.put(key, updatedExpense);
      notifyListeners();
    }
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