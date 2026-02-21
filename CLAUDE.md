# Chompd — AI Subscription Defence

## Project Overview
Chompd is a freemium subscription tracking & defence app built in Flutter. Its core differentiator is AI-powered screenshot scanning — users share a screenshot of a confirmation email, bank statement, or app store receipt, and Claude Haiku extracts the subscription details automatically. Its headline feature is the **Trap Scanner** — pre-purchase dark pattern detection that warns users BEFORE they get charged.

**Brand concept:** Your subscriptions are chomping through your money. Chompd fights back. The name works as both the problem ("you just got chompd") and the solution ("chomp back").

## Brand & Mascot
- **App name:** Chompd
- **Mascot:** Unnamed piranha character — small, fast, sharp. Chomps through the fine print, bites back at dark patterns.
- **Mascot personality:** Friendly but fierce. Not cute-helpless — more like a scrappy ally who's always looking out for you. Quick-witted, slightly mischievous. Think Duolingo owl energy but for money.
- **Mascot poses/assets:**
  - `piranha_full.png` — Original with phone (scanning)
  - `piranha_wave.png` — Welcome, return visits
  - `piranha_celebrate.png` — Milestones, wins, savings
  - `piranha_thinking.png` — Scan processing, considering
  - `piranha_sleeping.png` — Empty states, nothing to show
  - `piranha_sad.png` — Errors, over budget
  - `piranha_thumbsup.png` — Scan success, confirmation
  - `piranha_alert.png` — Trap detected, warning mode
- **Tone of voice:** Friendly, slightly cheeky, never corporate. Talks like a mate, not a bank. "That £1 is bait. You'll get chomped for £99.99 in 3 days."

## Taglines & Marketing Language
- **Primary tagline:** "Bite back at subscriptions"
- **Alternative taglines:** "Don't get chompd" · "Your money's being eaten alive" · "See what's really chomping your cash"
- **App Store title:** Chompd — Subscription Defence
- **App Store subtitle:** Scan. Track. Bite back.
- **Feature language:**
  - "Saved from Traps" → **"Unchompd"** — money you didn't let subscriptions chomp
  - Trap Dodger milestones → "First Bite Back" · "Chomp Spotter" · "Dark Pattern Destroyer" · "Subscription Sentinel" · "Unchompable"
  - Wrapped feature → **"Chompd Wrapped"**
  - AI scan persona → "You are Chompd, an AI that analyses screenshots..."

## The Story (App Store / TikTok / Landing Page)
"My wife signed up for a £1 health scan. Three days later, she was charged £100 for a full year — buried in the fine print she never saw.

I looked for an app to prevent this. They all track what you're already paying. None of them warn you BEFORE you get trapped.

So I built Chompd.

Screenshot any subscription offer. Chompd reads the fine print, spots the trap, and tells you the real price. If you go ahead anyway, it'll remind you before the trial converts — not after.

Your subscriptions shouldn't be smarter than you."

## Business Model
- **Free tier:** 3 subscriptions max, manual entry only, 1 free AI scan, basic reminders (day-of only)
- **Pro unlock:** £4.99 one-time purchase — unlimited subs, unlimited AI scans, smart escalating reminders (7d/3d/1d/morning-of), trial countdown, money saved gamification, widgets + Siri Shortcuts
- **AI costs:** Claude Haiku 4.5 at ~$0.0015/scan — negligible even at scale

## Tech Stack
| Layer | Choice |
|---|---|
| Framework | Flutter 3.x (cross-platform iOS + Android) |
| State management | Riverpod |
| Local database | Isar |
| AI backend | Claude Haiku 4.5 via Anthropic API |
| In-app purchases | RevenueCat |
| Notifications | flutter_local_notifications |
| Share Sheet | receive_sharing_intent |
| Analytics | PostHog (free tier) |
| Crash reporting | Sentry (free tier) |

