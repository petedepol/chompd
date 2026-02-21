# Chompd — Session Handover (22 Feb 2026, Session 4)

## Session Summary
TestFlight testing session. Found and fixed 7 bugs during hands-on device testing: share_plus privacy manifest, renewal date off-by-one, cancelled savings mismatch, calendar intro pricing, notification l10n after language switch, and cancel guide step localisation.

---

## Build Status
- **Latest commit:** `8dc8981` — Localise cancel guide steps for PL/DE/FR/ES
- **Branch:** main (up to date with origin)
- **Build:** 1.0.0+40

---

## Changes This Session

### 1. share_plus Privacy Manifest (ITMS-91061)
- **Issue:** Apple rejected build with ITMS-91061 — `share_plus` 7.x missing `PrivacyInfo.xcprivacy`
- **Fix:** Upgraded `share_plus` from `^7.2.1` to `^10.1.4` (privacy manifest included since v8.0.2)
- **Verified:** Old API (`Share.share()`, `Share.shareXFiles()`) still works in v10.x

### 2. Renewal Date Off-by-One
- **Bug:** "Renews tomorrow" showing for subscription renewing in 2 days
- **Root cause:** `daysUntilRenewal` compared `DateTime.now()` (with time) against `nextRenewal` — 23h55m truncates to 0 days
- **Fix:** Strip time from both dates: `DateTime(now.year, now.month, now.day)` vs `DateTime(renewal.year, renewal.month, renewal.day)`
- **File:** `lib/models/subscription.dart`

### 3. Cancelled Savings Mismatch
- **Bug:** Cancelled yearly sub at 149 zł showing "+12 zł" on card but "150 zł" in header
- **Root cause:** Card used `monthlyEquivalentIn × months` (149/12 ≈ 12), header used `priceIn × billing periods` (149 × 1)
- **Fix:** Card now uses same formula as header: `priceIn(currency) × (daysSinceCancelled / cycleDays).clamp(1.0, inf)`
- **File:** `lib/screens/home/home_screen.dart`

### 4. Calendar Intro/Trial Pricing
- **Bug:** Calendar showing intro price (£3.49) for dates after intro period expires, should show real price (£6.99)
- **Root cause:** `effectivePrice` only checked against `DateTime.now()`, but calendar displays future dates
- **Fix:** Added date-parameterised methods:
  - `Subscription.effectivePriceOn(DateTime date)` — returns intro/trial price if trial active on that date, otherwise real price
  - `Subscription.priceInOnDate(String currency, DateTime date)` — currency-converted version
  - Updated all calendar references to pass the specific date
- **Files:** `lib/models/subscription.dart`, `lib/providers/calendar_provider.dart`, `lib/screens/calendar/calendar_screen.dart`

### 5. Notification L10n After Language Switch
- **Bug:** Push notifications showing English text even after switching app to Polish
- **Root cause:** Same caching pattern as scan provider — notifications were already queued with English text and never rescheduled
- **Fix:**
  1. `locale_provider.dart` → calls `NotificationService.instance.refreshLocale()` when language changes (clears cached l10n)
  2. `notification_provider.dart` → watches `localeProvider` to trigger full reschedule when language changes
- **Files:** `lib/providers/locale_provider.dart`, `lib/providers/notification_provider.dart`

### 6. Cancel Guide Steps in English
- **Bug:** Cancel guide step content ("Log into Strava", "Go to Settings") showed in English even on Polish device. UI labels (KROK 1, Poziom trudności) were correctly localised.
- **Root cause:** Cancel guide data comes from Supabase via `CancelGuideData.fromJson()` which only parsed English fields. The localisation maps (`titleLocalized`, `detailLocalized`) were always empty. Meanwhile, the v1 `cancel_guides_data.dart` had full translations for 20 services in PL/DE/FR/ES but wasn't being used.
- **Fix (3 files):**
  1. `cancel_guides_data.dart` — added `cancelGuideToV2()` converter (v1 flat step lists → v2 per-step localisation maps) + `findTranslatedCancelGuide(name)` fuzzy matcher
  2. `service_cache_provider.dart` — `findCancelGuide()` and `findAllCancelGuides()` now prefer in-app translated data before falling back to Supabase
  3. `cancel_guide_v2.dart` — `fromJson()` now also parses `title_localized`, `detail_localized`, `warning_text_localized`, `pro_tip_localized` from JSON (future-proofs for when Supabase adds translations)

### 7. Build Number Bumps
- `pubspec.yaml` version progression: `1.0.0+35` → `1.0.0+40`

---

## Files Changed

| File | Change |
|------|--------|
| `pubspec.yaml` | share_plus upgrade, build number +40 |
| `ios/Podfile.lock` | Updated share_plus pod |
| `lib/models/subscription.dart` | `daysUntilRenewal` calendar date fix, `effectivePriceOn(date)`, `priceInOnDate()` |
| `lib/screens/home/home_screen.dart` | Cancelled card savings formula alignment |
| `lib/providers/calendar_provider.dart` | Date-aware pricing in `daySpendProvider` |
| `lib/screens/calendar/calendar_screen.dart` | All `priceIn` → `priceInOnDate` with dates |
| `lib/providers/locale_provider.dart` | Calls `refreshLocale()` on language change |
| `lib/providers/notification_provider.dart` | Watches `localeProvider` for reschedule |
| `lib/data/cancel_guides_data.dart` | `cancelGuideToV2()` converter + `findTranslatedCancelGuide()` |
| `lib/models/cancel_guide_v2.dart` | `fromJson()` parses localised fields |
| `lib/providers/service_cache_provider.dart` | Prefer in-app translated cancel guides |

---

## Git Log (This Session)

```
8dc8981 Localise cancel guide steps for PL/DE/FR/ES
9f30239 Clear notification l10n cache + reschedule on language change
315221b Calendar: show realPrice after intro/trial expiry
5daeecd Fix cancelled card savings to match header formula
862bcc3 Fix daysUntilRenewal: compare calendar dates, not timestamps
fefe306 Upgrade share_plus 7.2→10.1.4 to fix ITMS-91061 privacy manifest
```

---

## Testing Notes

- **IAP sandbox:** Cannot purchase on dev build — need sandbox Apple ID (existing Apple IDs can't be reused). Suggested Gmail + trick for unique email.
- **Trap warning detail text:** If scanning in English then switching to Polish, cached English trap text persists. Works correctly when scanning in Polish from the start. Acceptable for v1.0.
- **Cancel guide data:** Supabase has English-only cancel guides for ~30+ services. In-app data covers 20 services with full PL/DE/FR/ES. Unmatched services fall through to generic platform guides (iOS/Android/Web/Bank) which also have full translations.

---

## What's Next

### Immediate (Before App Review)
1. **TestFlight family testing** — 1 week with family testers
2. **Sandbox IAP testing** — create sandbox Apple ID, test purchase + restore flow
3. **Fix any bugs found** during testing
4. **Bump build number** and submit for App Review

### Next Week
- **Android build preparation** — get Android version ready for Google Play

### Known Acceptable Limitations for v1.0
- Trap warning detail text caches language from scan time (won't re-translate on language switch)
- Services not in the 20-service in-app database show English cancel steps (Supabase-only)
- `ServiceCache.description` is English-only — non-EN locales show category fallback
