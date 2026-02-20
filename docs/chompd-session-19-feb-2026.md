# Chompd — Session Notes: 19 Feb 2026

> Trial implementation verification + scanner fix session

---

## Session Overview

This session had three phases:
1. **Verify 6 trial implementation items** (from `cc-trial-verification-prompt.md`)
2. **Fix the AI scanner** (Edge Function 404 + API key 401)
3. **Confirm delete behaviour** (already correct — hard delete)

---

## Phase 1: Trial Verification (6 Items)

The user provided a verification prompt asking to check 6 specific areas of the trial implementation. Investigation results:

### Item 1: Isar `isActive` field ✅ Fully implemented
- `Subscription.isActive` exists at line 158-159 in `lib/models/subscription.dart`
- Has `@Index()` annotation for efficient querying
- Defaults to `true`
- Generated code (`subscription.g.dart`) is up-to-date with the field
- Used correctly in `SubscriptionsNotifier._load()` via `.deletedAtIsNull()` filter

### Item 2: Frozen Subscription UI ❌ Not implemented
**Backend exists, UI does not.**

What exists:
- `frozenSubsProvider` in `subscriptions_provider.dart` — filters `!isActive && cancelledDate == null`
- `freezeExcess(int maxActive)` and `unfreezeAll()` methods on `SubscriptionsNotifier`
- `Subscription.isActive` field in Isar

What's missing (needs building):
- Home screen does NOT show frozen subs — they're filtered out with `.where((s) => s.isActive)`
- No greyed-out / dimmed tile treatment
- No Pro badge / lock icon on frozen cards
- No bottom sheet with "Swap with active sub" / "Unlock Pro" options
- No `swapSubscription()` method on the notifier

**Implementation plan was designed** (see below in "Deferred Work") with full code approach for:
1. Merging frozen subs into home list after active subs
2. `isFrozen` parameter on `SubscriptionCard` with opacity + lock badge
3. New `frozen_sub_sheet.dart` bottom sheet widget
4. `swapSubscription()` method on notifier
5. l10n keys (EN + PL)

### Item 3: Savings Accumulation Logic ✅ Fully implemented
- `totalSavedProvider` in `subscriptions_provider.dart` correctly calculates `monthlyEquivalent × months since cancellation`
- Each `_CancelledCard` shows individual "+£X" contribution
- "SAVED WITH CHOMPD" header shows total across all cancelled subs
- Guard added: if `cancelledDate == null`, falls back to `createdAt` (prevents £0 display)

### Item 4: Trial Banner Slim Strip ✅ Fully implemented
- `lib/widgets/trial_banner.dart` is a slim ~36-40px strip (single line, minimal padding)
- Shows "✨ Pro trial · X days left | Upgrade" format
- Tapping anywhere opens paywall
- When expired: "Pro trial expired" + "Upgrade"
- When user is Pro: hidden entirely (returns `SizedBox.shrink()`)
- Placed in home screen as `SliverToBoxAdapter` between scan button and spending ring

### Item 5: Scan Limit UI on Home Screen ❌ Not implemented
- No dedicated scan CTA card on the home screen
- Scan limit enforcement exists in the scan screen and FAB modal
- But there's no home screen card showing "1 free scan" / "Upgrade for unlimited" etc.

### Item 6: Feature Gates Using Entitlement ⚠️ Partially done
**Infrastructure exists, adoption incomplete.**

What exists:
- `lib/models/entitlement.dart` — complete with all 8 getters: `hasUnlimitedSubs`, `hasUnlimitedScans`, `hasSmartReminders`, `hasFullDashboard`, `hasAllCancelGuides`, `hasSmartNudges`, `hasSavingsCards`, `hasCsvExport`
- `lib/providers/entitlement_provider.dart` — complete with `EntitlementNotifier`, trial management, `isProProvider` wrapper
- All getters correctly derived from `hasFullAccess` (trial OR pro)

What's missing:
- **No screen or widget actually uses the specific getters** — everything still uses raw `isProProvider` boolean
- Feature gates that should use specific getters:
  | Feature | Location | Uses | Should Use |
  |---------|----------|------|------------|
  | Add sub limit | `home_screen.dart` | `isProProvider` | `hasUnlimitedSubs` |
  | Scan limit | `scan_screen.dart` | `isProProvider` | `hasUnlimitedScans` |
  | Reminder days | `detail_screen.dart` | `isProProvider` | `hasSmartReminders` |
  | Service insights | `service_insight_card.dart` | `isProProvider` | `hasFullDashboard` |
  | Notification prefs | `settings_screen.dart` | `isPro` field | Should derive from entitlement |

**Technically functional** because `isProProvider` returns `entitlement.hasFullAccess`, but violates the spec that each feature gate should use its own specific getter.

---

## Phase 2: Scanner Fix

### Problem
Two errors when scanning:
1. `FunctionException(status: 404)` — Edge Function not found
2. `Claude API error 401: invalid x-api-key` — direct API fallback failing

### Root Cause
1. The Edge Function `supabase/functions/ai-scan/index.ts` exists locally but was **never deployed** to the Supabase instance. Every scan was hitting the Edge Function first, getting a 404, then falling back to direct API — adding latency and error noise.
2. The API key 401 was either a key rotation issue or shell escaping problem with `--dart-define`.

