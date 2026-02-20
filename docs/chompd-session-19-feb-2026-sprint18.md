# Chompd — Sprint 18 Session Handover
> 19 Feb 2026

## What Was Done This Session

### PROMPT 3: Offline / Error State Handling
- Created 3 new exception classes in `lib/services/ai_scan_service.dart`:
  - `NoConnectionException` — catches `SocketException`, `TimeoutException`, `HttpException`
  - `ApiLimitException` — catches HTTP 429
  - `ApiUnavailableException` — catches HTTP 500/502/503
- Updated `_callDirectApi()` to wrap the HTTP POST in try/catch and throw specific exceptions
- Updated `_callApi()` to rethrow new exceptions (prevents Edge Function fallback from swallowing them)
- Updated catch blocks in `scan_provider.dart` for both `startTrapScan` and `startTextScan`:
  - `NoConnectionException` → "No internet connection. Check your Wi-Fi or mobile data and try again."
  - `ApiLimitException` → "Too many requests — please wait a moment and try again."
  - `ApiUnavailableException` → "Our scanning service is temporarily down. Please try again in a few minutes."
  - Generic catch → "Something went wrong. Please try again." (no more raw error dumps)

### PROMPT 4: Frozen Subscription UI
- Added frozen section to home screen between active and cancelled sections
- Watches `frozenSubsProvider` (already existed in `subscriptions_provider.dart`)
- Created `_FrozenCard` widget:
  - 0.5 opacity on entire card
  - Service icon + name + "Tap to upgrade" subtitle
  - Dimmed price in mono font
  - Amber "🔒 FROZEN" badge chip
  - Tap → opens PaywallScreen with haptic
- Section header: lock icon + "FROZEN — UPGRADE TO UNLOCK" in dim text
- New l10n keys in all 5 locales: `frozenSectionHeader`, `frozenBadge`, `frozenTapToUpgrade`

### PROMPT 5: Feature Gates Migration
Migrated ALL `isProProvider` consumers to granular entitlement properties:

| File | Old | New |
|------|-----|-----|
| `purchase_provider.dart` | `isProProvider` | `ent.hasUnlimitedSubs` / `ent.hasUnlimitedScans` / `ent.maxSubscriptions` / `ent.maxScans` |
| `home_screen.dart` | `isProProvider` | `ent.isFree` (limit badges) |
| `scan_screen.dart` | `isProProvider` | `ent.hasUnlimitedScans` (scan counter) |
| `detail_screen.dart` | `isProProvider` | `ent.hasSmartReminders` (reminder toggles) |
| `service_insight_card.dart` | `isProProvider` | `ent.hasFullDashboard` (insights teaser) |
| `settings_screen.dart` | `prefs.isPro` | `ent.isFree` / `ent.hasSmartReminders` / `ent.isPro` / `ent.isTrial` |

Widget parameter renames:
- `_ReminderRow.isPro` → `showProBadge`
- `_TimelineDot.isPro` → `showLock`
- `_ReminderScheduleCard.isPro` → `hasSmartReminders`

Removed unused `constants.dart` import from `purchase_provider.dart`.

### PROMPT 6: Hide Pro Upsell for Pro/Trial Users
- PRO badges on reminder rows: only show when `!hasSmartReminders` (free users only)
- Settings Pro upgrade section: hidden when `!ent.isFree` (both Pro AND trial)
- Settings tier display: "Pro" (mint) / "Trial (Xd)" (amber) / "Free" (dim)
- Timeline dots lock icons: only show when `!hasSmartReminders`
- Home screen limit badges: only show when `ent.isFree`
- AI insights teaser: only show when `!hasFullDashboard`
- New l10n key: `tierTrial` in all 5 locales

### PROMPT 7: Fix AuthNotifier Dispose Error
- **Root cause**: `auth.onAuthStateChange.listen()` in `AuthNotifier._init()` never stored the `StreamSubscription`
- **Fix**: Stored in `StreamSubscription<dynamic>? _authSub` field, added `dispose()` that cancels it, added `if (!mounted) return` guard in listener
- Added `dart:async` import

### Also completed (continued from previous session):
- Piranha scan button (64×64 circular with press animation)
- Onboarding visual cleanup (standardised all 4 pages)
- App Store review prompt (`ReviewService` singleton + `in_app_review` package)

## Files Modified This Session

### Core logic
- `lib/services/ai_scan_service.dart` — exception classes, error handling in `_callDirectApi()` and `_callApi()`
- `lib/providers/scan_provider.dart` — user-friendly catch blocks for `startTrapScan` and `startTextScan`
- `lib/providers/purchase_provider.dart` — entitlement migration, removed `constants.dart` import
- `lib/providers/auth_provider.dart` — stream subscription dispose fix
- `lib/providers/entitlement_provider.dart` — not modified (already had all feature gates)

### Screens
- `lib/screens/home/home_screen.dart` — frozen section, entitlement migration, piranha scan button
- `lib/screens/scan/scan_screen.dart` — entitlement migration (`hasUnlimitedScans`)
- `lib/screens/detail/detail_screen.dart` — entitlement migration (`hasSmartReminders`, `showProBadge`)
- `lib/screens/settings/settings_screen.dart` — entitlement migration, tier display, `hasSmartReminders`/`showLock` renames
- `lib/screens/onboarding/onboarding_screen.dart` — visual cleanup
- `lib/screens/cancel/cancel_guide_screen.dart` — review service integration

### Widgets
- `lib/widgets/service_insight_card.dart` — entitlement migration (`hasFullDashboard`)

### New files
- `lib/services/review_service.dart` — App Store review prompt service

### Localisation
- `lib/l10n/app_en.arb` — `frozenSectionHeader`, `frozenBadge`, `frozenTapToUpgrade`, `tierTrial`
- `lib/l10n/app_pl.arb` — same keys (Polish)
- `lib/l10n/app_de.arb` — same keys (German)
- `lib/l10n/app_fr.arb` — same keys (French)
- `lib/l10n/app_es.arb` — same keys (Spanish)

### Config
- `pubspec.yaml` — `in_app_review: ^2.0.9`, `assets/images/`

### Docs
- `docs/subsnap-dev-status.md` — Sprint 18 added, known issues updated

## Known Issues / Tech Debt Status

### Resolved this session
- ~~Entitlement getters not used~~ → All migrated to granular properties
- ~~Frozen subscription UI not built~~ → `_FrozenCard` + frozen section on home screen
- ~~Debug error messages in scan catch blocks~~ → User-friendly messages per exception type
- ~~AuthNotifier stream subscription leak~~ → Proper dispose with subscription cancellation

### Still outstanding
- `isProProvider` definition still exists (zero consumers) — remove in future cleanup
- `dodged_trap.g.dart` doesn't exist — DodgedTrap is plain class, Isar annotations deferred
- `widget_test.dart` references old `MyApp` class
- Debug `debugPrint` in `totalSavedProvider` and `_runTrapScan` — remove before release
- `flutter_local_notifications` v20.1.0 — notifications scheduled in-memory only
- API key baked into app via `--dart-define` — move to proxy at scale
- Edge Function not deployed on Supabase — direct API fallback in use

## Build Status
- `flutter gen-l10n` — clean
- `flutter analyze` on all modified files — zero new issues (only pre-existing info/warnings in backup folder)
