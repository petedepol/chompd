# Chompd — Session Handover (22 Feb 2026)

## Session Summary
Two sessions today. First: reviewed AI insight infrastructure and added weekly cron + on-subscription-add trigger. Second: comprehensive pre-launch audit, Apple AI consent compliance, 10+ bug fixes, and UX polish.

---

## Build Status
- **Latest commit:** `25b108d` — Pre-launch audit fixes + AI consent + UX polish
- **Branch:** main (2 commits ahead of origin)
- **Supabase changes:** Deployed via dashboard + CLI (not committed)

---

## Changes — Session 1 (AI Insights)

### 1. Insight Dispatcher Updated
**File:** `supabase/functions/insight-dispatcher/index.ts`
- `BATCH_SIZE`: 10 → **250**
- `MIN_INTERVAL_DAYS`: 14 → **7**
- Added **pagination loop** with **timeout guard** (`MAX_RUNTIME_MS = 140s`)

### 2. Cron Rescheduled (Daily → Weekly)
- `0 3 * * 1` — Monday 3am UTC

### 3. On-Subscription-Add Trigger
- `trigger_insight_on_sub_add()` — SECURITY DEFINER, Pro only, 1-hour debounce

### 4. Carousel + L10n Polish
- Directional slide transitions, animated dots
- Unmatched service info banner localised

---

## Changes — Session 2 (Pre-Launch Audit + UX)

### App Store Compliance
- **AI consent screen** (`ai_consent_screen.dart`) — Apple Guideline 5.1.2(i). All 4 scan entry points gated. 10 new l10n keys.
- **Info.plist** — purpose strings now mention "(Anthropic Claude)"
- **PrivacyInfo.xcprivacy** — added collected photo data type

### Audit Fixes (MUST FIX)
1. **Scan counter persisted** to SharedPreferences (was resettable on restart)
2. **Text trap modelOverride** — trap body now uses `modelOverride ?? AppConstants.aiModel`
3. **Deleted** `scan_provider.dart.bak`
4. **Notification scheduler wired** — `ref.watch(notificationSchedulerProvider)` in home screen
5. **Stale comments cleaned** in `trackTrapTrial()`
6. **Isar crash recovery** — try/catch + delete corrupt DB + retry

### Audit Fixes (SHOULD FIX)
7. **Google Sign-In removed** (not needed for iOS-only launch)
8. **AM/PM locale-aware** — `TimeOfDay.format(context)` replaces hardcoded format

### Bug Fixes
9. **Wakelock during scans** — prevents iOS process suspension (`wakelock_plus`)
10. **Stale scan state reset** on screen re-entry
11. **Cancelled savings** — uses billing period price, not monthly equivalent (149 zł/yr → 149, not 12)
12. **Insight refresh on resume** — `insightRefreshSignal` bumped after Supabase sync in `didChangeAppLifecycleState`

### UX Polish
13. **Trap card positioning** — removed double SafeArea padding
14. **Multi-scan double plus** — removed icon (l10n string already has `+`)
15. **Carousel reorder** — Yearly Burn → Annual Savings → Insights → Trap Stats → Nudges

---

## Files Changed — Session 2

| File | Change |
|------|--------|
| `lib/screens/scan/ai_consent_screen.dart` | **NEW** — AI consent screen + `checkAiConsent()` |
| `lib/app.dart` | Insight refresh on resume |
| `lib/providers/combined_insights_provider.dart` | `insightRefreshSignal` StateProvider |
| `lib/providers/scan_provider.dart` | Persisted scan counter, cleaned comments |
| `lib/providers/subscriptions_provider.dart` | Billing-period savings calculation |
| `lib/screens/home/home_screen.dart` | Carousel reorder, notification scheduler watch |
| `lib/screens/scan/scan_screen.dart` | Consent gate, wakelock, reset, removed duplicate plus |
| `lib/screens/scan/trap_warning_card.dart` | Removed SafeArea |
| `lib/screens/settings/settings_screen.dart` | Removed Google button, locale-aware time |
| `lib/services/ai_scan_service.dart` | Text trap modelOverride fix |
| `lib/services/auth_service.dart` | Removed `linkGoogleSignIn()` |
| `lib/services/isar_service.dart` | Crash recovery |
| `lib/utils/share_handler.dart` | Consent gate |
| `ios/Runner/Info.plist` | AI provider in purpose strings |
| `ios/Runner/PrivacyInfo.xcprivacy` | Collected photo data type |
| `pubspec.yaml` | Added `wakelock_plus` |
| All 5 ARB files + generated l10n | 10 `aiConsent*` keys |

---

## What's Left Before Submission

1. **RevenueCat integration** — wire real IAP (last big job)
2. **Rotate API key** — generate fresh key for production
3. **Supabase SQL cleanup** — delete YouTube/Google Play aliases
4. **App Store Connect** — screenshots, listing copy, submit
