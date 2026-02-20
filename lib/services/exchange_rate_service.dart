import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Exchange rate service with weekly-refreshed rates from the Frankfurter API.
///
/// Rates are GBP-based ("units per 1 GBP"). On init, cached rates are loaded
/// from SharedPreferences (instant). If stale (>7 days), a background fetch
/// pulls fresh rates from api.frankfurter.dev. Hardcoded defaults are the
/// ultimate fallback if both cache and API fail.
class ExchangeRateService {
  ExchangeRateService._();
  static final instance = ExchangeRateService._();

  static const _kFxRatesKey = 'fx_rates';
  static const _kFxLastUpdatedKey = 'fx_last_updated';
  static const _staleDays = 7;
  static const _apiUrl = 'https://api.frankfurter.dev/v1/latest?base=GBP';

  /// Hardcoded fallback rates (units per 1 GBP).
  static const Map<String, double> _fallbackRates = {
    'GBP': 1.0,
    'USD': 1.27,
    'EUR': 1.17,
    'CAD': 1.72,
    'AUD': 1.95,
    'JPY': 190.0,
    'PLN': 5.10,
    'CHF': 1.12,
    'SEK': 13.20,
    'NOK': 13.50,
    'DKK': 8.75,
  };

  /// Live/cached rates — starts as fallback, overwritten by cache or API.
  Map<String, double> _ratesFromGBP = Map.of(_fallbackRates);

  bool _initialised = false;

  /// Initialise: load cached rates, then fetch from API if stale.
  ///
  /// Call once at app startup (awaits only the fast cache read).
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    final prefs = await SharedPreferences.getInstance();

    // Load cached rates (fast)
    final cachedJson = prefs.getString(_kFxRatesKey);
    if (cachedJson != null) {
      try {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        _ratesFromGBP = decoded.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        );
        // Ensure GBP is always present
        _ratesFromGBP['GBP'] = 1.0;
      } catch (_) {
        // Silently ignored
      }
    }

    // Check staleness
    final lastUpdated = prefs.getString(_kFxLastUpdatedKey);
    final isStale = lastUpdated == null ||
        DateTime.now()
                .difference(DateTime.tryParse(lastUpdated) ?? DateTime(2000))
                .inDays >=
            _staleDays;

    if (isStale) {
      // Fire-and-forget — don't block app startup
      _fetchFromApi();
    }
  }

  /// Fetch fresh rates from Frankfurter API and persist.
  Future<void> _fetchFromApi() async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>;

      final parsed = rates.map(
        (k, v) => MapEntry(k.toUpperCase(), (v as num).toDouble()),
      );
      parsed['GBP'] = 1.0;

      _ratesFromGBP = parsed;

      // Persist
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kFxRatesKey, jsonEncode(parsed));
      await prefs.setString(
        _kFxLastUpdatedKey,
        DateTime.now().toIso8601String(),
      );

    } catch (_) {
      // Silently ignored
    }
  }

  /// Convert [amount] from [from] currency to [to] currency.
  ///
  /// Returns the amount unchanged if currencies match.
  /// Falls back to 1.0 for unknown currency codes.
  double convert(double amount, String from, String to) {
    if (from == to) return amount;
    final fromRate = _ratesFromGBP[from.toUpperCase()] ?? 1.0;
    final toRate = _ratesFromGBP[to.toUpperCase()] ?? 1.0;
    return amount / fromRate * toRate;
  }
}
