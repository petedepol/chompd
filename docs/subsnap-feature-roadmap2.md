# SubSnap — Feature Roadmap & Ideas Bank

> Revisit these one by one. Tick them off as they get built.
> Each feature includes: what it is, why it matters, complexity estimate, and when to build it.

---

## Tier 0 — Subscription Defence Suite (THE Differentiator)

> Full spec: subsnap-trap-scanner-spec.md

### 0a. Trap Scanner (Pre-Purchase Protection)
**What:** User screenshots a suspicious "£1 trial" offer → SubSnap AI reads the fine print → warns them of the real cost before they sign up. Snappy appears: "That £1 is bait. You'll be charged £99.99 in 3 days."
**Why:** No other sub tracker does pre-purchase scanning. This turns SubSnap from tracker to defence tool. Born from a real story — worth building the entire marketing around.
**Complexity:** Medium — extends existing AI scan with trap detection prompt. No new APIs.
**Sprint:** 🔥 Sprint 7-8 — SHIP WITH LAUNCH.

### 0b. Aggressive Trial Alerts
**What:** Multi-stage push notifications for tracked trials: 72hrs, 24hrs, and 2hrs before auto-conversion. The 2hr alert links directly to cancellation instructions.
**Why:** Passive "expires in 2 days" badges don't work. People need loud, timed warnings.
**Complexity:** Medium — flutter_local_notifications with scheduled offsets.
**Sprint:** 🔥 Sprint 6-7 — SHIP WITH LAUNCH.

### 0c. Saved from Traps Counter
**What:** Running total of money saved by dodging traps + cancelling trials in time. Feeds into milestones ("Trap Dodger" → "Dark Pattern Destroyer" → "The Untrappable").
**Why:** The reward loop. Makes defence feel like a game. Feeds SubSnap Wrapped.
**Complexity:** Low — counter + display on existing data.
**Sprint:** 🔥 Sprint 7-8 — SHIP WITH LAUNCH.

### 0d. Refund Rescue Guide
**What:** Step-by-step refund instructions per platform (App Store, Google Play, direct billing, bank chargeback). Pre-written dispute email templates that auto-fill with service details.
**Why:** Extends cancel guides into money recovery. Rocket Money charges for this.
**Complexity:** Medium — content creation + template system.
**Sprint:** ⭐ v1.1 — fast follow after launch.

### 0e. Dark Pattern Database (Community-Powered)
**What:** Crowdsourced database of services with dark pattern reports. Trust scores. "847 SubSnap users reported unexpected charges from this app."
**Why:** Network effect — gets more valuable with every user. Viral potential.
**Complexity:** High — needs backend + moderation.
**Sprint:** 📋 v1.2+ — start collecting data from day 1, surface when volume is sufficient.

---

## Tier 1 — Quick Wins (Add to Current Sprints)

### 1. Annual Cost Projection
**What:** Show yearly total alongside monthly. "Your subscriptions cost £1,147.76/year" displayed prominently on home screen, toggleable between monthly/yearly.
**Why:** Monthly costs feel manageable. Yearly costs trigger action. This is the single most effective "wake up call" feature in subscription trackers.
**Complexity:** Low — pure math on existing data.
**Where:** Home screen spending ring (tap to toggle mo/yr), subscription detail screen.
**Sprint:** Can add now — just a display calculation.

### 2. Calendar View
**What:** Month calendar showing which days you get charged. Each day shows coloured dots for each sub renewing. Tap a day to see the breakdown.
**Why:** Visually powerful. "I have 4 renewals hitting on the 15th totalling £64" is an insight no list view gives you. None of the screenshot-based trackers have this.
**Complexity:** Medium — needs a calendar widget + mapping renewal dates.
**Where:** New tab or toggle on home screen (list view ↔ calendar view).
**Sprint:** Sprint 6-7. Use `table_calendar` Flutter package.

### 3. Home Screen Widgets
**What:** iOS widget (WidgetKit) and Android widget showing:
  - Small (2x2): Monthly total + days until next renewal
  - Medium (4x2): Monthly total + next 3 upcoming renewals
  - Large (4x4): Full list with trial warnings highlighted
**Why:** Daily passive exposure without opening the app. Keeps SubSnap top-of-mind and useful.
**Complexity:** Medium-High — native platform code required (Swift for iOS, Kotlin for Android).
**Where:** Already in Sprint 7 plan.
**Sprint:** Sprint 7 (Platform features).

---

## Tier 2 — Differentiators (v1.0 Polish or v1.1)

