import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBudgetKey = 'monthly_budget';
const _kDefaultBudget = 40.0;

/// Country-based default budgets.
/// Uses country code from device locale to set a sensible first-launch default
/// that reflects local subscription spending patterns.
const _countryToDefaultBudget = <String, double>{
  'US': 50,
  'GB': 35,
  'DE': 40,
  'AT': 40,
  'CH': 40,
  'FR': 35,
  'ES': 35,
  'IT': 35,
  'PL': 100,
  'AU': 45,
  'CA': 45,
  'JP': 3000,
};

/// Fallback: currency-based defaults for countries not in the map above.
/// Marketing-friendly round numbers.
const _budgetForCurrency = <String, double>{
  'PLN': 100,
  'GBP': 35,
  'USD': 50,
  'EUR': 40,
  'AUD': 45,
  'CAD': 45,
  'SEK': 400,
  'NOK': 400,
  'DKK': 300,
  'CHF': 40,
  'JPY': 3000,
};

/// Detect the country code from device locale, matching the approach
/// used in currency_provider.dart.
String? _detectCountryCode() {
  try {
    final platformLocale = PlatformDispatcher.instance.locale;
    final region = platformLocale.countryCode?.toUpperCase();
    if (region != null && region.isNotEmpty) return region;

    // Fallback: parse Platform.localeName (e.g. "en_GB", "pl_PL")
    final locale = Platform.localeName;
    final parts = locale.split(RegExp('[_-]'));
    if (parts.length >= 2) return parts[1].toUpperCase();
    return null;
  } catch (_) {
    return null;
  }
}

/// User's monthly budget setting.
///
/// Persisted to SharedPreferences so it survives app restarts.
/// On first launch, auto-detects a sensible default from the user's country,
/// falling back to currency-based defaults, then a generic $40 default.
class BudgetNotifier extends StateNotifier<double> {
  BudgetNotifier() : super(_kDefaultBudget) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_kBudgetKey);
    if (saved != null) {
      state = saved;
    } else {
      // First launch: try country → then currency → then global default
      final country = _detectCountryCode();
      final countryBudget =
          country != null ? _countryToDefaultBudget[country] : null;

      if (countryBudget != null) {
        state = countryBudget;
      } else {
        final currency = prefs.getString('user_currency') ?? 'USD';
        state = _budgetForCurrency[currency] ?? _kDefaultBudget;
      }
    }
  }

  Future<void> setBudget(double value) async {
    if (value > 0) {
      state = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kBudgetKey, value);
    }
  }
}

/// Monthly budget provider.
final budgetProvider = StateNotifierProvider<BudgetNotifier, double>(
  (ref) => BudgetNotifier(),
);
