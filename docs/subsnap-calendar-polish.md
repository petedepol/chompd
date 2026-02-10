# SubSnap — Renewal Calendar Polish

> Quick polish pass on the calendar screen. Core feature works, these are visual refinements.

---

## Tweak 1: Bigger Renewal Dots

**Problem:** Category dots on renewal dates are too small to spot at a glance (2-3px).

**Fix:** Increase dot size to 6px diameter. Add a subtle glow matching the dot colour.

```dart
// Current (too small):
Container(
  width: 3,
  height: 3,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: dotColor,
  ),
)

// Updated:
Container(
  width: 6,
  height: 6,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: dotColor,
    boxShadow: [
      BoxShadow(
        color: dotColor.withOpacity(0.4),
        blurRadius: 4,
        spreadRadius: 1,
      ),
    ],
  ),
)
```

---

## Tweak 2: Bold Renewal Dates

**Problem:** Days with renewals look the same weight as empty days. Hard to scan.

**Fix:** Renewal dates get brighter text + slightly bolder weight. Empty dates stay dim.

```dart
Text(
  '$day',
  style: TextStyle(
    fontSize: 16,
    fontWeight: hasRenewal ? FontWeight.w600 : FontWeight.w400,
    color: isToday
        ? AppColors.mint
        : hasRenewal
            ? AppColors.text       // bright white — #F0F0F5
            : AppColors.textDim,   // dim — #6A6A82
  ),
)
```

---

## Tweak 3: Multiple Dots Per Day

**Problem:** If two or more subscriptions renew on the same day, need to show multiple dots or a count.

**Fix:** Stack up to 3 dots side by side (one per category colour). If 4+ renewals, show 2 dots + a count.

```dart
Widget _buildDayDots(List<Subscription> renewals) {
  if (renewals.isEmpty) return const SizedBox.shrink();

  // Get unique category colours for this day's renewals
  final colors = renewals
      .map((s) => getCategoryColor(s.category))
      .toSet()
      .toList();

  if (colors.length <= 3) {
    // Show individual dots
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: colors.map((c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c,
            boxShadow: [
              BoxShadow(
                color: c.withOpacity(0.4),
                blurRadius: 3,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
      )).toList(),
    );
  } else {
    // 4+ categories: show 2 dots + count
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...colors.take(2).map((c) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c,
            ),
          ),
        )),
        Text(
          '+${colors.length - 2}',
          style: const TextStyle(
            fontSize: 7,
            fontFamily: 'SpaceMono',
            color: AppColors.textDim,
          ),
        ),
      ],
    );
  }
}
```

---

## Tweak 4: Tap Day → Show Renewals

**Problem:** "Tap a day to see what renews" is shown but tapping likely does nothing yet.

**Fix:** Tapping a day with renewals expands a card below the calendar showing what renews.

```dart
// State: track selected day
int? _selectedDay;

// On tap:
GestureDetector(
  onTap: () {
    if (renewalsForDay.isNotEmpty) {
      setState(() {
        _selectedDay = _selectedDay == day ? null : day;
      });
      HapticService.instance.selectionClick();
    }
  },
  child: _buildDayCell(day),
)

// Below the calendar grid, show selected day's renewals:
AnimatedSize(
  duration: const Duration(milliseconds: 250),
  curve: Curves.easeOutCubic,
  child: _selectedDay != null
      ? _buildSelectedDayCard(_selectedDay!)
      : const SizedBox.shrink(),
)
```

**Selected day card design:**

```
┌──────────────────────────────────────────┐
│  February 13                              │
│                                           │
│  ┌─ sub card ────────────────────────┐   │
│  │ 🟣 Figma Pro    £9.99/mo         │   │
│  │     10d trial                     │   │
│  └───────────────────────────────────┘   │
│                                           │
│  ┌─ sub card ────────────────────────┐   │
│  │ 🔵 iCloud+      £2.99/mo         │   │
│  └───────────────────────────────────┘   │
│                                           │
│  Day total: £12.98                        │
└──────────────────────────────────────────┘
```

```dart
Widget _buildSelectedDayCard(int day) {
  final date = DateTime(_currentYear, _currentMonth, day);
  final renewals = _getRenewalsForDate(date);

  if (renewals.isEmpty) return const SizedBox.shrink();

  return Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Text(
          DateFormat('MMMM d').format(date),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMid,
          ),
        ),
        const SizedBox(height: 12),

        // Renewal cards
        ...renewals.map((sub) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              // Category dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: getCategoryColor(sub.category),
                ),
              ),
              const SizedBox(width: 10),
              // Name
              Expanded(
                child: Text(
                  sub.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ),
              // Price
              Text(
                sub.priceDisplay,
                style: const TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        )),

        // Day total (if multiple)
        if (renewals.length > 1) ...[
          const Divider(color: AppColors.border, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Day total: ',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textDim,
                ),
              ),
              Text(
                '£${renewals.fold(0.0, (sum, s) => sum + s.price).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mint,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
```

---

## Tweak 5: Summary Card Dark Theme Fix

**Problem:** The "THIS MONTH" summary card background looks lighter than the rest of the dark UI. Feels like a light theme component.

**Fix:** Match the existing card style.

```dart
// The outer container:
Container(
  decoration: BoxDecoration(
    color: AppColors.bgCard,        // #111118 — not grey
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.border),  // #242436
  ),
)

// The inner stat boxes ("5 Renewals" / "£61.96 Total"):
Container(
  decoration: BoxDecoration(
    color: AppColors.bgElevated,    // #1A1A24 — not light grey
    borderRadius: BorderRadius.circular(12),
  ),
)

// Text colours:
// "5" → AppColors.mint
// "Renewals" → AppColors.textDim
// "£61.96" → AppColors.mint
// "Total" → AppColors.textDim
// "THIS MONTH" header → AppColors.textDim, fontFamily: 'SpaceMono', letterSpacing: 1.5
```

---

## Summary

| Tweak | Effort | Impact |
|---|---|---|
| Bigger dots + glow | 5 min | Medium — scanability |
| Bold renewal dates | 5 min | Medium — scanability |
| Multiple dots per day | 15 min | Low — edge case |
| Tap day → show renewals | 20 min | High — core interaction |
| Summary card dark theme | 5 min | Medium — visual consistency |

Total: ~50 minutes. Tap interaction is the big one — everything else is quick styling.