### Fix Applied

**File: `lib/services/ai_scan_service.dart`**

1. **Edge Function now opt-in** (was always-on when Supabase URL present):
   ```dart
   // Before:
   bool get _useEdgeFunction => _hasSupabase;

   // After:
   const _useEdgeFn = bool.fromEnvironment('USE_EDGE_FUNCTION');
   bool get _useEdgeFunction => _useEdgeFn && _hasSupabase;
   ```
   Now requires explicit `--dart-define=USE_EDGE_FUNCTION=true` to enable. Default: direct API.

2. **Single API key constant** (was read in two places):
   ```dart
   // Before: two separate String.fromEnvironment calls
   const _hasApiKey = String.fromEnvironment('ANTHROPIC_API_KEY') != '';
   // ... later in _callDirectApi():
   const apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');

   // After: single top-level constant
   const _apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
   const _hasApiKey = _apiKey != '';
   // ... _callDirectApi() uses _apiKey directly
   ```

3. **Diagnostic logging**:
   ```dart
   debugPrint('[AiScan] Direct API — key length: ${_apiKey.length}');
   ```
   Logs key length on every scan for debugging without exposing the key.

**File: `lib/providers/scan_provider.dart`**

4. **Sanitised error messages** — both catch blocks (lines 370, 1134):
   ```dart
   // Before:
   errorMessage: e.toString(),  // leaked raw API errors to UI

   // After:
   errorMessage: 'scan_error',  // safe constant
   ```
   The user-facing chat message was already friendly: "Couldn't read this image. Please try a different screenshot."

---

## Phase 3: Delete Behaviour Confirmation

User asked to confirm subscription deletion is hard delete. **Already correct — no changes needed.**

Current behaviour:
- **Delete** (`remove()` in `subscriptions_provider.dart`): Hard delete from Isar (`deleteAll()`) + hard delete from Supabase (`.delete()` SQL). Row is completely removed.
- **Cancel** (`cancel()` in `subscriptions_provider.dart`): Sets `isActive = false` + `cancelledDate = now`. Sub remains in database and visible in cancelled section.
- `deletedAt` field on Subscription model exists but is only used during sync pull (to detect remotely-deleted records). The actual delete path does a real hard delete.
- No graveyard/restore-from-deleted UI exists.

---

## Files Modified This Session

| File | Change |
|------|--------|
| `lib/services/ai_scan_service.dart` | Edge Function opt-in, single API key constant, diagnostic logging |
| `lib/providers/scan_provider.dart` | Sanitised `errorMessage` from `e.toString()` to `'scan_error'` |

### Files Investigated But NOT Modified
- `lib/models/subscription.dart` — `isActive` field confirmed correct
- `lib/providers/subscriptions_provider.dart` — `remove()` hard delete confirmed correct
- `lib/services/sync_service.dart` — `pushDelete()` hard delete confirmed correct
- `lib/widgets/trial_banner.dart` — slim strip confirmed correct
- `lib/providers/entitlement_provider.dart` — infrastructure confirmed correct
- `lib/models/entitlement.dart` — all 8 getters confirmed correct
- `lib/screens/home/home_screen.dart` — cancelled section + savings confirmed correct

---

## Deferred Work (Not Done This Session)

### 1. Frozen Subscription UI (Item 2)
Full implementation plan was designed:
- Add `isFrozen` parameter to `SubscriptionCard` with 0.45 opacity + purple lock badge
- Merge frozen subs into home list after active subs
- New `lib/widgets/frozen_sub_sheet.dart` — two-phase bottom sheet (swap picker + unlock Pro)
- `swapSubscription({frozenUid, activeUid})` method on `SubscriptionsNotifier`
- 7 l10n keys (EN + PL): `frozenSubTitle`, `frozenSubMessage`, `frozenSwapOption`, `frozenUnlockOption`, `frozenSwapPickerTitle`, `frozenSwapSuccess`

### 2. Scan Limit UI on Home Screen (Item 5)
Needs a dedicated card/CTA on the home screen:
- Free (unused): "Scan for hidden traps — 1 free scan"
- Free (used): "Upgrade to Pro for unlimited scans"
- Trial: "Unlimited scans (Pro Trial)"
- Pro: "Unlimited scans"

### 3. Feature Gate Migration (Item 6)
All screens still use raw `isProProvider` instead of specific entitlement getters. Migration checklist:
- `home_screen.dart` → `entitlementProvider.hasUnlimitedSubs`
- `scan_screen.dart` → `entitlementProvider.hasUnlimitedScans`
- `detail_screen.dart` → `entitlementProvider.hasSmartReminders`
- `service_insight_card.dart` → `entitlementProvider.hasFullDashboard`
- `settings_screen.dart` → derive from entitlement, not cached `isPro` field

---

## Launch Command Reminder

```bash
flutter run -d <device-id> \
  --dart-define=SUPABASE_URL=<url> \
  --dart-define=SUPABASE_ANON_KEY=<key> \
  --dart-define=ANTHROPIC_API_KEY=<key>
```

To enable Edge Function (when deployed):
```bash
  --dart-define=USE_EDGE_FUNCTION=true
```

Must be a **full cold restart** (not hot reload) for `--dart-define` values to take effect.
