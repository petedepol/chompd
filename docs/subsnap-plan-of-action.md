# SubSnap — Master Plan of Action

## What We've Completed

| Deliverable | Status | File |
|---|---|---|
| Market research & competitive analysis | ✅ Done | `subsnap-competitor-analysis.html` |
| Freemium model + 5-year financial projections | ✅ Done | `sub-tracker-freemium-model.xlsx` |
| AI scan flow with 3-tier recognition | ✅ Done | `subsnap-scan-v3.jsx` |
| Intelligence flywheel architecture | ✅ Done | Documented in scan flow |
| Pricing & feature split (Free vs Pro) | ✅ Done | In financial model |
| Design direction (dark premium palette) | ✅ Done | In competitor analysis |

---

## Phase 1 — Design & Brand Assets (Before Code)

These should be locked before writing Flutter code so the app has a consistent identity from day one.

### 1.1 Logo & App Icon
**What's needed:**
- App icon (1024×1024 master, exports for iOS/Android)
- Wordmark for splash screen & marketing
- Monochrome variant for receipts/exports

**Direction:** The name "SubSnap" suggests a camera shutter or scan line. Keep it simple — a stylised "S" with a scan/snap motif, mint green accent on dark. Think Revolut's clean geometric icon, not a skeuomorphic camera.

**Options:**
- A) Design it yourself in Figma — cheapest, full control
- B) Use an AI image generator for concepts, refine in Figma
- C) Commission on Fiverr/99designs — £50-150 for a full icon kit

**Recommendation:** Option B. Generate 20+ concepts, pick the strongest, refine manually. The icon is the single most important marketing asset on the App Store.

### 1.2 Colour System (Finalised Tokens)

```
Background:    #0A0A0F  (deep black)
Surface 1:     #14141F  (card bg)
Surface 2:     #1C1C2E  (elevated)
Border:        #2A2A3E
Text Primary:  #E8E8F0
Text Secondary:#8888A8
Accent:        #6EE7B7  (mint green — primary actions)
Accent Dark:   #34D399  (gradient pair)
Warning:       #FBBF24  (amber — trials, expiring)
Danger:        #F87171  (red — overdue, cancelled)
Purple:        #A78BFA  (AI/question indicators)
Blue:          #60A5FA  (info/confirm)
```

**Light theme:** Defer to v1.1. Ship dark-only for launch — it's the premium expectation and halves the design work.

### 1.3 Typography
- **Primary:** SF Pro (iOS) / Google Sans or Inter (Android) — platform native
- **Monospace:** SF Mono / JetBrains Mono — for prices, merchant codes
- **Scale:** 10 / 12 / 14 / 16 / 20 / 28 — six sizes max

### 1.4 Key Animations (Spec Before Build)

| Animation | Where | Duration | Priority |
|---|---|---|---|
| **Scan shimmer** | Screenshot preview during AI analysis | 1.8s loop | P0 — signature moment |
| **Data extraction** | Text highlights appearing on screenshot | 0.3s per field | P0 — makes AI feel "alive" |
| **Checkmark draw** | Confirmed result bubble | 0.4s | P0 — satisfying completion |
| **Toast slide-up** | After "Add to SubSnap" tap | 0.5s in, 0.4s out | P0 — save confirmation |
| **Trial countdown** | Pulsing amber ring on trial subs | 1s subtle pulse | P1 — urgency without anxiety |
| **Confetti burst** | Money saved milestones (£50, £100, etc.) | 1.2s | P1 — gamification |
| **Number roll** | Total spending counter | 0.6s | P1 — dashboard polish |
| **Card entrance** | Subscription cards on home screen | 0.15s stagger | P2 — list polish |
| **Paywall reveal** | Blur + slide when hitting free limit | 0.5s | P2 — soft upsell |

**Implementation:** Use Flutter's built-in animation framework (AnimationController + Tween). Rive or Lottie only for the confetti burst — everything else should be code-driven for smaller APK size.

### 1.5 Service Icons & Branding
- Ship with 50 pre-loaded service icons (Netflix, Spotify, etc.)
- Use brand colours from the service's official palette
- Fallback: First-letter icon with extracted dominant colour
- Source: SimpleIcons.org (free, SVG, 3000+ brands) or manual

---

## Phase 2 — Screen-by-Screen User Flow

### 2.1 Onboarding (4 screens max)

