# Handover — 20 February 2026

## Session Summary

Two sessions today completing the **pre-launch batch** (`cc-prompt-prelaunch-batch.md`). All 4 fixes plus the prior batch (intro price, debugPrint, onboarding) are done and pushed.

---

## Commits Pushed Today

| Hash | Description |
|------|-------------|
| `b5be54b` | Localise scan messages, intro price labels, remove debugPrint, cleanup |
| `f56ffe3` | Center onboarding content vertically in available space |
| `d4aa411` | Pre-launch batch: scan limit=1, error logging, Done button, iOS bundle fix |

All on `main`, pushed to `origin/main`.

---

## What Was Done

### Session 1 (previous context)
1. **Intro price l10n keys** — 4 new keys (`introPrice`, `introPriceExpires`, `introPriceDaysRemaining`, `introBadge`) in all 5 ARB files
2. **debugPrint removal** — stripped from 21 production files; `debugFireTestNotification()` gated with `kDebugMode`
3. **widget_test.dart** — replaced stale test with placeholder
4. **Dead isProProvider** — removed from `entitlement_provider.dart`
5. **Onboarding centering** — LayoutBuilder + ConstrainedBox pattern

### Session 2 (this context)
1. **Scan limit alignment (Fix 1)** — `freeMaxScans = 1` enforced everywhere:
   - Edge function `FREE_SCAN_LIMIT` 5 → 1
   - `ScanCounterNotifier` hardcoded 3 → `AppConstants.freeMaxScans`
   - L10n strings rewritten singular (no `{count}`/`{limit}` params)
   - Callers updated, unused catch variable warnings fixed

2. **Done button after trap scan (Fix 2)** — `_buildBottomBar` now shows Done for ALL `ScanPhase.result` states. Both Done buttons use `popUntil(isFirst)` to go home.

3. **Error logging (Fix 3)** — New `ErrorLogger` class in `lib/services/error_logger.dart`. Static `log()` method writes to Supabase `app_events` table with truncated stack traces. Wired into 6 priority files (21 catch blocks):
   - sync_service (7), auth_service (2), scan_provider (3), ai_scan_service (3), main.dart (2), purchase_service (4)

4. **iOS bundle name (Fix 4)** — `CFBundleName` changed from `subsnap` to `Chompd` in Info.plist

### Verification
- `flutter gen-l10n` — clean
- `flutter analyze` — zero new errors (only pre-existing warnings in backup files)
- Grep for scan limit inconsistencies — all show 1 or use `AppConstants.freeMaxScans`
- Grep for "subsnap" in ios/ — no matches

---

## Files Modified (Session 2)

| File | Change |
|------|--------|
| `lib/services/error_logger.dart` | **NEW** — error logging utility |
| `lib/providers/scan_provider.dart` | AppConstants.freeMaxScans, ErrorLogger, singular l10n |
| `lib/screens/scan/scan_screen.dart` | Done button for all result phases, popUntil |
| `lib/screens/paywall/paywall_screen.dart` | Removed paywallLimitScans argument |
| `lib/services/sync_service.dart` | ErrorLogger in 7 catch blocks |
| `lib/services/auth_service.dart` | ErrorLogger in 2 catch blocks |
| `lib/services/ai_scan_service.dart` | ErrorLogger in 3 catch blocks |
| `lib/main.dart` | ErrorLogger in 2 catch blocks |
| `lib/services/purchase_service.dart` | ErrorLogger in 4 catch blocks |
| `ios/Runner/Info.plist` | CFBundleName subsnap -> Chompd |
| `supabase/functions/ai-scan/index.ts` | FREE_SCAN_LIMIT 5 -> 1 |
| `lib/l10n/app_*.arb` (x5) | Singular scan limit strings |
| `lib/l10n/generated/app_localizations*.dart` (x6) | Auto-regenerated |
| `docs/subsnap-dev-status.md` | Sprint 21 added, known issues updated |
| `pubspec.yaml` | Minor dependency update |

---

## Outstanding Plan (Not Worked On Today)

There is an **existing plan** at `.claude/plans/jazzy-juggling-hanrahan.md` for 3 interconnected bugs from Build +20 testing:

- **Bug 3** — Trap timeline shows "60-day trial" instead of intro price (needs prompt update + `monthIntro` l10n key + price_breakdown_card conditional)
- **Bug 4** — Sonnet escalation message shown twice (needs `_escalationMessageShown` flag)
- **Bug 5** — Duplicate subscription from one scan (needs `fromTrapTracking` flag + dedup guard)

This plan is detailed and ready to implement in order: Bug 4 → Bug 5 → Bug 3.

---

## What's Next

1. **Bugs 3/4/5** from the existing plan (trap timeline, double escalation, duplicate subs)
2. **TestFlight Build +21** with all pre-launch fixes
3. **App Store submission prep** — screenshots, description, review notes
4. Any remaining items from `cc-prompt-prelaunch-batch.md` if there were more beyond these 4

---

## Key Context for Next Session

- `ErrorLogger` event types: `sync_error`, `auth_error`, `scan_error`, `ai_api_error`, `startup_error`, `purchase_error`
- `ScanCounterNotifier` now references `AppConstants.freeMaxScans` — changing the constant changes everything
- `ScanPhase.result` Done button covers single scan, multi scan, AND trap-tracked results
- The plan for bugs 3/4/5 is in `.claude/plans/jazzy-juggling-hanrahan.md` — read it before starting
