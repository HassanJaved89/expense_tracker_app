import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../provider/expense_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../screens/category_expenses_screen.dart';
import '../widgets/category_card.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  String selectedTimeRange = 'today';
  DateTime selectedDate = DateTime.now();

  final List<String> timeRanges = ['today', 'weekly', 'monthly'];

  void _changeTimeRange(String range) {
    setState(() {
      selectedTimeRange = range;
      selectedDate = DateTime.now();
    });
  }

  void _navigateDate(bool isNext) {
    setState(() {
      if (selectedTimeRange == 'weekly') {
        final startOfWeek = context.read<ExpenseProvider>().getStartOfWeek(selectedDate);
        final nextWeek = isNext
            ? startOfWeek.add(const Duration(days: 7))
            : startOfWeek.subtract(const Duration(days: 7));
        final now = DateTime.now();
        if (!nextWeek.isAfter(now)) {
          selectedDate = nextWeek;
        }
      } else if (selectedTimeRange == 'monthly') {
        final nextMonth = isNext
            ? DateTime(selectedDate.year, selectedDate.month + 1, 1)
            : DateTime(selectedDate.year, selectedDate.month - 1, 1);
        final now = DateTime.now();
        final currentMonthStart = DateTime(now.year, now.month, 1);
        if (!nextMonth.isAfter(currentMonthStart)) {
          selectedDate = nextMonth;
        }
      }

      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
      if (selectedDate.isBefore(sixMonthsAgo)) {
        selectedDate = sixMonthsAgo;
      }
    });
  }

  String _getRangeDisplay(ExpenseProvider provider) {
    if (selectedTimeRange == 'today') {
      return formatDate(selectedDate);
    } else if (selectedTimeRange == 'weekly') {
      final startOfWeek = provider.getStartOfWeek(selectedDate);
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final startLabel = formatDate(startOfWeek).replaceAll(', ${startOfWeek.year}', '');
      final endLabel = formatDate(endOfWeek);
      return '$startLabel - $endLabel';
    } else {
      return DateFormat('MMMM yyyy').format(selectedDate);
    }
  }

  String _rangeLabel() {
    if (selectedTimeRange == 'today') return 'Today';
    if (selectedTimeRange == 'weekly') return 'This Week';
    return 'This Month';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final summaries = provider.getCategoryTotals(selectedTimeRange, selectedDate);
          final overallTotal = provider.getTotalForExpenses(provider.getExpensesForRange(selectedTimeRange, selectedDate));

          return Column(
            children: [
              Container(
                height: 4,
                color: Theme.of(context).colorScheme.primary,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SegmentedButton<String>(
                      segments: timeRanges
                          .map((range) => ButtonSegment(
                                value: range,
                                label: Text(range.capitalize()),
                              ))
                          .toList(),
                      selected: {selectedTimeRange},
                      onSelectionChanged: (Set<String> newSelection) {
                        _changeTimeRange(newSelection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selectedTimeRange != 'today')
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => _navigateDate(false),
                          ),
                        Expanded(
                          child: Text(
                            _getRangeDisplay(provider),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        if (selectedTimeRange != 'today')
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => _navigateDate(true),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Total ${_rangeLabel()}: ${formatCurrency(overallTotal)}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: summaries.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wallet_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary.withAlpha((0.75 * 255).round()),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No expenses for this period',
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: summaries.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final summary = summaries[index];
                          return CategoryCard(
                            category: summary.category,
                            amountLabel: formatCurrency(summary.totalAmount),
                            itemCount: summary.itemCount,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CategoryExpensesScreen(
                                    category: summary.category,
                                    timeRange: selectedTimeRange,
                                    selectedDate: selectedDate,
                                  ),
                                ),
                              );
                            },
                          );
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
