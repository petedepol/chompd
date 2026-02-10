# SubSnap — Trap Scanner & Subscription Defence Suite

> "My wife got charged £100 for a 'free' health app. So I built SubSnap."

## The Problem

Dark pattern subscriptions are an epidemic:
- "£1 to see your results" → auto-renews at £99.99/year
- "Free 3-day trial" → charges full price on day 4 with no reminder
- Cancellation buried 6 screens deep behind "Are you sure?" guilt trips
- Price increases applied silently with no notification
- Terms hidden in tiny grey-on-grey text

The people who get hit hardest aren't careless — they're busy, trusting, or just didn't see the full picture. SubSnap should be their shield.

---

## Feature 1: Trap Scanner (Pre-Purchase Protection)

### What
User sees a suspicious "trial" or "£1 deal" screen → screenshots it → opens SubSnap → scans it. Instead of adding a subscription, SubSnap reads the fine print and flags the trap.

### How It Works

**Step 1 — Screenshot & Scan**
User hits the scan button as normal. The AI (Claude Haiku) analyses the screenshot.

**Step 2 — Trap Detection**
The AI looks for dark pattern indicators:
- Trial periods with auto-renewal
- Introductory prices that increase
- Annual charges disguised as weekly prices ("just £1.92/week" = £99.99/year)
- Recurring billing buried in terms
- "Free" offers that require payment details

**Step 3 — Snappy's Warning**
Instead of the normal "add subscription" flow, Snappy appears in concerned/alert mode:

```
┌─────────────────────────────────┐
│  ⚠️ TRAP DETECTED               │
│                                  │
│  This "£1 health scan" is       │
│  actually:                       │
│                                  │
│  £1.00 today (3-day trial)      │
│  Then £99.99/year auto-renew    │
│                                  │
│  Real cost: £100.99 first year  │
│                                  │
│  🐊 "That £1 is bait. You'll   │
│  be charged £99.99 in 3 days    │
│  unless you cancel."            │
│                                  │
│  [Track Trial Anyway]  [Skip It]│
│                                  │
│  Set cancellation reminder? ⏰   │
└─────────────────────────────────┘
```

**Step 4 — User Decision**
- **"Skip It"** → Done. Snappy celebrates: "Smart move! You just saved £100."
  Add to savings counter. Log as a "dodged trap."
- **"Track Trial Anyway"** → Adds the subscription with:
  - Trial end date prominently displayed
  - Auto-reminder set for 24hrs AND 2hrs before trial converts
  - Card marked with amber "TRIAL TRAP" badge
  - Price shows both trial price AND real renewal price
  - Cancel guide pre-loaded for that service

### AI Prompt Engineering

Add a new scan mode to the existing 3-tier intelligence system:

```
TRAP_SCAN system prompt addition:

"Analyse this screenshot for subscription dark patterns. Look for:
1. Trial periods — what's the trial length? What happens after?
2. Auto-renewal terms — is there automatic billing after the trial?
3. Real price — what will the user actually pay per year?
4. Price framing tricks — is an annual price shown as weekly/daily?
5. Cancellation difficulty — are cancel instructions visible?
6. Hidden terms — any fine print about recurring charges?

Respond with:
- is_trap: boolean
- trap_type: 'trial_bait' | 'price_framing' | 'hidden_renewal' | 'cancel_friction' | null
- trial_price: amount or null
- trial_duration: days or null  
- real_price: amount per year
- billing_cycle: 'weekly' | 'monthly' | 'yearly'
- confidence: 0-100
- warning_message: plain English explanation of the trap
- severity: 'low' | 'medium' | 'high'

Severity guide:
- low: Standard trial with reasonable auto-renewal (Netflix free month → £15.99/mo)
- medium: Introductory price that significantly increases (£1 → £9.99/mo)  
- high: Extreme price jump or deceptive framing (£1 → £99.99/year, weekly price hiding annual cost)"
```

### Integration with Existing Scan Flow

The trap detection happens within the existing scan — no separate button needed:

```
User scans screenshot
  → AI analyses content
  → IF subscription detected with trial/intro pricing:
      → Run trap detection in parallel
      → IF trap detected:
          → Show Trap Scanner result (warning card)
          → User decides: track or skip
      → ELSE:
          → Normal "add subscription" flow
  → IF no subscription detected:
      → Normal "not recognised" flow
```

### Data Model Addition

```dart
class Subscription {
  // ... existing fields ...
  
  // Trap Scanner fields
  bool? isTrap;
  String? trapType;        // 'trial_bait', 'price_framing', etc.
  double? trialPrice;
  int? trialDurationDays;
  double? realPrice;       // actual annual cost
  String? trapSeverity;    // 'low', 'medium', 'high'
  DateTime? trialExpiresAt;
  bool? trialReminderSet;
}

class DodgedTrap {
  String serviceName;
  double savedAmount;      // the real annual price they avoided
  DateTime dodgedAt;
  String trapType;
}
```

