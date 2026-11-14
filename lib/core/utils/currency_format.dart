import 'package:intl/intl.dart';

class CurrencyFormat {
  static String convertToIdr(dynamic number, int decimalDigit) {
    if (number == null) return 'Rp 0';
    final numVal = number is num ? number : (double.tryParse(number.toString()) ?? 0);
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(numVal);
  }
}

