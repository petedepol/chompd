import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBudgetKey = 'monthly_budget';
const _kDefaultBudget = 100.0;

/// Sensible monthly subscription budget defaults per currency.
/// Marketing-friendly round numbers, not PPP-adjusted.
const _budgetForCurrency = <String, double>{
  'PLN': 300,
  'GBP': 50,
  'USD': 75,
  'EUR': 60,
  'AUD': 100,
  'CAD': 100,
  'SEK': 700,
  'NOK': 700,
  'DKK': 500,
  'CHF': 70,
  'JPY': 10000,
};

/// User's monthly budget setting.
///
/// Persisted to SharedPreferences so it survives app restarts.
/// On first launch, auto-detects a sensible default from the user's currency.
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
      // First launch: pick a sensible default based on detected currency
      final currency = prefs.getString('user_currency') ?? 'USD';
      state = _budgetForCurrency[currency] ?? _kDefaultBudget;
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