### Complexity
Medium — it's an extension of the existing AI scan, not a new system. The prompt engineering is the main work. UI is a new card variant.

### Sprint Target
**v1.0 Sprint 7-8** — This should ship with launch. It's the headline feature.

---

## Feature 2: Aggressive Trial Alerts

### What
When a user adds a trial subscription (detected by Trap Scanner or manually entered), SubSnap sets up a multi-stage alert system that's impossible to ignore.

### Alert Timeline

```
Trial added (e.g., 7-day trial converting to £99.99/year)
│
├── Immediately: Confirmation with trial end date shown prominently
│
├── Day 1: "Your [App] trial is active. You have 6 days to decide."
│   (passive — just an in-app badge update)
│
├── 72 hours before: Push notification
│   "Your [App] trial ends in 3 days. It'll auto-charge £99.99/year."
│   [Cancel Now] [Remind Me Later]
│
├── 24 hours before: Push notification (elevated)  
│   "⚠️ TOMORROW: [App] will charge £99.99. Cancel now if you don't want it."
│   [Cancel Now] [Keep It]
│
├── 2 hours before: URGENT push notification
│   "🚨 [App] charges £99.99 in 2 HOURS. This is your last chance."
│   [Cancel Now — Here's How]
│   Links directly to the cancel guide for that service
│
└── After conversion: "Did you mean to keep [App]? You were charged £99.99."
    [I wanted this] [Help me get a refund]
```

### Cancel Guide Deep Link
The 2-hour alert includes a direct link to the cancellation instructions. For App Store subs this can deep link to Settings → Subscriptions. For others, show the step-by-step guide.

### User Controls
- Users can adjust alert frequency per subscription (some trials are intentional)
- Global toggle: "Aggressive trial alerts" on/off (default: on)
- Never alert for subs the user marks as "I want to keep this"

### Complexity
Medium — needs local notification scheduling (flutter_local_notifications) with the trial end date minus offsets.

### Sprint Target
**v1.0 Sprint 6-7** — Core trial tracking is already in the app. This adds the notification scheduling.

---

## Feature 3: Refund Rescue Guide

### What
When a user realises they've been caught by a dark pattern charge, SubSnap provides a step-by-step refund guide specific to how they were charged.

### Refund Paths

**Path A — App Store (iOS)**
```
1. Go to reportaproblem.apple.com
2. Sign in with your Apple ID
3. Find the charge in your purchase history
4. Select "I didn't intend to purchase this item"
5. Submit — Apple usually refunds within 48 hours

Success rate: ~80% for first request
```

**Path B — Google Play**
```
1. Go to play.google.com/store/account
2. Click "Order History"
3. Find the charge → "Report a Problem"
4. Select "I didn't mean to make this purchase"
5. Submit

Success rate: ~70% for first request
```

**Path C — Direct Billing (Website)**
```
1. Email the company's support address
2. Subject: "Refund Request — Misleading Trial Terms"
3. [PRE-WRITTEN TEMPLATE — tap to copy]:

"I signed up for what I understood to be a [trial price] trial 
of [Service]. I was not clearly informed that this would 
auto-renew at [real price]. Under the UK Consumer Rights 
Act 2015, I am entitled to a refund as the pricing terms 
were not presented clearly. Please process a full refund 
within 14 days.

[User's name]"

4. If no response in 7 days → escalate to bank chargeback
```

**Path D — Bank Chargeback (Last Resort)**
```
1. Call your bank or use the app's dispute feature
2. Reference: "Misleading subscription terms"
3. Provide: screenshot of the original offer + the actual charge
4. Banks are familiar with this pattern — high success rate in UK
```

### Snappy's Role
Snappy guides users through with encouragement:
- "Don't worry, most people get their money back. Let's sort this."
- After refund: "You got £99.99 back! That's going in your saved total."

### Template Emails
Pre-written dispute templates that auto-fill with:
- Service name (from subscription record)
- Trial price vs actual price
- Date of original signup
- Amount charged

User just taps "Copy to Clipboard" or "Open Mail App"

### Complexity
Medium — content creation for guides + template system. No API needed.

