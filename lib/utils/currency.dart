/// Currency formatting utilities.
class CurrencyUtils {
  CurrencyUtils._();

  static const Map<String, String> symbols = {
    'GBP': '\u00A3',
    'USD': '\$',
    'EUR': '\u20AC',
    'JPY': '\u00A5',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'PLN': 'z\u0142',
    'CHF': 'CHF',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
  };

  /// Get currency symbol for an ISO 4217 code.
  static String symbol(String code) {
    return symbols[code.toUpperCase()] ?? '$code ';
  }

  /// Format a price with currency symbol.
  static String format(double amount, String currency, {int decimals = 2}) {
    return '${symbol(currency)}${amount.toStringAsFixed(decimals)}';
  }
}
