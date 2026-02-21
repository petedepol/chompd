# Chompd — Session Handover (21 Feb 2026, Evening)

## Session Summary
Three-phase session: (1) wired real IAP via `in_app_purchase` plugin (StoreKit 2), replacing simulated purchase flow, (2) ran comprehensive code audit (combined manual + Codex 5.3), (3) fixed all 7 must-fix and 9 should-fix audit issues.

---

## Build Status
- **Latest commit:** `1e2d809` — Fix 9 should-fix audit issues
- **Previous commits this session:**
  - `49014e8` — Fix 7 must-fix audit issues
  - `4bb0a73` — Wire real IAP via in_app_purchase plugin (StoreKit 2)
- **Branch:** main (6 commits ahead of origin)
- **Build:** `flutter build ios --no-codesign` passes cleanly

---

## Phase 1: Real IAP Integration

### Key Decision
Dropped `7_day_trial` as IAP product — Apple doesn't support $0 non-consumable products. Trial stays local via SharedPreferences + EntitlementNotifier (already working).

### Changes
| File | Change |
|------|--------|
| `pubspec.yaml` | Added `in_app_purchase: ^3.2.3` |
| `lib/services/purchase_service.dart` | Full rewrite — real StoreKit 2 via `InAppPurchase.instance` |
| `lib/config/constants.dart` | Removed `trialProductId = '7_day_trial'` |
| `lib/screens/paywall/paywall_screen.dart` | Dynamic price via `PurchaseService.instance.priceDisplay`, smarter cancel handling |
| `lib/screens/settings/settings_screen.dart` | Dynamic price display |
| `lib/l10n/app_*.arb` (5 files) | Added `purchaseCancelled` key |

### IAP Architecture
- **Source of truth:** App Store (StoreKit 2) primary → Supabase `profiles.is_pro` secondary → local `_state` in-memory
- **Completer pattern:** `purchasePro()` creates `Completer<bool>`, purchase stream resolves it
- **Product:** `chompd_pro_lifetime` (non-consumable, one-time purchase)
- **Price:** App Store-localised via `ProductDetails.price`, GBP fallback if query fails

---

## Phase 2: Code Audit

Ran comprehensive audit + cross-referenced with Codex 5.3 findings. Produced unified list: 7 red (must fix), 12 yellow (should fix), 8 green (can wait).

---

## Phase 3: Audit Fixes

### Must-Fix (Red) — Commit `49014e8`
1. **Subscriptions provider silent errors** — ErrorLogger.log() in all 8 catch blocks
2. **Purchase completers never nulled** — Nulled after resolution in all 3 stream handlers
3. **AddEditScreen missing mounted check** — `if (!mounted) return;` before Navigator.pop()
4. **Toast hardcoded /mo** — Localised with cycleWeeklyShort/Monthly/Quarterly/Yearly l10n keys
5. **Edge function scan count on failed AI** — Only increments when `anthropicResponse.ok`
6. **ErrorLogger null user_id** — Uses `'anonymous'` sentinel pre-auth
7. **CLAUDE.md stale docs** — "3 free AI scans" → "1 free AI scan"

### Should-Fix (Yellow) — Commit `1e2d809`
8. **SyncService soft-deleted data** — Already handled correctly (`.isFilter('deleted_at', null)` + cleanup). SKIPPED.
9. **Entitlement listener dispose** — Riverpod auto-cleans `ref.listen()`. SKIPPED.
10. **HapticService async return types** — `error()` + `celebration()` now return `Future<void>`
11. **effectivePrice during trap trials** — Shows `trialPrice` during active trial, `realPrice` after expiry
12. **BillingCycle.fromString silent fallback** — Debug-assert log for unknown values
13. **PriceBreakdownCard hardcoded fontFamily** — Replaced `fontFamily: 'SpaceMono'` with `ChompdTypography.mono()`
14. **OnboardingScreen PageController listener** — `removeListener` before `dispose()`
15. **NotificationService ID overflow** — Wraps at 2^31-1 for Android 32-bit limit
16. **Dead providers** — SKIPPED (harmless, lazy-evaluated, may be useful later)
17. **Dead currency.dart** — SKIPPED (harmless dead file)
18. **CHF currency spacing** — Removed trailing space from symbol, `formatPrice()` handles multi-letter prefix spacing
19. **Info.plist landscape orientations** — Restricted to portrait-only (matches `SystemChrome` lock)

---

## Files Changed This Session

| File | Change |
|------|--------|
| `pubspec.yaml` | `in_app_purchase: ^3.2.3` |
| `lib/services/purchase_service.dart` | Full IAP rewrite + completer nulling |
| `lib/config/constants.dart` | Removed `trialProductId` |
| `lib/screens/paywall/paywall_screen.dart` | Dynamic price, cancel handling |
| `lib/screens/settings/settings_screen.dart` | Dynamic price |
| `lib/l10n/app_*.arb` (5 files) | `purchaseCancelled` key |
| `lib/providers/subscriptions_provider.dart` | ErrorLogger in 8 catch blocks |
| `lib/screens/detail/add_edit_screen.dart` | Mounted check |
| `lib/services/error_logger.dart` | `'anonymous'` sentinel |
| `lib/widgets/toast_overlay.dart` | Localised cycle text |
| `supabase/functions/ai-scan/index.ts` | Scan count on success only |
| `CLAUDE.md` | Free scan count docs |
| `lib/services/haptic_service.dart` | Future<void> return types |
| `lib/models/subscription.dart` | effectivePrice trial-aware, BillingCycle debug log, CHF spacing |
| `lib/widgets/price_breakdown_card.dart` | ChompdTypography.mono() |
| `lib/screens/onboarding/onboarding_screen.dart` | removeListener |
| `lib/services/notification_service.dart` | ID counter wrap |
| `ios/Runner/Info.plist` | Portrait-only |

---

## What's Left Before Submission

### App Store Connect (Manual)
1. **Create `chompd_pro_lifetime` IAP product** in App Store Connect (Non-Consumable, pricing tiers)
2. **StoreKit Configuration File** — create for Xcode testing (sandbox purchases)
3. **Privacy nutrition labels** — configure in App Store Connect
4. **Screenshots** — capture on physical device
5. **App Store listing** — title, subtitle, description, keywords

### Code
6. **Deploy Edge Function** — `supabase functions deploy ai-scan` (local `index.ts` modified but not deployed)
7. **Rotate API key** — fresh Anthropic key for production
8. **Supabase SQL cleanup** — delete YouTube/Google Play aliases

### Testing
9. **StoreKit sandbox testing** — purchase, cancel, restore flows on physical device
10. **Verify `priceDisplay`** shows localised price from App Store
