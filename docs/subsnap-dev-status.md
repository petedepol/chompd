# Chompd — Development Status & What's Already Built

> Share this with anyone writing a roadmap so they know what exists.
> Last updated: 9 Feb 2026 (Sprint 12 — Chompd Rebrand & Polish)

---

## Architecture Overview

- **Framework:** Flutter 3.x (Dart SDK >=3.2.0)
- **State Management:** Riverpod (manual StateNotifier pattern — NOT @riverpod codegen)
- **Local Database:** Isar (with codegen via isar_generator)
- **Typography:** Google Fonts (Space Mono for data, system default for UI)
- **Theme:** Dark-only — ChompdColors class with static const colours (mint, amber, red, purple, blue)
- **Monetisation:** Freemium — one-time £4.99 Pro unlock (via PurchaseService)
- **Free tier limits:** 3 subscriptions max, 3 AI scans max
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
│   ├── cancel_guide.dart             (cancel guide model, plain class)
│   ├── refund_template.dart          (refund path data class + RefundPath enum)
│   └── nudge_candidate.dart          (nudge result + NudgeReason enum)
├── data/
│   ├── cancel_guides_data.dart       (20 pre-loaded cancel guides + fuzzy matching)
│   └── refund_paths_data.dart        (4 refund paths + email template builder)
├── providers/
│   ├── subscriptions_provider.dart   (CRUD + mock data + monthly/yearly totals)
│   ├── scan_provider.dart            (scan state + credits + trap flow)
│   ├── purchase_provider.dart        (Pro unlock state)
│   ├── notification_provider.dart    (reminder state)
│   ├── budget_provider.dart          (monthly budget, SharedPreferences)
│   ├── spend_view_provider.dart      (monthly/yearly toggle)
│   ├── trap_stats_provider.dart      (dodged trap statistics)
│   ├── calendar_provider.dart        (renewal date projections)
│   └── nudge_provider.dart           (highest-priority nudge candidate)
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
│   ├── onboarding/onboarding_screen.dart  (4-page intro, PARKED)
│   └── splash/splash_screen.dart     (animated splash, PARKED)
├── services/
│   ├── ai_scan_service.dart          (Claude Haiku 3-tier scan + trap detection)
│   ├── merchant_db.dart              (local brand DB)
│   ├── notification_service.dart     (reminders + aggressive trial alerts)
│   ├── purchase_service.dart         (IAP / Pro unlock)
│   ├── haptic_service.dart           (tactile feedback)
│   └── nudge_engine.dart             (5 heuristic nudge rules)
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
    └── mascot_image.dart             (reusable piranha mascot widget)
```

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
- Various `prefer_const_constructors` lint suggestions throughout (72 info hints, 0 errors, 0 warnings)
- `withOpacity` → `withValues(alpha:)` migration mostly complete
