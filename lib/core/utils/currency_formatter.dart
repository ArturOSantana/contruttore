/// Utilitário para formatação de valores monetários
class CurrencyFormatter {
  /// Formata um valor double para moeda brasileira
  ///
  /// Exemplo:
  /// ```dart
  /// CurrencyFormatter.format(1234.56) // "R$ 1.234,56"
  /// ```
  static String format(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();

    final intPart = absValue.floor();
    final decimalPart = ((absValue - intPart) * 100).round();

    final intString = intPart.toString();
    final formattedInt = _addThousandsSeparator(intString);
    final formattedDecimal = decimalPart.toString().padLeft(2, '0');

    final result = 'R\$ $formattedInt,$formattedDecimal';
    return isNegative ? '-$result' : result;
  }

  /// Formata um valor double para moeda brasileira de forma compacta
  ///
  /// Exemplo:
  /// ```dart
  /// CurrencyFormatter.formatCompact(1234.56) // "R$ 1,2 mil"
  /// CurrencyFormatter.formatCompact(1234567.89) // "R$ 1,2 mi"
  /// ```
  static String formatCompact(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();

    String result;

    if (absValue >= 1000000) {
      final millions = absValue / 1000000;
      result = 'R\$ ${millions.toStringAsFixed(1)} mi';
    } else if (absValue >= 1000) {
      final thousands = absValue / 1000;
      result = 'R\$ ${thousands.toStringAsFixed(1)} mil';
    } else {
      result = format(absValue);
    }

    return isNegative ? '-$result' : result;
  }

  /// Adiciona separador de milhares
  static String _addThousandsSeparator(String value) {
    final buffer = StringBuffer();
    final length = value.length;

    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(value[i]);
    }

    return buffer.toString();
  }
}

// Made with Bob