```
Screen 1: Welcome
  "Track every subscription. Never overpay."
  [Get Started] button

Screen 2: How It Works
  "📸 Snap a screenshot → AI reads it → Done"
  Brief animation showing the scan flow

Screen 3: Notification Permission
  "We'll remind you before renewals"
  [Allow Notifications] / [Maybe Later]

Screen 4: First Scan or Manual Add
  "Add your first subscription"
  [📸 Scan Screenshot] (uses 1 of 3 free scans)
  [✏️ Add Manually]
  [Skip for now]
```

### 2.2 Home Screen

```
┌─────────────────────────────────┐
│  SubSnap              ⚙️  [+]  │
│                                 │
│  Monthly Spend                  │
│  £127.94          ▾ This Month  │
│                                 │
│  ⚠️ 1 trial expiring in 3 days │
│                                 │
│  ─── Active (7) ────────────── │
│  [N] Netflix         £15.99/mo  │
│  [S] Spotify         £10.99/mo  │
│  [F] Figma Pro ⏱14d  $9.99/mo  │
│  [Z] Zwift           £17.99/mo  │
│  ...                            │
│                                 │
│  ─── Cancelled (2) ──────────  │
│  [A] Adobe CC    saved £54.99   │
│                                 │
│         💰 £659 saved           │
│                                 │
│  [📸 Scan]  [✏️ Add]           │
└─────────────────────────────────┘
```

### 2.3 AI Scan Screen
Documented in v3 prototype. Flow:
1. Share Sheet / in-app camera → screenshot received
2. Shimmer animation over preview
3. Conversational Q&A if needed (3-tier system)
4. Result card with confirm
5. "Add to SubSnap" → toast confirmation

### 2.4 Subscription Detail Screen

```
┌─────────────────────────────────┐
│  ←  Netflix                     │
│                                 │
│  [N]  Netflix                   │
│  £15.99/month                   │
│                                 │
│  Next renewal: 14 March 2026    │
│  ━━━━━━━━━━━━━━━━━━━━ 22 days  │
│                                 │
│  Reminders                      │
│  ✓ 7 days before     ⟶ PRO    │
│  ✓ 3 days before     ⟶ PRO    │
│  ✓ 1 day before                 │
│  ✓ Morning of                   │
│                                 │
│  History                        │
│  Feb 2026  £15.99               │
│  Jan 2026  £15.99               │
│  Dec 2025  £15.99               │
│                                 │
│  Category: Entertainment        │
│  Added: 8 Feb 2026 via AI Scan  │
│                                 │
│  [Cancel Subscription]          │
└─────────────────────────────────┘
```

### 2.5 Paywall Screen

```
┌─────────────────────────────────┐
│         ✨ Go Pro ✨            │
│                                 │
│  You've hit 3 subscriptions.    │
│  Unlock everything for a        │
│  one-time payment.              │
│                                 │
│  ✓ Unlimited subscriptions      │
│  ✓ Unlimited AI scans           │
│  ✓ Smart reminders (7d,3d,1d)   │
│  ✓ Trial countdown tracking     │
│  ✓ Money saved gamification     │
│  ✓ Widgets + Siri Shortcuts     │
│                                 │
│  ┌─────────────────────────┐    │
│  │     £4.99 one-time      │    │
│  │  No subscription. Ever. │    │
│  └─────────────────────────┘    │
│                                 │
│  [Unlock Pro — £4.99]           │
│  [Restore Purchase]             │
│                                 │
│  "A subscription tracker that   │
│   isn't a subscription." 🎯     │
└─────────────────────────────────┘
```

### 2.6 Settings Screen
- Appearance (dark/light — v1.1)
- Currency preference
- Notification preferences
- Export data (CSV)
- Restore purchase
- Privacy policy / Terms
- Rate app / Share app
- About / Version

---

## Phase 3 — Claude Code Development Plan

### 3.1 Project Structure

