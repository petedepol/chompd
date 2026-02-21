# Chompd — Session Handover (21 Feb 2026)

## Session Summary
Two-part session: (1) Night session fixed YouTube alias matching bug + reinstated service description punchlines. (2) Day session fixed trap warning localisation, English descriptions on non-EN locales, annual savings card styling, trap scan modelOverride passthrough, and upgraded Sonnet to 4.6. All 9 original QA bugs + 4 prelaunch batch items verified fixed during device testing. OG image created for website. Google Search Console submitted. **App is ready for App Store submission — manual tasks only remain.**

---

## Build Status
- **Current build:** +28
- **Latest commit:** `5bec0d4` — Upgrade Sonnet fallback from 4.5 to 4.6
- **Bundle ID:** com.chompdapp.chompdapp
- **Branch:** main (up to date with origin)

## Build Command
```bash
cd ~/subsnap
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://bavfommuelhivrigiafg.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_nqEKvmcTaucj_p8ivLWMAA_u74BTje1 \
  --dart-define=ANTHROPIC_API_KEY=<key from .env>
```

---

## Bugs Fixed This Session

### 1. YouTube Insight Showing for Google Play Subscription (Night)
**Root cause:** Supabase `service_aliases` table had `"google play"` as an alias for YouTube Premium. When user scanned a Google Play receipt, `findByName("Google Play")` matched YouTube Premium via alias step.

**Fix:** Added `_billingPlatforms` blocklist to `findByName()` in `service_cache_provider.dart`. Generic billing entity names are rejected early before any matching logic.

**Supabase cleanup still needed** (see SQL below).

### 2. Missing Service Description Punchlines (Night)
**Root cause:** Sprint 19 overhaul removed `_serviceDescription` getter and replaced with just localised category.

**Fix:** Reinstated `_serviceDescription` in both `subscription_card.dart` and `detail_screen.dart` with `ServiceCache.description` lookup via `matchedServiceId`, falling back to `AppConstants.localisedCategory()`.

### 3. Trap Warnings in English When App in Polish (Day)
**Root cause:** Trap scan JSON schema field descriptions had "plain English summary" for `warning_message` and `detail` fields, overriding the `_langInstruction` at the top of the prompt.

**Fix:** Replaced "plain English" with `${_languageName(langCode)}` in 4 locations (image + text trap prompts).

### 4. English Descriptions on Non-EN Subscription Cards (Day)
**Root cause:** `ServiceCache.description` only has English text from Supabase. Was showing on all locales.

**Fix:** Gated `_serviceDescription()` on locale — checks `lang != 'en'` → returns null → falls back to localised category. Applied in both `subscription_card.dart` and `detail_screen.dart`.

