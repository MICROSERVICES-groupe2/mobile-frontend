import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String symbol = 'XAF'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 0,
      locale: 'fr_FR',
    );
    return formatter.format(amount);
  }
}