```
subsnap/
├── lib/
│   ├── main.dart
│   ├── app.dart                    # Theme, routing
│   ├── config/
│   │   ├── theme.dart              # Colour tokens, typography
│   │   ├── constants.dart          # Free limits, API keys ref
│   │   └── routes.dart
│   ├── models/
│   │   ├── subscription.dart       # Core data model
│   │   ├── merchant.dart           # Intelligence DB model
│   │   └── scan_result.dart        # AI response model
│   ├── services/
│   │   ├── ai_scan_service.dart    # Claude Haiku integration
│   │   ├── merchant_db.dart        # Local intelligence flywheel
│   │   ├── notification_service.dart
│   │   ├── purchase_service.dart   # RevenueCat IAP
│   │   └── storage_service.dart    # Hive/Isar local DB
│   ├── providers/                  # Riverpod state management
│   │   ├── subscriptions_provider.dart
│   │   ├── scan_provider.dart
│   │   └── purchase_provider.dart
│   ├── screens/
│   │   ├── home/
│   │   ├── scan/
│   │   ├── detail/
│   │   ├── onboarding/
│   │   ├── paywall/
│   │   └── settings/
│   ├── widgets/
│   │   ├── subscription_card.dart
│   │   ├── scan_shimmer.dart
│   │   ├── toast_overlay.dart
│   │   ├── trial_badge.dart
│   │   └── money_saved_counter.dart
│   └── utils/
│       ├── currency.dart
│       ├── date_helpers.dart
│       └── share_handler.dart      # Share Sheet extension
├── assets/
│   ├── icons/                      # Service brand icons
│   ├── animations/                 # Lottie files (confetti only)
│   └── fonts/
├── test/
└── pubspec.yaml
```

### 3.2 Tech Stack Decisions

| Layer | Choice | Why |
|---|---|---|
| Framework | Flutter 3.x | Cross-platform, one codebase |
| State | Riverpod | Cleaner than Provider for async, good for AI responses |
| Local DB | Isar | Fast, typed, Flutter-native. Hive backup option |
| AI | Claude Haiku 4.5 via API | $0.0015/scan, best value-to-quality |
| IAP | RevenueCat | Handles Apple/Google receipts, webhook for validation |
| Notifications | flutter_local_notifications | Escalating reminders, scheduled |
| Share Sheet | receive_sharing_intent | Intercept screenshots from other apps |
| Analytics | PostHog or Mixpanel free tier | Conversion funnel, scan success rate |
| Crash reporting | Sentry free tier | Flutter-native, good free tier |

### 3.3 Development Sprints

#### Sprint 1 — Foundation (Week 1-2)
**Goal:** App skeleton, theme, navigation, local DB

Claude Code tasks:
```
- Initialize Flutter project with folder structure
- Implement theme.dart with full colour system
- Set up Riverpod with core providers
- Create Subscription model + Isar schema
- Build home screen layout (static, mock data)
- Build subscription card widget
- Implement bottom navigation / FAB
```

#### Sprint 2 — Core CRUD (Week 3-4)
**Goal:** Manually add, edit, delete subscriptions

Claude Code tasks:
```
- Manual add subscription form (name, price, cycle, category)
- Edit subscription detail screen
- Delete with confirmation
- Quick-add from popular services (pre-loaded templates)
- Category picker with icons
- Billing cycle options (weekly/monthly/quarterly/yearly)
- Local persistence with Isar
```

#### Sprint 3 — AI Scan Engine (Week 5-7)
**Goal:** Screenshot scanning via Claude Haiku, conversational Q&A

Claude Code tasks:
```
- Claude Haiku API integration service
- Screenshot text extraction prompt engineering
- Confidence scoring + 3-tier routing logic
- Conversational Q&A widget (from prototype)
- Merchant intelligence DB (local Isar table)
- Share Sheet integration (receive_sharing_intent)
- Free scan counter (3 scans for free tier)
- Scan result → subscription creation flow
```

**Critical prompt engineering task:**
Design the Claude Haiku system prompt for screenshot analysis. It needs to:
- Extract: service name, price, currency, billing cycle, next renewal date
- Handle: emails, bank statements, app store receipts, payment confirmations
- Return: structured JSON with confidence scores per field
- Flag: trial periods, price changes, multiple subscriptions in one image

#### Sprint 4 — Notifications & Reminders (Week 8)
**Goal:** Escalating reminder system

Claude Code tasks:
```
- Notification permission flow
- Schedule reminders: 7d, 3d, 1d, morning-of
- Free tier: morning-of only
- Pro tier: full escalating set
- Trial expiry countdown notifications
- Notification tap → subscription detail screen
```

#### Sprint 5 — Paywall & IAP (Week 9-10)
**Goal:** RevenueCat integration, paywall screen

Claude Code tasks:
```
- RevenueCat SDK integration
- Paywall screen with feature comparison
- 3-subscription limit enforcement
- 3-scan limit enforcement
- Purchase flow (Apple/Google)
- Restore purchases
- Pro status provider (unlocks features)
```

