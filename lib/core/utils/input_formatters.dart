import 'package:flutter/services.dart';

/// Allows digits and at most ONE decimal point. Pair with
/// `FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))` (which only filters
/// per-character and would otherwise let "1.2.3" through and break parsing).
class SingleDecimalFormatter extends TextInputFormatter {
  const SingleDecimalFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if ('.'.allMatches(newValue.text).length > 1) return oldValue;
    return newValue;
  }
}

/// Convenience list for money input fields: digits + a single decimal point.
List<TextInputFormatter> amountFormatters() => [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      const SingleDecimalFormatter(),
    ];

/// Whole-number input (e.g. age): digits only, no decimal point.
List<TextInputFormatter> integerFormatters() => [
      FilteringTextInputFormatter.digitsOnly,
    ];