### 4. Smart Cancel Guides
**What:** When a user taps "Cancel Subscription," show step-by-step instructions for that specific service. E.g., "Netflix: Open netflix.com → Account → Cancel Membership → Confirm."
**Why:** Rocket Money charges a premium for cancellation assistance. SubSnap includes it free in Pro. Removes the friction that stops people actually cancelling.
**Complexity:** Medium — needs a database of cancellation steps per service. Start with top 50 services manually, then crowdsource.
**Data structure:**
```dart
class CancelGuide {
  String serviceName;
  List<CancelStep> steps;    // ordered instructions
  String? directLink;         // deep link to cancel page if available
  String? difficulty;         // 'easy', 'medium', 'hard'
  DateTime lastVerified;
}
```
**Where:** Subscription detail screen → "Cancel" button → shows guide before confirming.
**Sprint:** v1.1 — needs content creation for the initial guide database.

### 5. Price Change Detection
**What:** Track historical prices per subscription. When a user updates a price (manually or via AI scan), compare to previous. Alert: "Netflix increased from £10.99 to £15.99. You're now paying £60/year more."
**Why:** Massive engagement trigger. Users often don't notice gradual price creep. Being told "your subs went up £127 this year without you doing anything" is powerful.
**Complexity:** Low-Medium — store price history array on each subscription, compare on update.
**Data structure:**
```dart
class PriceHistory {
  double price;
  DateTime date;
  String source;  // 'manual', 'ai_scan', 'price_alert'
}
// Add List<PriceHistory> priceHistory to Subscription model
```
**Where:** Push notification on price change + badge on subscription card + section in detail screen showing price timeline.
**Sprint:** v1.1 — model change is simple, notification logic needs thought.

### 6. "Should I Keep This?" AI Nudge
**What:** Periodic smart prompt based on subscription age and self-reported usage. "You've had Audible for 8 months. Have you used it recently?" with three options: Keep / Cancel / Remind me in 30 days.
**Why:** The hardest part of subscription management isn't tracking — it's deciding. This gentle nudge at the right moment drives cancellations (and savings).
**Logic:**
  - Trigger after 3 months of tracking a sub
  - Re-trigger every 90 days if user taps "Remind me"
  - Never nudge within 7 days of a trial expiry (separate alert handles that)
  - User can disable per-sub or globally
**Complexity:** Medium — needs a nudge scheduling system + notification logic.
**Where:** Push notification → opens detail screen with the question card.
**Sprint:** v1.2 — needs usage self-reporting UI first.

### 7. Shared / Family Tracking
**What:** Tag subscriptions as "shared" and assign how many people split the cost. Display "Your share: £3.33/mo" alongside the full £9.99. Optional: name the people sharing.
**Why:** Couples and housemates need this. "We pay £180/mo on subscriptions but my share is actually £94." Clarifies true personal spend.
**Complexity:** Low — just a divisor field on the subscription model.
**Data:**
```dart
// Add to Subscription model
int sharedWith;          // default 1 (just me), 2+ = shared
List<String>? sharedNames;  // optional: ["Me", "Sarah", "Tom"]
// Display: price / sharedWith = "Your share"
```
**Where:** Subscription add/edit form → "Shared?" toggle → number picker. Home screen total can show "Your share: £X" vs "Total: £Y".
**Sprint:** v1.1 — simple model addition + UI.

### 8. Renewal Day Optimisation
**What:** Insight card on home screen: "You have 6 renewals totalling £87 on the 15th. Consider spreading them out." Shows a histogram of spending by day-of-month.
**Why:** Feels genuinely smart. Helps users avoid cash-flow crunches. Easy to build, impressive to show.
**Complexity:** Low — pure data analysis on existing renewal dates.
**Where:** Insights section on home screen or a dedicated "Insights" tab.
**Sprint:** v1.1 — quick calculation, needs UI for the histogram/insight card.

---

## Tier 3 — Growth & Viral (v1.2+)