### Sprint Target
**v1.1** — extends the existing Cancel Guides feature (roadmap item #4).

---

## Feature 4: Dark Pattern Database (Community-Powered)

### What
A growing database of apps/services known to use dark patterns, powered by SubSnap users and AI.

### How It Builds
1. Every time Trap Scanner flags a service → anonymised data point added
2. When users report "I was charged unexpectedly" → flag added
3. AI scans App Store/Play Store reviews for phrases like "scam", "couldn't cancel", "charged without consent"

### What Users See
When scanning a new service, if it's in the database:

```
┌──────────────────────────────────┐
│  ⚠️ COMMUNITY WARNING            │
│                                   │
│  [Health App Name]                │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  🔴 847 SubSnap users reported   │
│     unexpected charges            │
│                                   │
│  Most common trap: Trial bait    │
│  Avg hidden cost: £89/year       │
│  Refund success rate: 73%        │
│                                   │
│  🐊 "Careful with this one.      │
│  If you proceed, I'll watch it   │
│  like a hawk."                   │
└──────────────────────────────────┘
```

### Trust Score
Each service gets a trust score (0-100):
- 90-100: Clean — no reports, transparent pricing
- 70-89: Caution — some reports, standard trials
- 50-69: Warning — frequent reports, aggressive trials
- 0-49: Danger — many reports, known dark patterns

### Privacy
- Only aggregate data shared (never individual user data)
- Service names + trap type + frequency — nothing personal
- Opt-in to contribute data
- Minimum 50 reports before showing a warning (avoid false flags)

### Complexity
High — needs backend (Supabase), moderation, data aggregation.

### Sprint Target
**v1.2+** — needs user base to be meaningful. Start collecting data from day 1, surface it when volume is sufficient.

---

## Feature 5: "Saved from Traps" Counter (Gamification)

### What
A running total of money the user has avoided spending thanks to SubSnap's warnings.

### How It Counts
- User scans a trap → chooses "Skip It" → annual price added to "Saved from Traps" counter
- User cancels a trial before conversion → trial-to-paid price difference added
- User gets a refund → refunded amount added

### Display

```
Home screen card (below spending ring):
┌──────────────────────────────┐
│  🛡️ Snappy saved you         │
│  £347.96                      │
│  from subscription traps      │
│                               │
│  3 traps dodged               │
│  1 trial cancelled in time    │
│  1 refund recovered           │
└──────────────────────────────┘
```

### Integration with Milestones
New milestone track: "Trap Dodger"
- £50 saved from traps: "Rookie Dodger" 🛡️
- £100: "Trap Spotter" 🔍
- £250: "Dark Pattern Destroyer" ⚔️
- £500: "Subscription Sentinel" 🏰
- £1000: "The Untrapable" 👑

### Integration with SubSnap Wrapped
Year-end stat: "You dodged X traps worth £X this year"
Shareable card: "SubSnap saved me £347 from subscription traps in 2026"

### Complexity
Low — counter + display. Data already captured by Trap Scanner and trial alerts.

### Sprint Target
**v1.0** — ships with Trap Scanner. It's the reward loop.

---

## Updated Priority Matrix

| Feature | Impact | Effort | Priority | Target |
|---|---|---|---|---|
| **Trap Scanner** | 🔥 Very High | Medium | 🔥 SHIP WITH LAUNCH | Sprint 7-8 |
| **Aggressive Trial Alerts** | 🔥 Very High | Medium | 🔥 SHIP WITH LAUNCH | Sprint 6-7 |
| **Saved from Traps Counter** | High | Low | 🔥 SHIP WITH LAUNCH | Sprint 7-8 |
| **Refund Rescue Guide** | High | Medium | ⭐ Fast follow | v1.1 |
| **Dark Pattern Database** | Very High | High | 📋 Plan | v1.2+ |

---

## Marketing Angle

This entire suite reframes SubSnap from "subscription tracker" to **"subscription defence"**.

### App Store Positioning
**Title:** SubSnap — Subscription Defence
**Subtitle:** Scan. Track. Trap-proof your money.

### Hero Copy
"Your subscriptions are out to get you. SubSnap fights back."

### The Story (App Store description / TikTok / landing page)
"My wife signed up for a £1 health scan. Three days later, she was charged £100 for a full year — buried in the fine print she never saw. 

I looked for an app to prevent this. They all track what you're already paying. None of them warn you BEFORE you get trapped.

So I built SubSnap. 

Snap a screenshot of any subscription offer. SubSnap reads the fine print, spots the trap, and tells you the real price. If you go ahead anyway, it'll remind you before the trial converts — not after.

Your subscriptions shouldn't be smarter than you."

### Social Proof Hooks
- "SubSnap users have dodged £X in subscription traps"
- "Average user saves £240/year just by knowing what they pay"
- "847 people reported [App Name] for hidden charges"

### TikTok / Reels Format
1. Screen recording: "My wife got charged £100 for this £1 health app"
2. Show the fine print / dark pattern
3. Show SubSnap scanning the same screenshot
4. Snappy warning: "That £1 is actually £100/year"
5. "This is why I built SubSnap. Link in bio."

---

## Technical Notes

### No New APIs Needed
Trap Scanner uses the same Claude Haiku API as the existing scan flow — just an extended prompt. No additional costs beyond existing scan credits.

### Scan Credit Usage
A trap scan uses 1 scan credit (same as a normal scan). This means free users get 3 trap scans, which is perfect — it demonstrates the value and drives Pro upgrades.

### Notification Permissions
Trial alerts require push notification permission. Request this at the moment a trial is added ("Want me to warn you before this trial charges you?") — much higher acceptance rate than asking at launch.

### Offline Capability
Refund guides and cancel guides should be cached locally in Isar. The dark pattern database needs network but can cache the top 100 flagged services locally.
