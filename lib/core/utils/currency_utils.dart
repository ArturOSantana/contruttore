import 'package:intl/intl.dart';

class CurrencyUtils {
  static final _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static String format(double value) {
    return _formatter.format(value);
  }

  static double parse(String value) {
    // Remove R$, espaços e pontos de milhar
    final cleanValue = value
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(cleanValue) ?? 0.0;
  }
}

// Made with Bob