### 5. Annual Savings Card Too Dark (Day)
**Root cause:** Card used custom `_green` (#1B8F6A) colour and flat `c.bgCard` background, not matching other carousel cards.

**Fix:** Switched to theme `c.mint` + gradient background (`mint@0.08 → bgCard`) matching yearly burn card. Padding 16→18.

### 6. Trap Scan Not Benefiting from Sonnet Escalation (Day)
**Root cause:** `_runTrapScan()` was hardcoded to `AppConstants.aiModel` (Haiku). When `scan_provider` escalated to Sonnet, only subscription extraction got Sonnet while trap scan stayed on Haiku.

**Fix:** Added `modelOverride` parameter to `_runTrapScan()`, passed through from `analyseScreenshotWithTrap()`.

### 7. Sonnet 4.6 Upgrade (Day)
Upgraded `aiModelFallback` from `claude-sonnet-4-5-20250929` to `claude-sonnet-4-6`. Same pricing ($3/$15 per MTok), newer training data (Jan 2026 cutoff). Updated both `constants.dart` and Edge Function `ALLOWED_MODELS`.

### 8. API Key Typo (Night, minor)
`.env` had `ssk-ant-api03-` (double s) → fixed to `sk-ant-api03-`.

---

## Commits This Session
| Commit | Description |
|--------|-------------|
| `e1a96b6` | Fix YouTube alias matching, reinstate service descriptions on cards |
| `79aa930` | Localise trap warnings and gate English descriptions for non-EN locales |
| `6fc8457` | Style annual savings card to match carousel, pass modelOverride to trap scan |
| `5bec0d4` | Upgrade Sonnet fallback from 4.5 to 4.6 |

## Files Changed This Session

| File | Change |
|------|--------|
| `lib/providers/service_cache_provider.dart` | Added `_billingPlatforms` blocklist to `findByName()` |
| `lib/widgets/subscription_card.dart` | `_serviceDescription(BuildContext)` with EN-only gate + category fallback |
| `lib/screens/detail/detail_screen.dart` | `_serviceDescription(sub, lang)` with EN-only gate + category fallback |
| `lib/services/ai_scan_service.dart` | Trap prompt l10n fix (4 locations) + `_runTrapScan()` modelOverride param |
| `lib/widgets/annual_savings_card.dart` | Theme mint colour + gradient background, removed custom `_green` |
| `lib/config/constants.dart` | `aiModelFallback` → `claude-sonnet-4-6` |
| `supabase/functions/ai-scan/index.ts` | `ALLOWED_MODELS` updated for Sonnet 4.6 |
| `pubspec.yaml` | Build +25 → +28 |
| `.env` | Fixed API key prefix typo (not committed) |

---

## What's Left Before App Store

### Supabase Cleanup (Manual)
```sql
-- Delete bad YouTube Premium aliases
DELETE FROM service_aliases
WHERE service_id = '92badf7e-db07-4eb5-aca7-6e1d73f3b0dd'
AND alias IN ('google play', 'google youtube', 'google *youtube');

-- Delete old test user_insights
DELETE FROM user_insights;

-- Delete phantom cancelled subs (if any remain)
DELETE FROM subscriptions WHERE cancelled_date IS NOT NULL;
```

### Outstanding Bugs — ALL CLEARED ✅
All 9 original QA bugs + 4 prelaunch batch items verified fixed during device testing on 21 Feb. No outstanding bugs.

### Trap Scan Resilience (Deferred)
- `_runTrapScan()` has catch-all returning `TrapResult.clean` on any error — no retry logic
- modelOverride passthrough partially addresses (Sonnet is more reliable)
- Silent error swallowing means trap detection can intermittently fail without user knowing

### Code Cleanup (Pre-App Store)
- Change "Trial" → "Intro price" label on trap card when `trialPrice > 0`
- Remove remaining `debugPrint` statements (if any)

### Manual Tasks Only (No Code Needed)
1. **Rotate Anthropic API key** — old key exposed in chat history. Generate new at console.anthropic.com, update `.env`
2. **Run Supabase cleanup SQL** — delete bad YouTube aliases, old user_insights, phantom cancelled subs (SQL above)
3. ~~**Add OG image**~~ ✅ Done
4. **Uncomment Apple Smart App Banner** — line 17 in index.html, replace `YOUR_APP_STORE_ID` with real ID after submission
5. **App Store Connect: IAP setup** — 7-day trial + £4.99 one-time Pro purchase
6. **App Store screenshots** — 6.7" + 6.5" minimum
7. **App Store listing** — spec in `chompd-app-store-listing.md`
8. **Submit for review**

---

## Key Technical Notes

### AI Model Configuration
- **Primary:** `claude-haiku-4-5-20251001` — handles ~95% of scans
- **Fallback:** `claude-sonnet-4-6` — same price as 4.5, newer training data
- Sonnet escalation triggers:
  - Single scan: `_shouldEscalate()` returns true (low confidence)
  - Multi-sub scan: empty results, single+poor quality, or ≥5 results
  - Trap scan: inherits `modelOverride` from subscription scan escalation

### Service Description Flow
1. `ServiceCache` records from Supabase `services` table (includes `description` column — English only)
2. `matchServiceIdAsync()` finds matching `ServiceCache` by name during scan/add
3. `matchedServiceId` stored on `Subscription` model
4. Display time: `findById(matchedServiceId)` → `service.description` → shown on card/detail **only if locale is EN**
5. Non-EN locales or no match: `AppConstants.localisedCategory()` — translated in all 5 languages

### Billing Platform Blocklist
Generic billing entity names that should NEVER match a specific service:
`google play`, `google play store`, `apple`, `apple.com/bill`, `app store`, `itunes`, `paypal`, `stripe`, `google`, `microsoft store`

---

## Infrastructure
- **Supabase:** https://bavfommuelhivrigiafg.supabase.co
- **Website:** https://getchompd.com
- **AI:** Haiku 4.5 (primary), Sonnet 4.6 (fallback)
- **Languages:** EN, PL, DE, FR, ES
- **Local DB:** Isar
- **State:** Riverpod
- **Physical device:** iPhone "Polish" (ID: `00008140-001C446A26C2801C`)
- **Simulator:** iPhone 16e (ID: `53E52169-815E-4AE5-BF3D-79C67347E81A`)