### 9. SubSnap Wrapped (Year in Review)
**What:** Annual summary (triggered in December or on the user's app anniversary):
  - Total spent on subscriptions this year
  - Most expensive subscription
  - Total money saved from cancellations
  - Number of trials successfully dodged
  - Number of AI scans used
  - "Subscription personality" (e.g., "The Streamer" if mostly entertainment)
  - Generates a shareable card (Instagram Stories 9:16, Twitter 16:9)
**Why:** Spotify Wrapped is the most viral feature in consumer tech. A "SubSnap Wrapped" costs nothing to build and is pure organic marketing. Users share it → friends discover SubSnap.
**Complexity:** Medium — data aggregation + image/card generation.
**Design:**
  - 4-5 swipeable screens with big numbers and animations
  - Dark background with mint highlights (on-brand)
  - Final screen: shareable card with key stats
  - "Share to Stories" / "Share to Twitter" / "Copy Image"
**Sprint:** v1.2 — target December 2026 for first cohort.

### 10. Anonymous Benchmarking
**What:** Opt-in feature: "You spend £95/mo on subscriptions. The average SubSnap user spends £73/mo." Can also break down by category: "You spend 40% more on streaming than average."
**Why:** Social comparison is a powerful motivator. Creates a reason to trim spending and a reason to check the app ("am I still above average?").
**Complexity:** High — requires backend (Supabase/Firebase) to aggregate anonymised data.
**Privacy rules:**
  - Strictly opt-in with clear explanation
  - Only aggregate stats sent to server (category totals, not service names)
  - No personally identifiable information ever leaves the device
  - Minimum 1,000 users before showing benchmarks (statistical validity)
**Where:** Insights tab or home screen card.
**Sprint:** v1.2+ — needs backend infrastructure, so after v1 launch when user base exists.

---

## Tier 4 — Future Vision (v2.0)

### 11. Bank Feed Integration (Open Banking)
**What:** Connect to bank via Open Banking API (Plaid, TrueLayer, GoCardless) to auto-detect subscriptions from transaction history.
**Why:** Eliminates manual entry entirely. This is what Rocket Money does. But it requires significant trust-building and regulatory compliance.
**Complexity:** Very High — PSD2/Open Banking compliance, Plaid integration, transaction parsing.
**Consideration:** This fundamentally changes the app's privacy story. Currently SubSnap is "no bank connection needed" which is a selling point. Consider keeping both modes: manual/AI scan as default, bank feed as optional Pro+ feature.
**Sprint:** v2.0 — only after establishing trust with a large user base.

### 12. Subscription Marketplace / Deals
**What:** Partner with services to offer SubSnap users exclusive deals. "Your Netflix is £15.99/mo. Switch to the ad-supported plan and save £72/year." Or "Get 3 months free of Spotify with SubSnap."
**Why:** Revenue diversification beyond the one-time £4.99 purchase. Affiliate commissions on switches/signups.
**Complexity:** High — needs partnerships, affiliate tracking, legal review.
**Sprint:** v2.0+ — only viable with 50K+ users for leverage.

### 13. Cross-Device Sync
**What:** iCloud sync (iOS) and/or Supabase backend sync for multi-device access.
**Why:** Users want their data on phone + tablet + potentially web.
**Complexity:** Medium (iCloud) to High (custom backend).
**Sprint:** v1.2 — iCloud sync is relatively straightforward in Flutter with isar.

---

## Implementation Priority Matrix

| Feature | Impact | Effort | Priority | Target |
|---|---|---|---|---|
| **Trap Scanner** | 🔥 Very High | Medium | 🔥 LAUNCH | Sprint 7-8 |
| **Aggressive Trial Alerts** | 🔥 Very High | Medium | 🔥 LAUNCH | Sprint 6-7 |
| **Saved from Traps Counter** | High | Low | 🔥 LAUNCH | Sprint 7-8 |
| Annual cost projection | High | Low | 🔥 Do now | Current sprint |
| Calendar view | High | Medium | 🔥 Do now | Sprint 6-7 |
| Home screen widgets | High | Medium-High | ✅ Planned | Sprint 7 |
| **Refund Rescue Guide** | High | Medium | ⭐ Quick win | v1.1 |
| Shared/family tracking | Medium | Low | ⭐ Quick win | v1.1 |
| Price change detection | High | Low-Medium | ⭐ Quick win | v1.1 |
| Renewal day optimisation | Medium | Low | ⭐ Quick win | v1.1 |
| Smart cancel guides | High | Medium | 📋 Plan | v1.1 |
| "Should I keep this?" | Medium | Medium | 📋 Plan | v1.2 |
| SubSnap Wrapped | Very High | Medium | 📋 Plan | v1.2 (Dec 2026) |
| **Dark Pattern Database** | Very High | High | 📋 Plan | v1.2+ |
| Anonymous benchmarking | Medium | High | 🔮 Future | v1.2+ |
| Bank feed integration | Very High | Very High | 🔮 Future | v2.0 |
| Subscription marketplace | High | Very High | 🔮 Future | v2.0+ |
| Cross-device sync | Medium | Medium | 🔮 Future | v1.2 |

---

## Notes

- **v1.0 focus:** Ship the core — manual CRUD, AI scan, **Trap Scanner**, **aggressive trial alerts**, reminders, paywall, basic gamification, **saved from traps counter**
- **v1.1 focus (1-2 months post-launch):** Quick wins from user feedback + **refund rescue guides**, shared tracking, price detection, cancel guides, renewal insights
- **v1.2 focus (3-4 months post-launch):** Wrapped, **dark pattern database**, benchmarking, "should I keep this?" nudges, iCloud sync
- **v2.0 vision:** Open Banking integration, marketplace deals, web dashboard

Always validate with real user feedback before building Tier 3-4 features. The App Store reviews and Reddit posts will tell you what people actually want.
