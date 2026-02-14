import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/sync_service.dart';

const _kCurrencyKey = 'user_currency';
const _kDefaultCurrency = 'USD';

/// Country code → currency mapping for locale auto-detection.
const _countryToCurrency = <String, String>{
  // Direct 1:1 mappings
  'GB': 'GBP',
  'US': 'USD',
  'CA': 'CAD',
  'AU': 'AUD',
  'JP': 'JPY',
  'PL': 'PLN',
  'CH': 'CHF',
  'SE': 'SEK',
  'NO': 'NOK',
  'DK': 'DKK',
  // Eurozone countries
  'DE': 'EUR',
  'FR': 'EUR',
  'ES': 'EUR',
  'IT': 'EUR',
  'NL': 'EUR',
  'BE': 'EUR',
  'AT': 'EUR',
  'FI': 'EUR',
  'IE': 'EUR',
  'PT': 'EUR',
  'GR': 'EUR',
  'LT': 'EUR',
  'LV': 'EUR',
  'EE': 'EUR',
  'SK': 'EUR',
  'SI': 'EUR',
  'CY': 'EUR',
  'MT': 'EUR',
  'LU': 'EUR',
  'HR': 'EUR',
};

/// Detect currency from device locale country code.
/// Falls back to USD (most global) if unknown.
String _detectCurrencyFromLocale() {
  try {
    final locale = Platform.localeName; // e.g. "en_GB", "pl_PL"
    final parts = locale.split(RegExp('[_-]'));
    final country =
        parts.length >= 2 ? parts[1].toUpperCase() : parts[0].toUpperCase();

    final detected = _countryToCurrency[country] ?? _kDefaultCurrency;
    debugPrint('[CurrencyProvider] Locale: $locale → country: $country → $detected');
    return detected;
  } catch (_) {
    return _kDefaultCurrency;
  }
}

/// User's preferred display currency.
///
/// On first launch, auto-detects from device locale.
/// Persisted to SharedPreferences.
/// This controls the symbol shown throughout the app (spending ring,
/// cards, milestones, etc.) — it does NOT do conversion.
class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super(_kDefaultCurrency) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kCurrencyKey);
    if (saved != null) {
      state = saved;
    } else {
      // First launch: detect from locale and persist
      final detected = _detectCurrencyFromLocale();
      state = detected;
      await prefs.setString(_kCurrencyKey, detected);
    }
  }

  Future<void> setCurrency(String code) async {
    state = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrencyKey, code);
    SyncService.instance.syncProfile(currency: code);
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