## Project Structure
```
chompd/
├── lib/
│   ├── main.dart
│   ├── app.dart                    # Theme, routing
│   ├── config/
│   │   ├── theme.dart              # Colour tokens, typography
│   │   ├── constants.dart          # Free limits, API config
│   │   └── routes.dart
│   ├── models/
│   │   ├── subscription.dart       # Core data model (includes trap fields)
│   │   ├── merchant.dart           # Intelligence DB model
│   │   ├── scan_result.dart        # AI response model
│   │   ├── scan_output.dart        # Combined scan + trap result
│   │   ├── trap_result.dart        # Trap detection result model
│   │   ├── dodged_trap.dart        # Logged avoided traps (Isar)
│   │   ├── cancel_guide.dart       # Cancel guide Isar model
│   │   ├── refund_template.dart    # Refund path data class
│   │   └── nudge_candidate.dart    # AI nudge result model
│   ├── services/
│   │   ├── ai_scan_service.dart    # Claude Haiku integration
│   │   ├── merchant_db.dart        # Local intelligence flywheel
│   │   ├── notification_service.dart
│   │   ├── purchase_service.dart   # RevenueCat IAP
│   │   └── storage_service.dart    # Isar local DB
│   ├── providers/                  # Riverpod state management
│   │   ├── subscriptions_provider.dart
│   │   ├── scan_provider.dart      # Includes trap detection states
│   │   ├── purchase_provider.dart
│   │   ├── trap_stats_provider.dart # Unchompd savings counter
│   │   └── nudge_provider.dart     # AI nudge state
│   ├── data/
│   │   ├── cancel_guides_data.dart # Pre-loaded cancel guides (~30 services)
│   │   └── refund_paths_data.dart  # 4 refund paths with templates
│   ├── screens/
│   │   ├── home/
│   │   ├── scan/
│   │   │   └── trap_warning_card.dart  # Trap detection warning overlay
│   │   ├── cancel/
│   │   │   └── cancel_guide_screen.dart # Step-by-step cancel instructions
│   │   ├── refund/
│   │   │   └── refund_rescue_screen.dart # Refund path selector + guide
│   │   ├── detail/
│   │   ├── onboarding/
│   │   ├── paywall/
│   │   └── settings/
│   ├── widgets/
│   │   ├── subscription_card.dart
│   │   ├── scan_shimmer.dart
│   │   ├── toast_overlay.dart
│   │   ├── trial_badge.dart
│   │   ├── money_saved_counter.dart
│   │   ├── severity_badge.dart     # Trap severity indicator
│   │   ├── price_breakdown_card.dart # Trial → real price visual
│   │   ├── trap_stats_card.dart    # Home screen Unchompd savings counter
│   │   ├── nudge_card.dart         # Inline subscription review nudge
│   │   └── mascot_image.dart       # Reusable piranha mascot widget
│   └── utils/
│       ├── currency.dart
│       ├── date_helpers.dart
│       └── share_handler.dart
├── assets/
│   ├── icons/                      # Service brand icons
│   ├── mascot/                     # Piranha mascot assets (PNGs + animated GIFs)
│   │   ├── piranha_full.png        # Original with phone
│   │   ├── piranha_wave.png        # Welcome, return visits
│   │   ├── piranha_celebrate.png   # Milestones, wins
│   │   ├── piranha_thinking.png    # Scan processing
│   │   ├── piranha_sleeping.png    # Empty states
│   │   ├── piranha_sad.png         # Errors, over budget
│   │   ├── piranha_alert.png       # Trap detected warning
│   │   └── piranha_thumbsup.png    # Scan success
│   ├── animations/                 # Lottie (confetti only)
│   └── fonts/
├── docs/                           # Design docs & reference
├── test/
└── pubspec.yaml
```

## Design System

### Colour Tokens (Dark Theme — ship dark-only for v1)
```dart
static const bg = Color(0xFF07070C);
static const bgCard = Color(0xFF111118);
static const bgElevated = Color(0xFF1A1A24);
static const border = Color(0xFF242436);
static const text = Color(0xFFF0F0F5);
static const textMid = Color(0xFFA0A0B8);
static const textDim = Color(0xFF6A6A82);
static const mint = Color(0xFF6EE7B7);       // Primary accent
static const mintDark = Color(0xFF34D399);    // Gradient pair
static const amber = Color(0xFFFBBF24);       // Trials/warnings
static const red = Color(0xFFF87171);          // Overdue/cancel
static const purple = Color(0xFFA78BFA);       // AI indicators
static const blue = Color(0xFF60A5FA);         // Info/confirm
```

### Typography
- **UI text:** System default (SF Pro on iOS, Roboto on Android)
- **Data/prices:** Space Mono (monospace) — for prices, dates, counters
- **Scale:** 10 / 12 / 14 / 16 / 20 / 28

