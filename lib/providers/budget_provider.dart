import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBudgetKey = 'monthly_budget';
const _kDefaultBudget = 100.0;

/// User's monthly budget setting.
///
/// Persisted to SharedPreferences so it survives app restarts.
/// Defaults to £100 on first launch.
class BudgetNotifier extends StateNotifier<double> {
  BudgetNotifier() : super(_kDefaultBudget) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_kBudgetKey) ?? _kDefaultBudget;
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
