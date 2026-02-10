import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kCurrencyKey = 'user_currency';
const _kDefaultCurrency = 'GBP';

/// User's preferred display currency.
///
/// Persisted to SharedPreferences. Defaults to GBP.
/// This controls the symbol shown throughout the app (spending ring,
/// cards, milestones, etc.) — it does NOT do conversion.
class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super(_kDefaultCurrency) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_kCurrencyKey) ?? _kDefaultCurrency;
  }

  Future<void> setCurrency(String code) async {
    state = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrencyKey, code);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>(
  (ref) => CurrencyNotifier(),
);

/// Supported currencies for the picker.
const supportedCurrencies = [
  {'code': 'GBP', 'symbol': '\u00A3', 'name': 'British Pound'},
  {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
  {'code': 'EUR', 'symbol': '\u20AC', 'name': 'Euro'},
  {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
  {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
  {'code': 'JPY', 'symbol': '\u00A5', 'name': 'Japanese Yen'},
  {'code': 'PLN', 'symbol': 'z\u0142', 'name': 'Polish Z\u0142oty'},
  {'code': 'CHF', 'symbol': 'CHF', 'name': 'Swiss Franc'},
  {'code': 'SEK', 'symbol': 'kr', 'name': 'Swedish Krona'},
  {'code': 'NOK', 'symbol': 'kr', 'name': 'Norwegian Krone'},
  {'code': 'DKK', 'symbol': 'kr', 'name': 'Danish Krone'},
];