### Key Animations
- Scan shimmer: sweeping light over screenshot during AI analysis (1.8s loop)
- Checkmark draw: SVG path animation on confirmed result (0.4s)
- Toast slide-up: save confirmation with service icon (0.5s in, 0.4s out)
- Number roll: spending counter transitions (0.6s)
- Trial pulse: amber glow on trial badges (1.5s subtle pulse)
- Confetti: Lottie animation for savings milestones only
- Chomp bite: quick bite animation on trap detection (piranha chomps through the fine print)

## AI Scan Architecture — 3-Tier Intelligence Flywheel

### How scanning works:
1. User shares screenshot via Share Sheet or in-app
2. Check local merchant DB first (instant match = no API call, $0.00)
3. If no match, send to Claude Haiku for analysis ($0.0015)
4. If AI confidence < 90%, ask 1-3 clarification questions
5. User confirms → answer stored in merchant DB → next user gets instant match

### Three tiers:
- **Tier 1 — Auto-detect:** Unambiguous merchants (NETFLIX.COM). No question, no API call.
- **Tier 2 — Quick Confirm:** Learned from users. "78% say this is Kindle Unlimited. Right?" Single tap to confirm.
- **Tier 3 — Full Question:** New/ambiguous. Multiple choice: "Which Microsoft service is this?"

### Merchant DB schema:
```dart
class Merchant {
  String pattern;        // e.g. "AMZN DIGITAL*7.99"
  String resolvedName;   // e.g. "Kindle Unlimited"
  double confidence;     // 0.0 - 1.0
  int tier;              // 1, 2, or 3
  int userCount;         // how many users confirmed this
  String? icon;
  String? color;
}
```

### Claude Haiku prompt should extract:
- Service name, price, currency, billing cycle
- Next renewal date, trial status, trial end date
- Confidence score per field
- Handle: emails, bank statements, app store receipts, payment confirmations

## Subscription Model
```dart
class Subscription {
  String id;
  String name;
  double price;
  String currency;           // GBP, USD, EUR
  BillingCycle cycle;        // weekly, monthly, quarterly, yearly
  DateTime nextRenewal;
  String category;
  bool isTrial;
  DateTime? trialEndDate;
  bool isActive;
  DateTime? cancelledDate;
  String? iconName;
  String? brandColor;
  String source;             // 'manual', 'ai_scan', 'quick_add'
  DateTime createdAt;
  List<ReminderConfig> reminders;

  // Trap Scanner fields
  bool? isTrap;
  String? trapType;          // 'trial_bait', 'price_framing', etc.
  double? trialPrice;
  int? trialDurationDays;
  double? realPrice;
  double? realAnnualCost;
  String? trapSeverity;      // 'low', 'medium', 'high'
  DateTime? trialExpiresAt;
  bool trialReminderSet = false;

  // Nudge fields
  DateTime? lastReviewedAt;
  DateTime? lastNudgedAt;
  bool keepConfirmed = false;
}
```

## Trap Scanner (Headline Feature)
Chompd's core differentiator: pre-purchase dark pattern detection. The existing AI scan is extended to detect subscription traps (deceptive trials, hidden renewals, price framing) and warn users BEFORE they get charged.

**Key flows:**
- Scan screenshot → AI detects trap → warning card with real price breakdown → user skips (saves money) or tracks trial (aggressive alerts set)
- Tracked trials get push notifications at 72h, 24h, and 2h before auto-conversion
- Skipped traps add to "Unchompd" counter on home screen
- Milestone track: "First Bite Back" → "Unchompable"

**See:** `docs/chompd-trap-scanner-build.md` for full implementation spec with code.

## Defence Suite
The complete anti-subscription defence loop:
1. **Trap Scanner** — pre-purchase dark pattern detection (v1.0)
2. **Aggressive Trial Alerts** — 72h/24h/2h push notifications before auto-conversion (v1.0)
3. **Unchompd Counter** — running total of money saved from traps + gamification milestones (v1.0)
4. **Smart Cancel Guides** — step-by-step cancellation instructions per service (v1.1)
5. **Refund Rescue** — platform-specific refund guides + dispute email templates (v1.1)
6. **AI Nudge** — periodic "Are you still using this?" prompts (v1.2)
7. **Dark Pattern Database** — community-powered trap reports + trust scores (v1.2+)

