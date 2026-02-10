# SubSnap — Annual Cost Projection Build Spec

> Quick win. Most of the pieces exist. This is wiring + UI polish.

---

## What It Does

Shows yearly total alongside monthly. User taps the spending ring to toggle:

- **Monthly view (default):** "£95.47/mo" — what you pay this month
- **Yearly view:** "£1,145.64/yr" — the wake-up call

The yearly number is the single most effective trigger for action in subscription trackers. Monthly costs feel manageable. Yearly costs make people cancel things.

---

## What Already Exists

- `SpendingRing` widget — animated circular progress, accepts budget param
- `BudgetProvider` — configurable monthly budget (now persisted with SharedPreferences fix)
- `SubscriptionsProvider` — full list with price, cycle, isActive
- `Subscription.monthlyEquivalent` — computed helper that normalises any cycle to monthly
- Spending ring already has "tap to toggle monthly/yearly" noted as ready

---

## Build Steps

### Step 1: Add yearly helpers to Subscription model

In `lib/models/subscription.dart`, add:

```dart
/// Annual cost regardless of billing cycle
double get yearlyEquivalent {
  return switch (cycle) {
    BillingCycle.weekly => price * 52,
    BillingCycle.monthly => price * 12,
    BillingCycle.quarterly => price * 4,
    BillingCycle.yearly => price,
  };
}
```

This should sit alongside the existing `monthlyEquivalent` getter.

### Step 2: Add totals to SubscriptionsProvider

In `lib/providers/subscriptions_provider.dart`, add computed getters (or create a separate provider if the existing one is a StateNotifier):

```dart
/// Total monthly spend across all active subscriptions
double get totalMonthly {
  return state
      .where((s) => s.isActive)
      .fold(0.0, (sum, s) => sum + s.monthlyEquivalent);
}

/// Total yearly spend across all active subscriptions
double get totalYearly {
  return state
      .where((s) => s.isActive)
      .fold(0.0, (sum, s) => sum + s.yearlyEquivalent);
}
```

If these already exist as methods in the provider, skip this step. If the provider doesn't expose them directly, create a simple derived provider:

```dart
final totalMonthlyProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs
      .where((s) => s.isActive)
      .fold(0.0, (sum, s) => sum + s.monthlyEquivalent);
});

final totalYearlyProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs
      .where((s) => s.isActive)
      .fold(0.0, (sum, s) => sum + s.yearlyEquivalent);
});
```

### Step 3: Add toggle state

Create a simple toggle provider for the view mode:

```dart
// lib/providers/spend_view_provider.dart

enum SpendView { monthly, yearly }

final spendViewProvider = StateProvider<SpendView>(
  (ref) => SpendView.monthly,
);
```

### Step 4: Update SpendingRing widget

In `lib/widgets/spending_ring.dart`:

**a) Accept both values:**

```dart
class SpendingRing extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(spendViewProvider);
    final totalMonthly = ref.watch(totalMonthlyProvider);
    final totalYearly = ref.watch(totalYearlyProvider);
    final budget = ref.watch(budgetProvider);

    final isYearly = view == SpendView.yearly;
    final displayAmount = isYearly ? totalYearly : totalMonthly;
    final displayBudget = isYearly ? budget * 12 : budget;
    final displayLabel = isYearly ? '/yr' : '/mo';
    final progress = displayBudget > 0
        ? (displayAmount / displayBudget).clamp(0.0, 1.5)
        : 0.0;

    // ... rest of ring rendering using displayAmount, displayBudget, progress
  }
}
```

**b) Tap to toggle:**

```dart
GestureDetector(
  onTap: () {
    final current = ref.read(spendViewProvider);
    ref.read(spendViewProvider.notifier).state =
        current == SpendView.monthly
            ? SpendView.yearly
            : SpendView.monthly;

    HapticService.instance.selectionClick();
  },
  child: // ... the ring
)
```

**c) Animate the number change:**

Wrap the amount text in a `TweenAnimationBuilder<double>`:

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: displayAmount, end: displayAmount),
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeOutCubic,
  builder: (context, value, child) {
    return Text(
      '£${value.toStringAsFixed(2)}',
      style: const TextStyle(
        fontFamily: 'SpaceMono',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  },
)
```

**Note:** To make `TweenAnimationBuilder` animate properly on toggle, you need to track the previous value. A cleaner approach:

```dart
// Use an AnimatedSwitcher with a key change
AnimatedSwitcher(
  duration: const Duration(milliseconds: 400),
  transitionBuilder: (child, animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  },
  child: Text(
    '£${displayAmount.toStringAsFixed(2)}',
    key: ValueKey(isYearly), // triggers animation on toggle
    style: // ...
  ),
)
```

**d) Label + hint:**

Below the amount, show the period label and a toggle hint:

```dart
Column(
  children: [
    // Amount (animated)
    _buildAmountText(displayAmount, isYearly),

    const SizedBox(height: 2),

    // Period label
    Text(
      isYearly ? 'per year' : 'per month',
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textMid,
      ),
    ),

    const SizedBox(height: 4),

    // Toggle hint (subtle, disappears after first tap)
    Text(
      isYearly ? 'tap for monthly' : 'tap for yearly',
      style: const TextStyle(
        fontSize: 9,
        color: AppColors.textDim,
        fontFamily: 'SpaceMono',
      ),
    ),
  ],
)
```

### Step 5: Update ring progress colour

When viewing yearly and the amount exceeds the yearly budget, shift the ring colour:

```dart
Color get ringColor {
  if (progress > 1.0) return AppColors.red;
  if (progress > 0.8) return AppColors.amber;
  return AppColors.mint;
}
```

This probably already exists — just make sure it works with the yearly values too.

### Step 6: Budget display in yearly mode

When toggled to yearly, the budget reference should also show yearly:

```dart
// Below the ring or in the spending summary:
Text(
  isYearly
      ? '£${displayBudget.toStringAsFixed(0)} yearly budget'
      : '£${displayBudget.toStringAsFixed(0)} monthly budget',
  style: const TextStyle(
    fontSize: 10,
    color: AppColors.textDim,
  ),
)
```

### Step 7: Yearly cost on subscription detail screen

In `lib/screens/detail/detail_screen.dart`, add a line showing annual cost:

```dart
// In the price section of the detail screen:
if (subscription.cycle != BillingCycle.yearly)
  Text(
    '£${subscription.yearlyEquivalent.toStringAsFixed(2)}/yr',
    style: const TextStyle(
      fontFamily: 'SpaceMono',
      fontSize: 12,
      color: AppColors.textDim,
    ),
  ),
```

This shows "£191.88/yr" under "£15.99/mo" so users see the true annual cost per service. Only shows when the sub isn't already yearly (no point showing £99.99/yr under £99.99/yr).

---

## Files Created/Modified

**New files:**
- `lib/providers/spend_view_provider.dart` (3 lines — enum + StateProvider)

**Modified files:**
- `lib/models/subscription.dart` — add `yearlyEquivalent` getter
- `lib/providers/subscriptions_provider.dart` — add total providers (or create derived providers)
- `lib/widgets/spending_ring.dart` — toggle logic, animated amount, dual budget display
- `lib/screens/detail/detail_screen.dart` — yearly cost line

**No new packages needed.**

---

## That's it. Should be 20-30 minutes of work.
