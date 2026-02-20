# Chompd — Development Status & What's Already Built

> Share this with anyone writing a roadmap so they know what exists.
> Last updated: 19 Feb 2026 (Post-Sprint 20 — Calendar overhaul, detail screen overhaul, cancel/refund localisation)

---

## Architecture Overview

- **Framework:** Flutter 3.x (Dart SDK >=3.2.0)
- **State Management:** Riverpod (manual StateNotifier pattern — NOT @riverpod codegen)
- **Local Database:** Isar (with codegen via isar_generator)
- **Typography:** Google Fonts (Space Mono for data, system default for UI)
- **Theme:** Dark-only — ChompdColors class with static const colours (mint, amber, red, purple, blue)
- **Monetisation:** Freemium — one-time £4.99 Pro unlock (via PurchaseService)
- **Free tier limits:** 3 subscriptions max, 1 AI scan max
- **AI:** Claude Haiku for screenshot scanning (3-tier intelligence flywheel)
- **Mascot:** Unnamed piranha character — small, fast, sharp. Chomps through the fine print.
- **Calendar:** table_calendar ^3.1.2 for renewal calendar view

---

## Sprint History — What's Been Built

### Sprint 1 — Core Data Layer ✅
- **Subscription model** (`lib/models/subscription.dart`) with Isar annotations
  - Fields: name, price, currency, cycle (BillingCycle enum), nextRenewal, category, isTrial, trialEndDate, isActive, cancelledDate, iconName, brandColor, source, createdAt, reminders
  - Computed helpers: daysUntilRenewal, trialDaysRemaining, monthlyEquivalent, yearlyEquivalent, priceDisplay
  - BillingCycle enum: weekly, monthly, quarterly, yearly (with label, shortLabel, approximateDays)
  - SubscriptionSource enum: manual, aiScan, quickAdd
  - ReminderConfig embedded object (daysBefore, enabled, requiresPro)
- **Merchant model** (`lib/models/merchant.dart`) for brand data (logo, colour, category)
- **Scan result model** (`lib/models/scan_result.dart`) for AI scan responses
- **Subscriptions provider** (`lib/providers/subscriptions_provider.dart`) — full CRUD with Riverpod StateNotifier, mock data seeded
- **Theme & constants** (`lib/config/theme.dart`, `lib/config/constants.dart`)
- **Currency utils** (`lib/utils/currency.dart`)
- **Date helpers** (`lib/utils/date_helpers.dart`)

### Sprint 2 — Home Screen & UI Components ✅
- **Home screen** (`lib/screens/home/home_screen.dart`) — scrollable list of subscription cards, spending summary, trial alert banner, cancelled cards section
- **Spending ring** (`lib/widgets/spending_ring.dart`) — animated circular progress showing spend vs budget, tap to toggle monthly/yearly
- **Subscription card** (`lib/widgets/subscription_card.dart`) — glassmorphic card with brand colour, price, renewal date, swipe actions
- **Category bar** (`lib/widgets/category_bar.dart`) — horizontal segmented bar showing spend by category
- **Trial badge** (`lib/widgets/trial_badge.dart`) — amber badge for trial subscriptions
- **Empty state** (`lib/widgets/empty_state.dart`) — illustration + CTA when no subscriptions exist
- **Animated list item** (`lib/widgets/animated_list_item.dart`) — staggered fade-in for list entries
- **Milestone card** (`lib/widgets/milestone_card.dart`) — gamification track showing progress milestones (hardcoded defaults — user wants these editable eventually)

### Sprint 3 — CRUD & Detail Screens ✅
- **Detail screen** (`lib/screens/detail/detail_screen.dart`) — full subscription details with edit/cancel/delete actions, annual cost line under hero price
- **Add/Edit screen** (`lib/screens/detail/add_edit_screen.dart`) — form for manual subscription entry with category picker, billing cycle selector, trial toggle
- **Quick-add sheet** (`lib/widgets/quick_add_sheet.dart`) — bottom sheet with popular services for one-tap addition
- **Routes config** (`lib/config/routes.dart`)