## Milestones — "Unchompd" Track
```dart
static const chompMilestones = [
  Milestone(amount: 50, title: 'First Bite Back', icon: '🦷', track: 'chomp'),
  Milestone(amount: 100, title: 'Chomp Spotter', icon: '🔍', track: 'chomp'),
  Milestone(amount: 250, title: 'Dark Pattern Destroyer', icon: '⚔️', track: 'chomp'),
  Milestone(amount: 500, title: 'Subscription Sentinel', icon: '🏰', track: 'chomp'),
  Milestone(amount: 1000, title: 'Unchompable', icon: '👑', track: 'chomp'),
];
```

## Free Tier Limits
- Max 3 subscriptions (accelerates paywall)
- Max 1 AI scan lifetime (enough to experience magic, then paywall)
- Reminders: morning-of only (Pro gets 7d/3d/1d/morning-of)

## Sprint Plan
See `docs/chompd-plan-of-action.md` for full 8-sprint breakdown.

**Sprint order:**
1. Foundation — project skeleton, theme, nav, models, home screen layout
2. Core CRUD — add/edit/delete subscriptions manually
3. AI Scan — Claude Haiku integration, conversational Q&A, merchant DB
4. Notifications — escalating reminders, trial countdown alerts
5. Paywall & IAP — RevenueCat, limit enforcement, paywall screen
6. Polish — animations, money saved gamification, trial badges
7. Platform — widgets, Siri Shortcuts, export, onboarding, **Trap Scanner**
8. Launch prep — tests, App Store assets, beta

## Feature Roadmap Summary

### v1.0 — Launch
- Manual CRUD, AI scan, Trap Scanner, aggressive trial alerts, Unchompd counter, reminders, paywall, annual cost projection, calendar view

### v1.1 — Fast Follow (1-2 months post-launch)
- Cancel guides, Refund Rescue, shared/family tracking, price change detection, renewal day optimisation, home screen widgets

### v1.2 — Growth (3-4 months post-launch)
- Chompd Wrapped (target Dec 2026), Dark Pattern Database, AI nudges, anonymous benchmarking, iCloud sync

### v2.0 — Vision
- Open Banking integration, subscription marketplace/deals, web dashboard

## Reference Docs
- `docs/subsnap-plan-of-action.md` — Full plan with wireframes and sprint details
- `docs/subsnap-trap-scanner-build.md` — Trap Scanner implementation spec (code-ready)
- `docs/subsnap-trap-scanner-spec.md` — Trap Scanner feature/product spec
- `docs/subsnap-defence-suite-part2-build.md` — Cancel Guides + Refund Rescue + AI Nudge build spec
- `docs/subsnap-design-trends-2026.md` — Design system & trends reference
- `docs/subsnap-feature-roadmap.md` — Feature roadmap with Tier 0-4 priorities
- `docs/subsnap-onboarding-content.md` — Onboarding screens with mascot + copy
- `docs/subsnap-calendar-polish.md` — Calendar screen visual refinements
- `docs/subsnap-quick-fixes.md` — SharedPreferences bug fixes (budget + onboarding)
- `docs/subsnap-dev-status.md` — Development status & what's already built
- `docs/subsnap-bottom-nav-spec.md` — Bottom nav bar design spec (legacy — replaced by floating FAB)
- `docs/subsnap-annual-cost-build.md` — Annual cost projection build spec
- `docs/subsnap-dev-status.md` — Development status & what's already built (Sprint 13)

## Code Style
- Use trailing commas for Flutter widget trees
- Prefer const constructors where possible
- Group imports: dart, flutter, packages, local
- One widget per file for screens, shared widgets can be grouped
- Riverpod: manual `StateNotifier` pattern (NOT `@riverpod` codegen)
- `withValues(alpha: x)` NOT `withOpacity(x)` — project convention
- `Subscription.formatPrice(amount, currencyCode)` for all price display — never manual concatenation
- European decimal: all price fields must accept commas and auto-replace with dots

## Important Notes
- Ship dark theme only for v1 (light theme in v1.1)
- No backend needed for v1 — everything local + direct API calls
- API key will be in the app binary for v1 (move to proxy server at scale)
- RevenueCat handles IAP receipt validation server-side
- Test on both iOS and Android throughout development
- Company registered in Poland, targeting global market
- Domain: chompd.app (or getchompd.com) — register early
- Trademark: file with UPRP (Poland) and consider EUIPO (EU-wide) for Class 9/42
