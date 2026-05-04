import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final hasDecimals = amount % 1 != 0;
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'PKR ',
    decimalDigits: hasDecimals ? 2 : 0,
  );
  return formatter.format(amount);
}

String formatDate(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date);
}