### Sprint 4 — AI Scan & Intelligence ✅
- **AI scan service** (`lib/services/ai_scan_service.dart`) — 3-tier intelligence flywheel:
  - Tier 1: Auto-detect (screenshot → AI identifies service + price + cycle)
  - Tier 2: Quick-confirm (AI result shown, user confirms/edits)
  - Tier 3: Full Q&A (AI couldn't identify, user answers questions)
  - Uses Claude Haiku API for screenshot analysis
  - Mock implementation + mockWithTrap() for trap scenarios
- **Scan screen** (`lib/screens/scan/scan_screen.dart`) — camera/gallery picker → AI processing → result confirmation
- **Scan provider** (`lib/providers/scan_provider.dart`) — manages scan state, credits, trap detection flow
- **Scan shimmer** (`lib/widgets/scan_shimmer.dart`) — loading animation during AI processing
- **Merchant database** (`lib/services/merchant_db.dart`) — local brand data for instant recognition (singleton MerchantDb.instance)
- **Share handler** (`lib/utils/share_handler.dart`) — receives shared screenshots from other apps

### Sprint 5 — Notifications, Paywall & Gamification ✅
- **Notification service** (`lib/services/notification_service.dart`) — local push notifications for renewal reminders + aggressive trial alerts (singleton NotificationService.instance)
- **Notification provider** (`lib/providers/notification_provider.dart`)
- **Paywall screen** (`lib/screens/paywall/paywall_screen.dart`) — Pro upgrade screen with feature comparison, one-time £4.99 purchase
- **Purchase service** (`lib/services/purchase_service.dart`) — handles Pro unlock (singleton PurchaseService.instance)
- **Purchase provider** (`lib/providers/purchase_provider.dart`)
- **Haptic service** (`lib/services/haptic_service.dart`) — tactile feedback (singleton HapticService.instance)
- **Confetti overlay** (`lib/widgets/confetti_overlay.dart`) — celebration animation for milestones
- **Money saved counter** (`lib/widgets/money_saved_counter.dart`) — animated counter showing savings from cancellations
- **Toast overlay** (`lib/widgets/toast_overlay.dart`) — non-intrusive feedback messages

### Sprint 6 — Polish & Bug Fixes ✅
- **Glassmorphic bottom nav bar** — fixed ClipRRect/BackdropFilter rendering (rounded pill shape with backdrop blur)
- **Milestone card overflow** — fixed 3px bottom overflow (height 90→104)
- **Settings screen** (`lib/screens/settings/settings_screen.dart`) built out with sections for preferences, data, and app info

### Sprint 7 — Platform Features ✅ (partially parked)
- **Configurable monthly budget** — `lib/providers/budget_provider.dart` (StateNotifier<double>, default £100, persisted via SharedPreferences)
  - Budget setting in settings screen with 6 preset chips (£50/£75/£100/£150/£200/£300) + custom entry dialog
- **CSV export** — `lib/utils/csv_export.dart`
- **Splash screen** — `lib/screens/splash/splash_screen.dart` (PARKED — user polishing with piranha mascot assets)
- **Onboarding flow** — `lib/screens/onboarding/onboarding_screen.dart` (PARKED — user polishing with piranha mascot assets)
- **App entry flow** — `lib/app.dart` with splash → onboarding → home transitions, onboarding "seen" flag persisted via SharedPreferences
- **Floating Scan FAB** — standalone 64px mint gradient FAB in home_screen.dart (replaced bottom nav bar)
- **Deferred to device testing:** iOS/Android home screen widgets, Siri Shortcuts

### Sprint 8 — Subscription Defence Suite (Tier 0) ✅
- **Trap Scanner (pre-purchase protection)**
  - `lib/models/trap_result.dart` — TrapResult, TrapType enum, TrapSeverity enum
  - `lib/models/dodged_trap.dart` — plain Dart class for dodged trap records (Isar annotations deferred)
  - `lib/models/scan_output.dart` — wraps ScanResult + TrapResult with shouldShowTrapWarning/shouldShowTrialNotice getters
  - `lib/screens/scan/trap_warning_card.dart` — full-screen trap warning overlay with severity badge, price breakdown, skip/track buttons
  - `lib/widgets/severity_badge.dart` — pill badge (HIGH RISK / CAUTION / INFO)
  - `lib/widgets/price_breakdown_card.dart` — animated trial→real price comparison
  - Extended `lib/services/ai_scan_service.dart` with trap detection prompt + mockWithTrap() scenarios
  - Extended `lib/providers/scan_provider.dart` with trapDetected/trapSkipped phases, skipTrap(), trackTrapTrial()
  - Added 9 trap fields to `lib/models/subscription.dart` (isTrap, trapType, trialPrice, trialDurationDays, realPrice, realAnnualCost, trapSeverity, trialExpiresAt, trialReminderSet)
- **Aggressive Trial Alerts**
  - Extended `lib/services/notification_service.dart` with scheduleAggressiveTrialAlerts() — 72h, 24h, 2h before + 2h post-conversion check-in
- **Saved from Traps Counter**
  - `lib/providers/trap_stats_provider.dart` — aggregates dodged trap stats (totalSaved, trapsSkipped, trialsCancelled, refundsRecovered)
  - `lib/widgets/trap_stats_card.dart` — home screen "Unchompd savings" card with shield icon + breakdown
  - Extended `lib/widgets/subscription_card.dart` with trap badge + dual price display
  - Extended `lib/widgets/milestone_card.dart` with 5 Trap Dodger milestones (£50→£1000)

### Sprint 9 — Annual Cost Projection (Tier 1) ✅
- **Yearly cost toggle on spending ring**
  - `lib/providers/spend_view_provider.dart` — SpendView enum (monthly/yearly) + StateProvider toggle
  - Added `yearlySpendProvider` to `lib/providers/subscriptions_provider.dart`
  - Added `yearlyEquivalent` getter to `lib/models/subscription.dart`
  - Rewrote `lib/widgets/spending_ring.dart` — now ConsumerStatefulWidget, self-managing (watches its own providers), tap-to-toggle with re-animated ring, budget scales ×12 in yearly mode, amber ring at >80% budget
  - Home screen simplified: SpendingRing() takes no params
- **Annual cost on detail screen**
  - Added "£X.XX/yr" line under hero price display (only when cycle != yearly)

### Sprint 10 — Calendar View (Tier 1) ✅
- **Renewal calendar**
  - `lib/providers/calendar_provider.dart` — projects 12 months of renewals per subscription, normalises dates, renewalCalendarProvider + daySpendProvider
  - `lib/screens/calendar/calendar_screen.dart` — full calendar screen using table_calendar with:
    - Brand-coloured dots as day markers (up to 4 per day)
    - Tap-a-day detail panel showing each renewing sub with icon, price, cycle
    - Tap a sub row → navigates to detail screen
    - Monthly summary: total renewals, total spend, busiest day amber alert
    - "No renewals this day" empty state
  - Calendar icon in home screen header (next to settings gear)
  - Added `table_calendar: ^3.1.2` to pubspec.yaml

### Sprint 10.1 — Calendar Polish ✅
- **Bigger dots with glow** — dot size increased from 5px to 6px, added BoxShadow glow matching dot colour
- **Bold renewal dates** — custom `defaultBuilder` dims empty dates (textDim, w400), brightens renewal dates (text, w600) for at-a-glance scanability
- **Category-based dot dedup** — dots now use brand colour with category fallback, deduplicated by colour; up to 3 unique dots shown, 4+ shows 2 dots + "+N" count
- **AnimatedSize on day panel** — day detail / monthly summary swap wrapped in AnimatedSize (250ms easeOutCubic) for smooth height transition
- **Tap-to-dismiss** — tapping the same day again deselects it (returns to monthly summary)
- **Selection haptic** — day tap upgraded from `light()` to `selection()` haptic for crisper feedback
- **Edge case fix** — added empty-name guard on icon fallback (`sub.name[0]` → safe access)
- Summary card dark theme confirmed correct (bgCard #111118, bgElevated #1A1A24, mint values, textDim labels)

### Sprint 11 — Defence Suite Part 2 (Cancel Guides + Refund Rescue + AI Nudge) ✅
- **Smart Cancel Guides**
  - `lib/models/cancel_guide.dart` — plain Dart model (Isar deferred) with difficultyLabel getter
  - `lib/data/cancel_guides_data.dart` — 20 pre-loaded cancel guides for major services (Netflix, Spotify, Amazon Prime, Adobe CC, Xbox Game Pass, etc.) + fuzzy matching via `findGuideForSubscription()`
  - `lib/screens/cancel/cancel_guide_screen.dart` — step-by-step cancel UI with difficulty indicator (5-box colour-coded: mint/amber/red), tappable checkboxes with haptic, notes card (amber), "Open Cancel Page" button, "I've Cancelled" (marks sub cancelled), "Get Refund Help" link to Refund Rescue
  - Detail screen "Cancel" button now navigates to cancel guide (with fuzzy match → generic platform fallback)
- **Refund Rescue Guide**
  - `lib/models/refund_template.dart` — RefundPath enum (appStore, googlePlay, directBilling, bankChargeback) + RefundTemplate data class with steps, URL, email template, success rate, timeframe
  - `lib/data/refund_paths_data.dart` — 4 escalation paths with pre-written dispute email template (auto-fills service name, dates, prices from Subscription) + `buildDisputeEmail()` helper
  - `lib/screens/refund/refund_rescue_screen.dart` — two-phase UI: path selector (4 tappable cards with emoji, success rate, timeframe) → step-by-step guide with checkboxes, "Copy Dispute Email" for direct billing path, "Open Refund Page" button, submission confirmation
  - Detail screen now has "Request Refund" purple button linking to Refund Rescue
- **"Should I Keep This?" AI Nudge**
  - `lib/models/nudge_candidate.dart` — NudgeCandidate + NudgeReason enum (trialConverted, expensiveUnreviewed, renewalApproaching, duplicateCategory, annualRenewalSoon)
  - `lib/services/nudge_engine.dart` — 5 heuristic rules: expensive+old (>£10/mo, 90+ days unreviewed), trial converted, renewal approaching (>£15/mo, within 7 days), duplicate category (3+), annual renewal soon (within 30 days). Sorted by priority.
  - `lib/providers/nudge_provider.dart` — manual Riverpod Provider watching subscriptions list, returns highest-priority candidate (frequency limiting deferred to persistence)
  - `lib/widgets/nudge_card.dart` — Dismissible inline card with purple left border, piranha mascot, nudge message, "Review" (→ detail screen) and "I need this" (→ suppress 90 days) buttons. Swipe = dismiss.
  - Added to home screen between category bar and subscription list
  - Added `lastReviewedAt`, `lastNudgedAt`, `keepConfirmed` fields to Subscription model
- **Dependencies:** Added `url_launcher: ^6.2.4` to pubspec.yaml

### Sprint 11.1 — Cancelled Subs Fix ✅
- **Removed hardcoded mock cancelled subs** — deleted `CancelledSub` class and `mockCancelledSubs` list entirely
- **`cancelledSubsProvider`** now derives from the main subscription list: `!isActive && cancelledDate != null`, sorted newest-cancelled first
- **`totalSavedProvider`** now calculates real savings: `monthlyEquivalent × months since cancellation` per sub
- **`_CancelledCard`** in home screen rewritten to accept `Subscription` — reads `iconName`, `brandColor`, `cancelledDate` from the real sub, shows "Just cancelled" for <1 month, fixed `withOpacity` → `withValues(alpha:)`
- Cancelling a sub (via Cancel Guide, swipe, or dialog) now immediately moves it from active list to cancelled section with running savings

### Sprint 12 — Chompd Rebrand & Visual Polish ✅
- **Brand rename** — SubSnap → Chompd throughout app and docs
  - Home screen header: "Chompd" with mint accent on "d"
  - Mascot: Snappy crocodile → unnamed piranha character
- **Piranha mascot integration** — `lib/widgets/mascot_image.dart` (reusable widget with fade-in)
  - Onboarding pages 1 & 2 (piranha_wave.png, piranha_full.png)
  - Empty state (piranha_sleeping.png)
  - Trap stats card (piranha_thumbsup.png)
  - Scan screen thinking indicator (piranha_thinking_anim.gif)
  - Trap warning card (piranha_alert_anim.gif)
  - Over-budget indicator below SpendingRing (piranha_sad.png)
  - Detail screen trap info (piranha_alert.png)
  - Trap skipped celebration view (piranha_celebrate_anim.gif)
- **Floating Scan FAB** — replaced full bottom nav bar with standalone 64px floating action button
  - Mint gradient with breathing glow animation (3.5s cycle) + specular sweep (4s)
  - Tap scale feedback (150ms, 0.92x) + haptic
  - Positioned bottom-right, camera icon, triggers scan/add flow
  - Removed bottom_nav_bar.dart, nav_icons assets, and flutter_svg dependency
- **Trap Scanner gaps closed**
  - Real Claude API integration with `useMockData` toggle in scan_provider.dart
  - DodgedTrap persistence via SharedPreferences
  - trackTrapTrial() wired up with aggressive trial alerts
- **withOpacity → withValues(alpha:)** migration across codebase

### Sprint 13 — iPhone Testing & Quick Add Editable Prices ✅
- **Editable Quick Add Prices** — templates no longer instantly add with hardcoded GBP prices
  - Tapping a template opens an inline edit panel with price, currency, and cycle fields
  - Selected template highlights with brand colour border + tint
  - AnimatedSize panel slides up with smooth 250ms animation
  - Search deselects template if no longer in filtered results
  - Brand-styled "Add [ServiceName]" button, disabled when price invalid
- **European Decimal Input Fix** — comma separator support across all price fields
  - `add_edit_screen.dart` + `quick_add_sheet.dart` both accept commas and auto-replace with dots
  - `FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))` + `TextInputFormatter.withFunction` for comma→dot
- **Price Confirm Tick** — checkmark suffix icon appears in quick add price field when focused
  - Tapping tick dismisses keyboard with light haptic
  - Green mint colour when price is valid, dim when invalid
- **Paywall Screen Overflow Fix** — two overflow issues on iPhone 16e
  - Right overflow (12px): wrapped feature row text in `Expanded`
  - Bottom overflow (48px): replaced Column+Spacer layout with fixed close button + `SingleChildScrollView`
- **Onboarding Visual Polish** — all 4 pages upgraded
  - Page 1: Bigger mascot (220px) with mint glow, "Bite Back" headline, £240/yr stat card
  - Page 2: Step subtitles added for context
  - Page 3: Bigger piranha_alert (160px), amber notification feature pills
  - Page 4: Bigger piranha_celebrate (160px), urgency copy, "Scan a Screenshot" button now opens scan screen
- **Real Notification Permissions** — replaced stub with flutter_local_notifications v20.1.0
  - iOS: `IOSFlutterLocalNotificationsPlugin.requestPermissions(alert, badge, sound)`
  - Android: `AndroidFlutterLocalNotificationsPlugin.requestNotificationsPermission()`
  - AppDelegate.swift: added UNUserNotificationCenter delegate
- **Camera & Photo Permissions** — added `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to Info.plist
- **App Display Name** — changed `CFBundleDisplayName` from "Subsnap" to "Chompd" in Info.plist
- **Quick Add Sheet Overflow Fix** — wrapped edit panel in `Flexible(flex: 0, child: SingleChildScrollView)` to prevent bottom overflow when keyboard opens
- **AI Scan Improvements** (from previous session)
  - Haiku→Sonnet escalation: if Haiku returns low confidence (<80%), auto-retry with claude-sonnet-4-20250514
  - Enhanced extraction prompt for bank statements (handles AMZN DIGITAL, DD patterns)
  - `isNotFound` handling: treats "not found"/"N/A" AI responses as null
  - Expanded `_suggestPrices()` with ~20 popular service prices

### Sprint 14 — Five Targeted Fixes ✅
- **Per-Subscription Reminders** — reminder toggles are now individual per subscription, not global
  - Added `customReminderDays` getter to `Subscription` model — returns enabled days or null (use global default)
  - Added `toggleReminderDay(uid, day)` to `SubscriptionsNotifier` — initialises from global defaults on first use, then toggles per-sub
  - Rewired `_RemindersCard` in detail screen to read/write per-subscription reminders (falls back to global prefs if no custom set)
  - `NotificationService.scheduleReminders()` now checks `sub.customReminderDays` before falling back to tier defaults
- **Alphabetical Sorting** — home screen active subscriptions now sorted A→Z by name
- **Category-Based Card Colours** — subscription card tint/border now uses consistent category colour (via `CategoryColors.forCategory()`)
  - Split `_brandColor` into `_categoryColor` (card accent bar + box shadow) and `_brandColor` (icon gradient only)
  - All Productivity subs now have the same blue surround; icons still show their own AI-detected brand colours
- **Same-Day Spend Inclusion** — `totalPaidSinceCreation` now counts at least 1 payment on the day a subscription is added (was 0 before due to floor division)
- **Calendar Multi-Currency Fix** — all calendar total calculations now use `sub.priceIn(_currencyCode)` instead of raw `sub.price`
  - Fixed: `daySpendProvider` in calendar_provider.dart
  - Fixed: day detail total, monthly summary total, priciest day calc, busiest day display, and day cell glow threshold in calendar_screen.dart
- **AI Prompt Fix: Expires + Trial plan name** — tightened the exception clause in both Haiku and Sonnet prompts
  - Problem: "Annual Premium (7 Day Trial)" + "Expires on 7 October" was misclassified as Trial instead of Expiring
  - The "(7 Day Trial)" in plan name was confusing the AI despite the "Expires" keyword
  - Fix: emphasised "≤7 calendar days" requirement, added concrete example showing that months-away dates do NOT qualify for the exception
  - Changed in both Haiku prompt (line ~632) and Sonnet prompt (line ~822) — identical edits

### Sprint 15 — AI Insights Phase 1 + Phase 2 + Trap Scanner Split ✅
- **AI Insights Phase 1 (Batches I3–I5)** — curated editorial insights synced from Supabase `service_insights` table
  - `lib/models/service_insight.dart` — Isar collection with bilingual fields (EN/PL), `remoteId` unique index, `fromSupabaseMap()`
  - `lib/services/service_insight_repository.dart` — singleton, full-replace sync from Supabase, local-only dismiss, `getForServices()`, `getRandomInsight()`
  - `lib/providers/service_insight_provider.dart` — maps active subscription slugs (via `matchedServiceId` → `ServiceCache.slug`) to insight list
  - `lib/widgets/service_insight_card.dart` — carousel card with tap-to-cycle, dismiss, pagination dots, emoji + accent by `insightType`, `_ProTeaser` for free users
  - Registered `ServiceInsightSchema` in `isar_service.dart`, added sync calls in `main.dart` + connectivity listener
  - Added 6 l10n keys to `app_en.arb` and `app_pl.arb`
  - 14 insights synced from Supabase on first launch
- **AI Insights Phase 2 (Batches I11–I13)** — AI-generated per-user insights synced from Supabase `user_insights` table
  - `lib/models/user_insight.dart` — Isar collection with `userId`, `subscriptionId`, `serviceKey`, `generatedAt`, `expiresAt`, `isRead`, `isDismissed`
  - `lib/services/user_insight_repository.dart` — singleton, user-scoped sync (filters by `AuthService.instance.userId`), dismiss/read sync to Supabase (fire-and-forget), `cleanupExpired()` auto-hides stale insights
  - `lib/models/insight_display_data.dart` — unified display DTO mapping both `ServiceInsight` and `UserInsight` to a common model
  - `lib/providers/combined_insights_provider.dart` — merges AI insights (first) + curated insights (fill remaining), max 3 total, locale-aware
  - Modified `service_insight_card.dart` → reads from `combinedInsightsProvider`, shows ✨ AI badge (purple) on AI-generated insights, dual dismiss (Supabase for AI, local for curated), `markAsRead()` once per session
  - Added `dismissById(int isarId)` to `service_insight_repository.dart` for InsightDisplayData compatibility
  - Registered `UserInsightSchema` in `isar_service.dart` (7th schema), added sync calls in `main.dart`
- **Trap Scanner Split** — separated subscription extraction from trap detection into two parallel API calls
  - Modified `ai_scan_service.dart`: `analyseScreenshotWithTrap()` now uses `Future.wait()` running extraction + `_runTrapScan()` simultaneously
  - New `_trapScanPrompt` getter — dedicated fine-print reading prompt checking 6 trap categories
  - `_extractionPrompt` cleaned: removed TASK 2 trap section, focused on subscription data only
  - `_runTrapScan()` never throws — returns `TrapResult.clean` on failure

### Sprint 15.1 — Trial Implementation Wiring + Scanner Fix ✅
- **Trial system wiring** (compile errors fixed, l10n added, UI connected)
  - Added trial constants to `constants.dart`: `trialDurationDays = 7`, `trialProductId`, `proProductId`, updated `freeMaxScans: 3→1`, `scanCostEstimate: 0.0015→0.006`
  - Removed duplicate `isProProvider` from `purchase_provider.dart` (entitlement_provider's version is canonical)
  - Added `freezeExcess()`, `unfreezeAll()`, `reactivate()` methods to `SubscriptionsNotifier`
  - Added `frozenSubsProvider` derived provider
  - Added `PaywallTrigger.trialExpired` to enum + case in paywall_screen.dart
  - Added ~16 l10n keys to both `app_en.arb` and `app_pl.arb` (trial banner, prompt, expired, cancelled status, scan errors)
  - Wired `TrialBanner` into home screen (SliverToBoxAdapter between scan button and spending ring)
  - Wired trial prompt + expired triggers in `app.dart` (WidgetsBindingObserver, app resume recheck)
  - Made cancelled subs tappable in home screen (GestureDetector → DetailScreen, chevron icon)
  - Added cancelled state UI in detail screen (red status banner, reactivate button, hides reminders/renewal)
  - Fixed savings calculation guard (null `cancelledDate` → falls back to `createdAt`)
  - Friendly scan error messages in `scan_provider.dart`
  - Empty bytes guard in `ai_scan_service.dart`
- **Scanner fix** — two issues resolved:
  - Edge Function call now **opt-in** via `--dart-define=USE_EDGE_FUNCTION=true` (was always-on when Supabase URL present, caused 404 on every scan since function not deployed)
  - Single `_apiKey` top-level constant replaces duplicate `String.fromEnvironment` calls
  - Diagnostic `debugPrint` logs key length on each direct API call
  - `errorMessage` in scan catch blocks sanitised from `e.toString()` to `'scan_error'` (prevents raw API errors leaking to UI)
- **Trial verification findings** (investigated but not all fixed):
  - ✅ Isar `isActive` field — fully implemented
  - ❌ Frozen sub UI — backend only, no visual treatment (needs building)
  - ✅ Savings accumulation — fully implemented
  - ✅ Trial banner slim strip — fully implemented
  - ❌ Scan limit UI on home screen — not implemented
  - ⚠️ Feature gates — entitlement getters exist but no screen uses them yet (all still use raw `isProProvider`)

### Sprint 16 — Trap Scenarios, Currency Fixes, Paste Scanner, Quick-Add Rework, UX Polish ✅

**Session 1 — Bug Fixes & Features:**
- **Debug error messages** — scan_provider.dart catch blocks (lines ~366, ~1139) now show truncated actual error text instead of generic "Couldn't read this image" message (temporary for debugging)
- **Trap detection for non-trial scenarios** — trap scanner now handles 5 scenario types:
  - `trial_to_paid` — classic trial bait (original behaviour)
  - `renewal_notice` — upcoming renewal at current price
  - `price_increase` — price going up on renewal
  - `new_signup` — new subscription offer with hidden costs
  - `other` — anything else suspicious
  - Updated `_trapScanPrompt` in ai_scan_service.dart with new JSON schema (`scenario`, `current_price`, `future_price`, `current_billing_cycle`, `future_billing_cycle`)
  - Added `scenario` field to `TrapResult` model
  - `price_breakdown_card.dart` now branches on scenario: renewal shows single centred "RENEWS AT" price, price_increase shows "NOW"/"THEN" columns, trial_to_paid shows original "TODAY"/"THEN" layout
- **"NOT EVERYTHING IS A TRAP" guidance** — added explicit instructions to trap scan prompt preventing false positives on transparent renewal emails
- **Scenario field passthrough fix** — root cause bug: `scenario` was being dropped during TrapResult copy at line ~467 in ai_scan_service.dart when adding `serviceName`
- **Debug logging for scenario** — `_runTrapScan` logs parsed scenario value
- **Currency fixes:**
  - `_CancelledCard` in home_screen.dart converted from StatelessWidget to ConsumerWidget, now uses `monthlyEquivalentIn(displayCurrency)` matching `totalSavedProvider` calculation
  - Verified all subscription creation paths (quick add, manual, AI scan single/multi) correctly set currency — no fix needed
  - Verified first-launch currency detection chain (PlatformDispatcher → Platform.localeName → USD fallback) — no fix needed
- **Paste Text scanner** — third input method alongside camera/gallery:
  - Added "Paste email text" button to scan_screen.dart (outlined style, `Icons.content_paste`)
  - Added `_PasteTextSheet` bottom sheet with multiline TextField (max 5000 chars, min 6 lines), purple-gradient "Scan Text" button
  - Added `startTextScan()` to scan_provider.dart (mirrors `startTrapScan` but calls text analysis methods)
  - Added `analyseText()`, `analyseTextWithTrap()`, `_runTrapScanFromBody()`, `_textExtractionPrompt`, `_textTrapScanPrompt` to ai_scan_service.dart
  - Text scan counts toward scan limits, supports Haiku→Sonnet escalation
  - Added l10n keys: `pasteEmailText`, `pasteTextHint`, `scanText`, `textReceived` (EN + PL)
- **Quick-add sheet simplification** — major rewrite of quick_add_sheet.dart:
  - `ServiceTemplate` stripped to just `name`, `category`, `icon`, `brandColor` (removed `price`, `currency`, `cycle`)
  - Removed entire inline edit panel (`_EditPanelContent`, `_buildEditPanel`, `_selectTemplate`, `_quickAdd`, all state)
  - `_TemplateRow` simplified to icon + name + category + green "+" button (no price display)
  - Tap now pops sheet and opens `AddEditScreen` with prefill params
  - Added `prefillName`, `prefillCategory`, `prefillIcon`, `prefillBrandColor` to `AddEditScreen`

**Session 2 — Savings Bug + Cancel Flow + UX Polish:**
- **Savings total bug fix** — `totalSavedProvider` changed from `_allCancelledSubsProvider` (includes dismissed) to `cancelledSubsProvider` (visible only). Header total now matches the sum of visible cancelled cards. Added temporary debug logging showing each sub's contribution to total.
- **Cancel questionnaire removed** — replaced `_showCancelReasonSheet()` (bottom sheet with 5 emoji reason options + skip) with simple `AlertDialog`: "Cancel {name}?" with "Keep" and "Cancel Subscription" buttons. Removed `_CancelReason` class entirely. Added `cancelSubscriptionConfirm` l10n key (EN + PL).
- **Quick-add price field confirm** — Added `TextInputAction.done` + `onFieldSubmitted: (_) => _save()` to price field in AddEditScreen. User can now type price and tap keyboard Done button to save immediately without scrolling.
- **Cancel celebration overlay polish:**
  - Changed backdrop from `c.bg.withValues(alpha: 0.92)` to `Colors.black.withValues(alpha: 0.85)` — proper modal dark backdrop
  - Wrapped content in `SafeArea` + horizontal padding to prevent top clipping
  - Added `textAlign: TextAlign.center` to all text widgets
  - "tap anywhere to continue" upgraded: `Colors.white.withValues(alpha: 0.6)` with dark `Shadow`, font size 11→12

---

## Current File Structure

```
lib/
├── main.dart
├── app.dart                          (splash → onboarding → home flow)
├── config/
│   ├── constants.dart
│   ├── routes.dart
│   └── theme.dart                    (dark theme, mint + purple palette)
├── models/
│   ├── subscription.dart             (Isar model + BillingCycle enum)
│   ├── subscription.g.dart           (generated)
│   ├── merchant.dart                 (brand data)
│   ├── merchant.g.dart               (generated)
│   ├── scan_result.dart              (AI scan response)
│   ├── scan_output.dart              (ScanResult + TrapResult wrapper)
│   ├── trap_result.dart              (trap detection model + enums)
│   ├── dodged_trap.dart              (dodged trap record, plain class)
│   ├── service_insight.dart          (Isar: curated editorial insights)
│   ├── service_insight.g.dart        (generated)
│   ├── user_insight.dart             (Isar: AI-generated per-user insights)
│   ├── user_insight.g.dart           (generated)
│   ├── insight_display_data.dart     (unified display DTO for carousel)
│   ├── cancel_guide.dart             (cancel guide model, plain class)
│   ├── refund_template.dart          (refund path data class + RefundPath enum)
│   ├── nudge_candidate.dart          (nudge result + NudgeReason enum)
│   └── entitlement.dart              (UserTier enum + Entitlement class with 8 feature gate getters)
├── data/
│   ├── cancel_guides_data.dart       (20 pre-loaded cancel guides + fuzzy matching)
│   └── refund_paths_data.dart        (4 refund paths + email template builder)
├── providers/
│   ├── subscriptions_provider.dart   (CRUD + freeze/unfreeze + cancel/reactivate + monthly/yearly totals)
│   ├── scan_provider.dart            (scan state + credits + trap flow)
│   ├── purchase_provider.dart        (Pro unlock state + PaywallTrigger enum)
│   ├── entitlement_provider.dart     (trial/pro tier management, isProProvider, trialDaysRemaining)
│   ├── notification_provider.dart    (reminder state)
│   ├── budget_provider.dart          (monthly budget, SharedPreferences)
│   ├── spend_view_provider.dart      (monthly/yearly toggle)
│   ├── trap_stats_provider.dart      (dodged trap statistics)
│   ├── calendar_provider.dart        (renewal date projections)
│   ├── nudge_provider.dart           (highest-priority nudge candidate)
│   ├── currency_provider.dart        (supported currencies list + helpers)
│   ├── service_insight_provider.dart (curated insights by user's service slugs)
│   └── combined_insights_provider.dart (merges AI + curated, max 3)
├── screens/
│   ├── home/home_screen.dart         (main list + spending ring + calendar/settings icons)
│   ├── detail/detail_screen.dart     (sub details + cancel guide + refund rescue)
│   ├── detail/add_edit_screen.dart   (manual CRUD form)
│   ├── scan/scan_screen.dart         (AI screenshot scanner)
│   ├── scan/trap_warning_card.dart   (trap detection overlay)
│   ├── calendar/calendar_screen.dart (renewal calendar view)
│   ├── cancel/cancel_guide_screen.dart  (step-by-step cancel instructions)
│   ├── refund/refund_rescue_screen.dart (refund path selector + steps)
│   ├── settings/settings_screen.dart (preferences, budget, export)
│   ├── paywall/paywall_screen.dart   (Pro upgrade)
│   ├── onboarding/onboarding_screen.dart  (4-page intro, polished with mascot + glow effects)
│   ├── trial/trial_prompt_screen.dart     (glassmorphic trial start modal)
│   ├── trial/trial_expired_screen.dart    (glassmorphic trial expired modal with stats)
│   └── splash/splash_screen.dart     (animated splash)
├── services/
│   ├── ai_scan_service.dart          (Claude Haiku 3-tier scan + trap detection, direct API primary, Edge Function opt-in)
│   ├── merchant_db.dart              (local brand DB)
│   ├── notification_service.dart     (reminders + aggressive trial alerts)
│   ├── purchase_service.dart         (IAP / Pro unlock)
│   ├── haptic_service.dart           (tactile feedback)
│   ├── nudge_engine.dart             (5 heuristic nudge rules)
│   ├── storage_service.dart          (Isar local DB operations)
│   ├── auth_service.dart             (anonymous + OAuth auth, Apple/Google sign-in)
│   ├── sync_service.dart             (Supabase sync, push/pull/merge, hard delete)
│   ├── service_insight_repository.dart (curated insight sync + dismiss)
│   └── user_insight_repository.dart  (AI insight sync + dismiss/read + expiry cleanup)
├── utils/
│   ├── csv_export.dart               (RFC 4180 export)
│   ├── currency.dart
│   ├── date_helpers.dart
│   └── share_handler.dart            (share intent receiver)
└── widgets/
    ├── spending_ring.dart            (ConsumerStatefulWidget, tap-to-toggle mo/yr)
    ├── subscription_card.dart        (glassmorphic sub card + trap badge)
    ├── category_bar.dart             (spend by category)
    ├── milestone_card.dart           (savings + trap dodger milestones)
    ├── money_saved_counter.dart      (animated savings total)
    ├── trial_badge.dart              (trial warning badge)
    ├── severity_badge.dart           (trap severity pill)
    ├── price_breakdown_card.dart     (trial→real price animation)
    ├── trap_stats_card.dart          (home screen trap savings card)
    ├── empty_state.dart              (no-subs placeholder)
    ├── animated_list_item.dart       (staggered list animation)
    ├── quick_add_sheet.dart          (popular services sheet)
    ├── confetti_overlay.dart         (celebration animation)
    ├── toast_overlay.dart            (feedback messages)
    ├── scan_shimmer.dart             (scan loading animation)
    ├── nudge_card.dart               (inline "should I keep this?" card)
    ├── mascot_image.dart             (reusable piranha mascot widget)
    ├── trial_banner.dart             (slim ~36px Pro trial strip, self-hiding)
    └── service_insight_card.dart     (unified insight carousel card + AI badge)
```

### Sprint 17 — Localisations, Theme Contrast, CSV Fix, Budget Defaults, Cancel/Annual UX ✅

**Session 1 (continued from Sprint 16):**

- **Savings calculation bug fix** — `totalSavedProvider` was including dismissed cancelled subs; changed to use `cancelledSubsProvider` (visible only) so header total matches visible card amounts
- **Cancel questionnaire removed** — replaced multi-step cancel reason bottom sheet with simple "Cancel {name}?" AlertDialog confirmation dialog. Added `cancelSubscriptionConfirm` l10n key to EN and PL
- **Price field Done button** — added `TextInputAction.done` + `onFieldSubmitted: (_) => _save()` to price field in `AddEditScreen`
- **Cancel celebration overlay polish** — dark backdrop (`Colors.black α0.85`), `SafeArea` + `Center`, centred text, improved "tap anywhere" contrast with shadow

**Session 2:**

- **German, French, Spanish localisations** — created `app_de.arb`, `app_fr.arb`, `app_es.arb` (475 keys each). Informal tone (du/tu/tú), concise for mobile UI. Fixed German typographic quote encoding (Unicode escapes for `„"` in JSON). All 5 locale files generate cleanly via `flutter gen-l10n`
- **Removed "Open Cancel Page" button** — removed `_handleOpenCancelPage()`, `_buildOpenCancelPageButton()`, and conditional render block from `cancel_guide_screen.dart`. URLs were unmaintained; step-by-step instructions suffice. Removed unused `dart:developer` import
- **Dark theme text contrast bump** — `textMid`: `#8A9B95` → `#A6B6B0` (+20%), `textDim`: `#5A6B65` → `#70837D` (+20%). Readable at low screen brightness while still visually dim/mid
- **Annual savings card — actionable hint** — added hint line under each service name: "Check your {name} account settings for annual billing options". New l10n key `annualSavingsHint` in all 5 locales
- **CSV export fix (active subs only + share sheet)** — filtered export to `isActive` subs only (was including cancelled/deleted ghosts). Replaced silent temp-file write with `Share.shareXFiles` from `share_plus` to open iOS share sheet
- **Country-based default budget** — added `_countryToDefaultBudget` map in `budget_provider.dart` with country-specific defaults (US $50, UK £35, DE/AT/CH €40, FR/ES/IT €35, PL 100zł, AU/CA $45, JP ¥3000). Detects country from device locale (same approach as currency provider). Fallback chain: country → currency → $40 default

**Files modified/created:**
- `lib/providers/subscriptions_provider.dart` — totalSavedProvider fix
- `lib/screens/cancel/cancel_guide_screen.dart` — cancel questionnaire → dialog, removed Open Cancel Page button
- `lib/screens/detail/add_edit_screen.dart` — price field Done action
- `lib/widgets/cancel_celebration.dart` — overlay polish
- `lib/widgets/annual_savings_card.dart` — actionable hint per service row
- `lib/config/theme.dart` — textMid/textDim contrast bump
- `lib/providers/budget_provider.dart` — country-based default budgets
- `lib/screens/settings/settings_screen.dart` — CSV export active-only filter + share sheet
- `lib/l10n/app_en.arb` — new keys (cancelSubscriptionConfirm, annualSavingsHint)
- `lib/l10n/app_pl.arb` — new keys
- `lib/l10n/app_de.arb` — **NEW** — full German translation
- `lib/l10n/app_fr.arb` — **NEW** — full French translation
- `lib/l10n/app_es.arb` — **NEW** — full Spanish translation
- `docs/subsnap-dev-status.md` — this file

### Sprint 18 — Error Handling, Frozen UI, Entitlement Migration, Pro Upsell Gating, Auth Fix ✅

**PROMPT 3: Offline / Error State Handling**

- **3 new exception classes** in `ai_scan_service.dart`: `NoConnectionException` (SocketException/TimeoutException/HttpException), `ApiLimitException` (HTTP 429), `ApiUnavailableException` (HTTP 500/502/503)
- **`_callDirectApi()`** — wrapped HTTP POST in try/catch mapping network errors to specific exceptions; added status code checks for 429 and 5xx before generic error throw
- **`_callApi()`** — added rethrow clauses for new exceptions so they don't get swallowed by Edge Function fallback
- **`scan_provider.dart`** — updated catch blocks for both `startTrapScan` and `startTextScan` with user-friendly messages per exception type. Generic catch now shows "Something went wrong" instead of raw error dumps

**PROMPT 4: Frozen Subscription UI**

- **Frozen section on home screen** — `frozenSubsProvider` watched, rendered between active and cancelled sections
- **`_FrozenCard` widget** — 0.5 opacity, service icon + name, "Tap to upgrade" subtitle, dimmed price, amber "🔒 FROZEN" badge chip
- **Tap action** → opens PaywallScreen with haptic feedback
- **Section header** — lock icon + "FROZEN — UPGRADE TO UNLOCK" in dim text
- **New l10n keys** — `frozenSectionHeader`, `frozenBadge`, `frozenTapToUpgrade` in all 5 locales (EN, PL, DE, FR, ES)

**PROMPT 5: Feature Gates Migration**

- **Migrated ALL `isProProvider` consumers** to use granular entitlement feature gates from `entitlementProvider`
- `purchase_provider.dart` — `canAddSubProvider`/`canScanProvider`/`remainingSubsProvider`/`remainingScansProvider` now use `ent.hasUnlimitedSubs`/`ent.hasUnlimitedScans`/`ent.maxSubscriptions`/`ent.maxScans`
- `home_screen.dart` — limit badges show only when `ent.isFree`
- `scan_screen.dart` — scan counter uses `ent.hasUnlimitedScans`
- `detail_screen.dart` — reminder toggles use `ent.hasSmartReminders`; `_ReminderRow.isPro` renamed to `showProBadge`
- `service_insight_card.dart` — AI insights teaser uses `ent.hasFullDashboard`
- `settings_screen.dart` — Pro section, reminder schedule card, timeline dots all use entitlement gates
- **Zero consumers of `isProProvider` remain** — definition kept for backward compat

**PROMPT 6: Hide Pro Upsell for Pro/Trial Users**

- **Reminder PRO badges** (detail_screen) — only show for free users (`!hasSmartReminders`)
- **Settings Pro upgrade section** — hidden when `ent.isFree` is false (Pro AND trial users)
- **Settings tier display** — now shows "Pro" (mint), "Trial (Xd)" (amber), or "Free" (dim)
- **Timeline dots lock icons** — only show when `!hasSmartReminders`
- **Home screen limit badges** — only show when `ent.isFree`
- **AI insights teaser** — only show when `!hasFullDashboard`
- **New l10n key** — `tierTrial` in all 5 locales

**PROMPT 7: Fix AuthNotifier Dispose Error**

- **Root cause**: `auth.onAuthStateChange.listen()` subscription was never stored or cancelled
- **Fix**: stored subscription in `StreamSubscription<dynamic>? _authSub`, added `dispose()` override that cancels it, added `if (!mounted) return` guard in listener

**PROMPT 8: Piranha Scan Button** (continued from previous session)

- Replaced 52×52 mint gradient camera icon button with 64×64 circular ClipOval showing `scan_button.png`
- Added press animation with `AnimatedScale` (0.92 on tap-down, 1.0 on release, 100ms)

**PROMPT 9: Onboarding Visual Cleanup** (continued from previous session)

- Standardised all 4 onboarding pages: shared constants (`_mascotSize = 140`, `_topPadding = 40`, etc.)
- Unified layout: `FadeTransition` → `SingleChildScrollView` with shared constants
- Bottom navigation pinned at fixed position, page-specific buttons via separate builders

**PROMPT 10: App Store Review Prompt** (continued from previous session)

- Added `in_app_review: ^2.0.11` package
- Created `ReviewService` singleton — tracks scan count + cancel count, 90-day cooldown, thresholds: 3+ scans OR 1+ cancels
- Integrated in `scan_screen.dart` (after saves) and `cancel_guide_screen.dart` (after cancel celebrations)

**Files modified:**
- `lib/services/ai_scan_service.dart` — exception classes, `_callDirectApi()` error handling, `_callApi()` rethrow
- `lib/providers/scan_provider.dart` — user-friendly catch blocks
- `lib/screens/home/home_screen.dart` — frozen section, entitlement migration
- `lib/widgets/service_insight_card.dart` — entitlement migration
- `lib/providers/purchase_provider.dart` — entitlement migration, removed `constants.dart` import
- `lib/screens/scan/scan_screen.dart` — entitlement migration
- `lib/screens/detail/detail_screen.dart` — entitlement migration, `showProBadge` rename
- `lib/screens/settings/settings_screen.dart` — entitlement migration, tier display, `hasSmartReminders`/`showLock` renames
- `lib/providers/auth_provider.dart` — dispose fix, stream subscription cleanup
- `lib/screens/onboarding/onboarding_screen.dart` — visual cleanup
- `lib/services/review_service.dart` — **NEW**
- `lib/screens/cancel/cancel_guide_screen.dart` — review service integration
- `lib/l10n/app_*.arb` (all 5) — new keys: `frozenSectionHeader`, `frozenBadge`, `frozenTapToUpgrade`, `tierTrial`
- `pubspec.yaml` — `in_app_review`, `assets/images/`
- `docs/subsnap-dev-status.md` — this file

### Sprint 19 — Notifications Wired to OS, Scan L10n, Calendar Currency Fix, Multilingual Insights, Piranha Scan Messages ✅

**PROMPT 1: iPad Share Sheet Fix**

- Added `sharePositionOrigin` to `Share.shareXFiles` call in CSV export — iPad requires a source rect for the share popover
- Uses `context.findRenderObject() as RenderBox` to derive origin rect, with `Rect.fromLTWH(0, 0, 100, 100)` fallback

**PROMPT 2: Fun Piranha-Themed Scan Messages**

- Replaced 9 hardcoded English scan status messages with piranha-themed copy
- Updated 3 existing l10n keys (`scanAnalysing`, `textReceived`, `analysing`) + added 4 new keys (`scanSniffing`, `scanFoundFeast`, `scanEscalation`, `scanAlmostDone`)
- All 5 ARB files (EN, PL, DE, FR, ES) have complete translations

**PROMPT 3: Annual Savings Insight — Yearly Cycle Filter**

- Added yearly billing cycle guard to `combined_insights_provider.dart`
- Now watches `subscriptionsProvider` and skips `annual_saving` insights when the user's matching subscription is already on `BillingCycle.yearly`
- Guard applies to both AI-generated and curated insight loops
- `AnnualSavingsCard` already had this filter; `combinedInsightsProvider` was missing it

**PROMPT 4: Wire NotificationService to OS-Level Notifications**

- Added `timezone` as direct dependency in `pubspec.yaml` (was only transitive)
- Added `tz.initializeTimeZones()` in `NotificationService.init()`
- Created `_scheduleOSNotification()` method — converts `DateTime` → `tz.TZDateTime.from(dt, tz.local)`, calls `_plugin.zonedSchedule()` with `AndroidScheduleMode.inexactAllowWhileIdle`
- Wired all 7 `_scheduled.add()` call sites to also call `await _scheduleOSNotification(notification)`
- Changed `cancelReminders()` from `void` to `Future<void>` — now cancels each OS notification via `_plugin.cancel(id:)` before clearing from `_scheduled`
- Changed `cancelAll()` from `void` to `Future<void>` — calls `_plugin.cancelAll()` before `_scheduled.clear()`
- Morning digest cancel now collects existing digest notification IDs and cancels each via `_plugin.cancel(id:)` before `removeWhere`
- Added `_restorePendingNotifications()` — queries `_plugin.pendingNotificationRequests()` at startup, logs count
- Added `debugFireTestNotification()` — fires immediate test notification via `_plugin.show()`
- **v20 API fix**: all `flutter_local_notifications` v20.1.0 methods use named parameters (not positional) — `zonedSchedule(id:, title:, body:, scheduledDate:, notificationDetails:, androidScheduleMode:)`, `cancel(id:)`, `show(id:, title:, body:, notificationDetails:)`
- External callers (`detail_screen.dart`, `notification_provider.dart`) use fire-and-forget pattern (no await needed)

**PROMPT 5: ServiceInsight Multilingual (DE/FR/ES)**

- Added 9 new nullable fields to `ServiceInsight` Isar model: `titleDe`, `titleFr`, `titleEs`, `bodyDe`, `bodyFr`, `bodyEs`, `actionLabelDe`, `actionLabelFr`, `actionLabelEs`
- Updated `fromSupabaseMap()` to parse corresponding Supabase columns
- Ran `build_runner` to regenerate Isar codegen (`service_insight.g.dart`)
- `combined_insights_provider.dart` updated: replaced `isPl` boolean with full `lang` string, added `_localized()` helper function for 5-language switching (EN/PL/DE/FR/ES) with English fallback
- Added `_StringExt.ifEmpty()` extension for nullable actionLabel handling

**PROMPT 6: Scan Messages L10n + Calendar Currency Thresholds**

- **Scan messages wired to l10n** — `ScanNotifier` now has `_l10n` field + `_getL10n()` async method
  - Reads `SharedPreferences.getString('user_locale')` → `lookupS(Locale(langCode))` (same pattern as NotificationService)
  - All 9 scan status messages now use l10n keys instead of hardcoded English
  - Added imports for `shared_preferences`, `widgets`, `app_localizations`
- **Calendar glow/biggest-day thresholds converted to display currency**
  - Root cause: `daySpend` was correctly in display currency (via `priceIn()`), but comparison thresholds (30/50) were hardcoded GBP amounts
  - EUR users barely missed amber threshold (€35.10 < 50), PLN users triggered red on any day (150zł ≥ 50)
  - Added `_thresholdAmber` and `_thresholdRed` getters using `ExchangeRateService.instance.convert(30/50, 'GBP', _currencyCode)`
  - Replaced all 6 hardcoded `>= 30` / `>= 50` comparisons in calendar_screen.dart

**PROMPT 7: Multi-Scan Result Card L10n**

- Added 7 new l10n keys for the multi-subscription scan result checklist card
- `scanFoundCount` (parameterised: int count), `scanTapToExpand`, `scanCancelledHint`, `scanAlreadyCancelled`, `scanExpires`, `scanSkipAll`, `scanAddSelected` (parameterised: int count)
- All 5 ARB files (EN, PL, DE, FR, ES) have complete translations
- Replaced all 7 hardcoded English strings in `_MultiChecklistMessageState` with `context.l10n.*` calls

**PROMPT 8: Scan Status Duplication + Subscription Descriptions + Date Locale**

- **Scan AppBar subtitle removed** — dynamic `scanAnalysing` subtitle was duplicating the chat bubble status message; removed the `if (scanState.phase == ScanPhase.scanning)` subtitle block entirely
- **Subscription card descriptions replaced with localised categories** — English descriptions from Supabase `services.description` replaced with `AppConstants.localisedCategory(sub.category, context.l10n)`. Removed unused `_serviceDescription` getter and `serviceCacheProvider` import
- **Date formatting made locale-aware** — rewrote `DateHelpers.shortDate()` and `monthYear()` to use `DateFormat` from intl package with optional `{String? locale}` parameter. Removed hardcoded English month arrays. Updated all call sites:
  - `subscription.dart` — `localRenewalLabel()` now accepts `{String? locale}` param
  - `subscription_card.dart` — passes `Localizations.localeOf(context).languageCode`
  - `detail_screen.dart` — all 9 `shortDate()` calls now locale-aware
  - `calendar_screen.dart` — all 3 `shortDate()` calls now locale-aware
  - `scan_screen.dart` — replaced local `_formatShortDate()` with `DateHelpers.shortDate()` + locale

**Files modified:**
- `lib/screens/settings/settings_screen.dart` — iPad sharePositionOrigin
- `lib/providers/scan_provider.dart` — piranha messages → l10n wiring
- `lib/providers/combined_insights_provider.dart` — yearly cycle filter + multilingual `_localized()` helper
- `lib/services/notification_service.dart` — OS notification scheduling, cancel, restore, debug test
- `lib/models/service_insight.dart` — 9 new DE/FR/ES fields + `fromSupabaseMap()` update
- `lib/models/service_insight.g.dart` — regenerated Isar codegen
- `lib/screens/calendar/calendar_screen.dart` — currency-aware thresholds + locale-aware dates
- `lib/screens/scan/scan_screen.dart` — AppBar subtitle removed, multi-scan l10n, locale-aware dates
- `lib/widgets/subscription_card.dart` — category labels replace English descriptions, locale-aware renewal dates
- `lib/models/subscription.dart` — `localRenewalLabel` gains `{String? locale}` param
- `lib/utils/date_helpers.dart` — rewritten to use `DateFormat` with locale param
- `lib/screens/detail/detail_screen.dart` — all `shortDate()` calls now locale-aware
- `lib/l10n/app_en.arb` — 4 scan message keys + 7 multi-scan keys
- `lib/l10n/app_pl.arb` — 4 scan message keys + 7 multi-scan keys
- `lib/l10n/app_de.arb` — 4 scan message keys + 7 multi-scan keys
- `lib/l10n/app_fr.arb` — 4 scan message keys + 7 multi-scan keys
- `lib/l10n/app_es.arb` — 4 scan message keys + 7 multi-scan keys
- `pubspec.yaml` — `timezone: ^0.10.0` direct dependency

### Sprint 20 — Calendar Overhaul, Detail Screen Overhaul, Cancel/Refund Localisation ✅

**Task 1: Calendar Screen Visual Upgrade**

- **1A — Biggest day pill bug fix** — removed ALL threshold conditions from biggest day pill visibility. Changed from `priciestSpend >= _thresholdAmber` to simply `priciest != null`. Styled with coral `Color(0xFFFF6B5A)` and 🔥 emoji prefix
- **1B/1D — Scrollable category chips** — changed category breakdown from `Wrap` to `SingleChildScrollView(scrollDirection: Axis.horizontal) > Row` with `asMap().entries.map()` for indexed spacing
- **1F — Spring animation on day selection** — converted `_HeatMapDayCell` from `StatelessWidget` → `StatefulWidget` with `SingleTickerProviderStateMixin`. Added `TweenSequence` spring animation (1.0→1.15x easeOut → 1.15→1.0x elasticOut, 300ms). Triggered on selection transition. Added `HapticFeedback.selectionClick()` from `flutter/services.dart`. Selected state has intensified glow BoxShadow

**Task 2: Detail Screen Visual Overhaul**

- **2A — Hero section redesign** — converted `DetailScreen` from `ConsumerWidget` → `ConsumerStatefulWidget`. Added ambient glow (RadialGradient behind icon, brand color @ 25% opacity), price count-up animation (Tween<double> 0→price, 600ms, easeOut), AI scan provenance badge, `_GlowTier` enum (low/medium/high/max based on price thresholds 5/15/30) controlling border/shadow intensity
- **2B — Scroll-linked hero collapse** — SKIPPED per spec guidance (too complex for this pass)
- **2C — Payment timeline** — new `_PaymentTimeline` widget with vertical timeline structure. `_TimelineRow` widget with 1.5px connecting lines (white @ 0.08), coloured dots (past: mint @ 0.7, 8px; upcoming: mint 10px with glow BoxShadow)
- **2D — Reminder fire dates** — `_RemindersCard` now takes `nextRenewal` parameter. Each `_ReminderRow` shows concrete fire date calculated as `nextRenewal.subtract(Duration(days: daysBefore))`. Section header has 🔔 emoji. Toggle inactive track: `Colors.white.withValues(alpha: 0.12)`
- **2E — Annual plan section** — hides entirely when no annual data (no dead end). Green glow border when savings exist: `mint @ 0.5, 1.5px` + `BoxShadow(mint @ 0.15, blur: 10)`
- **2F — Details section polish** — thinner dividers (0.5px via static `_thinDivider()` method), category dot, simplified "Added" row to date only
- **2G — Action buttons redesign** — cancel guide button first (constructive, mint text + external link icon), delete de-emphasised (text-only, iOS System Red `#FF453A`, 13px, centred). Glassmorphic delete dialog: `BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8))`
- **2H — Press micro-interactions** — `_PressableButton` and `_PressableIconButton` widgets: scale to 0.97x on press with 100ms `AnimatedScale` + `HapticFeedback.selectionClick()`

**Cancel Guides + Refund Rescue Localisation (from prior session)**

- All 4 refund templates (Apple, Google Play, Direct Billing, Bank Chargeback) now have `nameLocalized`, `stepsLocalized`, `successRateLocalized`, `timeframeLocalized`, `emailTemplateLocalized` maps (PL/DE/FR/ES)
- `RefundTemplate` model extended with helper methods: `getName(lang)`, `getSteps(lang)`, `getSuccessRate(lang)`, `getTimeframe(lang)`, `getEmailTemplate(lang)` — all fall back to English
- `refund_rescue_screen.dart` uses `_lang` getter throughout
- All ~30 cancel guides in `cancel_guides_data.dart` have PL/DE/FR/ES translations
- `CancelGuide` model extended with `nameLocalized`, `stepsLocalized`, `notesLocalized` + helper methods
- `cancel_guide_screen.dart` uses locale-aware getters
- Detail screen description section removed (was showing English descriptions)

**Key technical lessons:**
- `_ChompdColorSet` is private to `theme.dart` — cannot be used as parameter type in other files. Use hardcoded colours or pass via constructor
- `AnimatedBuilder` (Flutter's animation builder widget) used for spring animation on day cells
- `_thinDivider()` must be a static method with no parameters since it can't reference `_ChompdColorSet`

**Files modified:**
- `lib/screens/calendar/calendar_screen.dart` — biggest day pill fix, scrollable chips, spring animation
- `lib/screens/detail/detail_screen.dart` — complete visual overhaul (hero, timeline, reminders, actions, micro-interactions)
- `lib/models/refund_template.dart` — localised field maps + getter methods
- `lib/data/refund_paths_data.dart` — PL/DE/FR/ES translations for all 4 refund paths + email templates
- `lib/screens/refund/refund_rescue_screen.dart` — locale-aware rendering throughout
- `lib/models/cancel_guide.dart` — localised field maps + getter methods
- `lib/data/cancel_guides_data.dart` — PL/DE/FR/ES translations for ~30 cancel guides
- `lib/screens/cancel/cancel_guide_screen.dart` — locale-aware rendering

---

## What's Left To Build

### Tier 0 — Remaining
- ❌ **Dark Pattern Database** (v1.2+) — crowdsourced service trust scores. Needs backend.

### Tier 1 — Remaining
- ❌ **Home Screen Widgets** — iOS (WidgetKit) + Android widgets. Deferred to device testing.

### Tier 2 — Differentiators (v1.1)
- ❌ **Price Change Detection** — track historical prices, alert on increases
- ❌ **Shared / Family Tracking** — split costs among housemates
- ❌ **Renewal Day Optimisation** — histogram of spending by day-of-month

### Tier 3 — Growth & Viral (v1.2+)
- ❌ **Chompd Wrapped** — Spotify Wrapped-style year in review. Target Dec 2026.
- ❌ **Anonymous Benchmarking** — opt-in spending comparisons.

### Tier 4 — Future Vision (v2.0)
- ❌ **Bank Feed Integration** (Open Banking / Plaid / TrueLayer)
- ❌ **Subscription Marketplace / Deals**
- ❌ **Cross-Device Sync** (iCloud / Supabase)

---

## Key Design Decisions Already Made

1. **No bank connection needed** — privacy-first approach; AI scan + manual entry only
2. **One-time purchase, not subscription** — £4.99 Pro unlock
3. **Free tier is generous** — 3 subs + 3 scans lets users experience core value
4. **Mock services throughout** — all services have mock implementations for rapid prototyping
5. **Isar codegen deferred** — DodgedTrap is a plain Dart class; Subscription.g.dart exists but may need regeneration
6. **Dark theme only** — no light mode planned for v1
7. **GBP default currency** — UK-first market with USD/EUR support
8. **Piranha mascot** — piranha character — chomps through the fine print
9. **Manual Riverpod** — StateNotifier pattern, NOT @riverpod codegen
10. **ChompdColors is a static utility class** — `ChompdColors._()` private constructor, all colours are static const. NOT instance-based.
11. **Relative imports** — `import '../config/theme.dart'` NOT `import 'package:subsnap/...'`

---

## Known Issues / Tech Debt

- `dodged_trap.g.dart` doesn't exist — DodgedTrap is intentionally a plain class for now. Isar annotations deferred to when persistence is wired up.
- `widget_test.dart` references old `MyApp` class — stale test file
- Various `prefer_const_constructors` lint suggestions throughout (62 info hints, 0 errors, 0 warnings)
- `withOpacity` → `withValues(alpha:)` migration mostly complete
- **Pro override REVERTED** in `purchase_provider.dart` — free tier limits now enforced
- Anthropic API key baked into app via `--dart-define` — move to proxy server at scale
- Edge Function `ai-scan` exists locally but **not deployed** on Supabase — app uses direct API (opt-in via `--dart-define=USE_EDGE_FUNCTION=true`)
- ~~Entitlement getters exist but no screen uses them yet~~ **RESOLVED Sprint 18** — all feature gates migrated to granular entitlement properties, `isProProvider` has zero consumers
- ~~Frozen subscription UI not built~~ **RESOLVED Sprint 18** — `_FrozenCard` widget + frozen section on home screen
- Quick add templates no longer show prices — tap opens full AddEditScreen with name/category/icon prefilled
- ~~`flutter_local_notifications` v20.1.0 — notifications are scheduled in-memory only~~ **RESOLVED Sprint 19** — all 7 scheduling points now call `zonedSchedule` for OS-level delivery, cancel methods wired to plugin
- `debugFireTestNotification()` in `notification_service.dart` — remove before App Store submission
- Temporary debug `debugPrint` statements in `totalSavedProvider` (subscriptions_provider.dart) and `_runTrapScan` (ai_scan_service.dart) — remove before release
- ~~Temporary debug error messages in scan_provider.dart catch blocks~~ **RESOLVED Sprint 18** — replaced with user-friendly messages per exception type
- `isProProvider` definition still exists in `entitlement_provider.dart` (zero consumers) — can be removed in a future cleanup pass
