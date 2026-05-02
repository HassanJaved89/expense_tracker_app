import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final DateTime dateTime;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.dateTime,
  });

  factory Expense.create({
    required double amount,
    required String category,
  }) {
    return Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      dateTime: DateTime.now(),
    );
  }
}
