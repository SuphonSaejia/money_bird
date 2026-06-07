import 'package:intl/intl.dart';

/// Formats money amounts in Thai Baht. Money Bird is THB-only for now, but the
/// formatting is locale-aware so grouping/spacing reads naturally in both
/// Thai and English.
class CurrencyFormatter {
  CurrencyFormatter._();

  static const String symbol = '฿';

  /// e.g. `฿1,250` (or `฿1,250.50` when there are satang).
  static String format(double amount, {String locale = 'en'}) {
    final hasFraction = amount.truncateToDouble() != amount;
    final pattern = hasFraction ? '#,##0.00' : '#,##0';
    final f = NumberFormat(pattern, locale);
    final sign = amount < 0 ? '-' : '';
    return '$sign$symbol${f.format(amount.abs())}';
  }

  /// A signed variant used in lists: `+฿1,250` for income, `-฿320` for expense.
  static String formatSigned(double amount,
      {required bool isIncome, String locale = 'en'}) {
    final body = format(amount.abs(), locale: locale);
    return '${isIncome ? '+' : '−'}$body';
  }

  /// Compact form for tight spots / widgets: `฿1.2K`, `฿3.4M`.
  static String compact(double amount, {String locale = 'en'}) {
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '';
    if (abs >= 1000000) {
      return '$sign$symbol${(abs / 1000000).toStringAsFixed(abs >= 10000000 ? 0 : 1)}M';
    }
    if (abs >= 1000) {
      return '$sign$symbol${(abs / 1000).toStringAsFixed(abs >= 10000 ? 0 : 1)}K';
    }
    return format(amount, locale: locale);
  }

  /// Just the grouped number with no symbol, for input fields.
  static String number(double amount, {String locale = 'en'}) {
    final hasFraction = amount.truncateToDouble() != amount;
    return NumberFormat(hasFraction ? '#,##0.00' : '#,##0', locale)
        .format(amount);
  }
}
