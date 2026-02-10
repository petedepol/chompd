# SubSnap — Quick Fixes

> Two bugs from dev status review. Both are SharedPreferences persistence.

---

## Fix 1: Budget Resets Every Launch

**Problem:** `BudgetProvider` is a `StateNotifier<double>` with default £100. Budget resets to £100 on every app launch because it's in-memory only.

**Fix:** Persist to SharedPreferences on change, load on init.

### Update `lib/providers/budget_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBudgetKey = 'monthly_budget';
const _kDefaultBudget = 100.0;

class BudgetNotifier extends StateNotifier<double> {
  BudgetNotifier() : super(_kDefaultBudget) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_kBudgetKey) ?? _kDefaultBudget;
  }

  Future<void> setBudget(double budget) async {
    state = budget;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kBudgetKey, budget);
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, double>(
  (ref) => BudgetNotifier(),
);
```

### Update settings screen

Wherever the budget is set (the preset chips + custom entry dialog), call `ref.read(budgetProvider.notifier).setBudget(value)` instead of directly setting state. If it already calls `setBudget()`, no change needed — just make sure the method persists.

---

## Fix 2: Onboarding Shows Every Launch

**Problem:** No "seen" flag persisted. User sees the 4-page onboarding flow every time they open the app.

**Fix:** Set a flag after onboarding completes, check it in the app entry flow.

### Update `lib/app.dart`

Where the splash → onboarding → home flow is managed:

```dart
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingSeenKey = 'onboarding_seen';

// In the app entry flow (wherever AnimatedSwitcher decides what to show):
Future<bool> _hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingSeenKey) ?? false;
}

// Flow becomes:
// 1. Show splash (2s animation)
// 2. Check _hasSeenOnboarding()
//    - false → show onboarding
//    - true → skip straight to home
```

### Update `lib/screens/onboarding/onboarding_screen.dart`

At the end of onboarding (when user taps "Get Started" on the last page):

```dart
Future<void> _completeOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingSeenKey, true);
  
  // Navigate to home (existing logic)
}
```

### Optional: Reset onboarding from settings

Add a row in the settings screen so users can re-trigger onboarding:

```dart
ListTile(
  title: const Text('Replay Onboarding'),
  subtitle: const Text('See the intro screens again'),
  leading: const Icon(Icons.replay_rounded),
  onTap: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingSeenKey, false);
    // Navigate to onboarding or show confirmation
  },
),
```

---

## Dependency Check

Make sure `shared_preferences` is in `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.2.0
```

If it's not there yet, add it and run `flutter pub get`. It's likely already present since it's one of the most common Flutter packages, but worth checking.

---

## Both fixes are < 5 minutes each. Ship it.