#### Sprint 6 — Polish & Gamification (Week 11-12)
**Goal:** Animations, money saved, trial tracking

Claude Code tasks:
```
- Scan shimmer animation
- Toast overlay with checkmark draw
- Trial countdown badges + pulsing ring
- Money saved running total
- Cancelled subscription tracking
- Milestone celebrations (confetti at £50, £100, etc.)
- Number roll animation on spending counter
- Empty states (no subs yet, no trials)
```

#### Sprint 7 — Platform Features (Week 13-14)
**Goal:** Widgets, Siri Shortcuts, export

Claude Code tasks:
```
- iOS home screen widget (monthly total)
- Android widget equivalent
- Siri Shortcuts ("What's my monthly spend?")
- CSV export of all subscriptions
- App icon + splash screen
- Onboarding flow (4 screens)
```

#### Sprint 8 — Testing & Launch Prep (Week 15-16)
**Goal:** Bug fixes, App Store assets, beta

```
- Unit tests for AI scan service
- Integration tests for CRUD + IAP
- App Store screenshots (6.7", 6.1", iPad)
- App Store description + keywords
- Privacy policy + terms of service
- TestFlight beta to 10-20 users
- Google Play internal testing
- Fix beta feedback
- Submit for review
```

### 3.4 Claude Code Session Strategy

**How to use Claude Code effectively for this project:**

1. **One sprint = ~3-5 Claude Code sessions**
   - Session 1: Set up structure, models, basic UI
   - Session 2: Business logic, services
   - Session 3: Polish, edge cases, tests

2. **Start each session with context:**
   ```
   "We're building SubSnap, a subscription tracker app.
   Current sprint: [Sprint X — Goal].
   What's done: [list completed files].
   This session: [specific tasks]."
   ```

3. **Commit after each session** — push to GitHub (petedepol/subsnap)

4. **Keep a PROGRESS.md** in the repo root tracking what's done

### 3.5 Backend Considerations

**For v1 launch — no backend required.** Everything runs locally:
- Isar DB on device
- Claude Haiku called directly from app (API key in app, rate-limited)
- RevenueCat handles IAP validation server-side
- Merchant intelligence DB ships as a bundled JSON, updated via app store releases

**For v1.1+ — lightweight backend needed when:**
- Merchant DB needs real-time crowd-sourced updates (not just app releases)
- User count exceeds ~10K and you want server-side scan deduplication
- You add cloud sync across devices

**Backend stack when ready:** Supabase (familiar from CFR app) or Firebase. Edge functions for the Claude API proxy so the API key isn't in the app binary.

---

## Phase 4 — Launch & Growth

### 4.1 App Store Optimisation (ASO)
**Keywords:** subscription tracker, subscription manager, bill tracker, recurring payments, cancel subscriptions, trial tracker
**Title:** SubSnap — AI Subscription Tracker
**Subtitle:** Scan Screenshots. Track Bills. Save Money.

### 4.2 Launch Marketing (Zero Budget)
- Reddit: r/personalfinance, r/frugal, r/apps ("I built a thing" posts)
- Product Hunt launch (aim for a weekday, Tuesday-Thursday)
- Twitter/X: Dev build-in-public thread
- YouTube: 60-second demo video
- App Store "What's New" featuring pitch

### 4.3 Post-Launch Metrics to Track
- Free → Pro conversion rate (target: 4%+)
- AI scan success rate (target: 85%+ first-try accuracy)
- Day 7 retention (target: 30%+)
- Average scans per user in first session
- Paywall view → purchase rate
- Most common Tier 3 merchants (feed back into DB)

---

## Summary — Priority Order

| # | What | When | Effort |
|---|---|---|---|
| 1 | Logo & app icon | This week | 1-2 days |
| 2 | Finalise screen flows in Figma | This week | 2-3 days |
| 3 | Sprint 1: Foundation + theme | Week 1-2 | Claude Code |
| 4 | Sprint 2: Core CRUD | Week 3-4 | Claude Code |
| 5 | Sprint 3: AI Scan (biggest sprint) | Week 5-7 | Claude Code |
| 6 | Sprint 4-5: Notifications + IAP | Week 8-10 | Claude Code |
| 7 | Sprint 6-7: Polish + platform | Week 11-14 | Claude Code |
| 8 | Sprint 8: Test + launch | Week 15-16 | Manual + Claude Code |

**Total estimated timeline: ~16 weeks to App Store submission**
(Faster if you dedicate full days vs. squeezing around race weekends)
