# SubSnap — Defence Suite Build Spec (Part 2)

> Three features that complete the anti-subscription defence loop.
> Cancel Guides → Refund Rescue → AI Nudge. Read fully before coding.

---

## How These Connect

```
User adds subscription
  │
  ├── AI Nudge checks periodically: "Are you still using this?"
  │     ├── Yes → leave it alone
  │     └── Not sure / No → show Cancel Guide for that service
  │
  ├── Trial about to convert (from Trap Scanner alerts)
  │     └── 2-hour alert → links to Cancel Guide
  │
  └── Already charged (missed the trial / didn't cancel)
        └── Refund Rescue → platform-specific steps + dispute templates
```

All three features share a common data layer: **service-specific guides** stored locally in Isar.

---

# Feature 1: Smart Cancel Guides

## What
Step-by-step cancellation instructions for specific services. When a user wants to cancel, SubSnap shows them exactly how — including deep links to settings pages where possible.

## Data Model

### Create `lib/models/cancel_guide.dart`

```dart
import 'package:isar/isar.dart';

part 'cancel_guide.g.dart';

@collection
class CancelGuide {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String serviceName;        // normalised lowercase: "netflix", "spotify"

  late String platform;           // 'ios', 'android', 'web', 'all'
  late List<String> steps;        // ordered cancellation steps
  String? deepLink;               // iOS Settings URL or web URL
  String? cancellationUrl;        // direct web cancel page if known
  String? notes;                  // "Netflix lets you use until end of billing period"
  late int difficultyRating;      // 1-5 (1 = easy, 5 = deliberately hard)
  DateTime? lastVerified;         // when these steps were last checked
}
```

## Pre-loaded Guide Data

### Create `lib/data/cancel_guides_data.dart`

Ship with ~30 guides for the most common services. These are hardcoded at launch, updatable via app updates later.

```dart
final List<Map<String, dynamic>> cancelGuidesData = [
  // === App Store Subscriptions (iOS) ===
  {
    'serviceName': 'app_store_generic',
    'platform': 'ios',
    'steps': [
      'Open the Settings app on your iPhone',
      'Tap your name at the top',
      'Tap "Subscriptions"',
      'Find the subscription you want to cancel',
      'Tap "Cancel Subscription"',
      'Confirm cancellation',
    ],
    'deepLink': 'https://apps.apple.com/account/subscriptions',
    'notes': 'You keep access until the end of your current billing period.',
    'difficultyRating': 1,
  },

  // === Google Play Subscriptions (Android) ===
  {
    'serviceName': 'google_play_generic',
    'platform': 'android',
    'steps': [
      'Open the Google Play Store app',
      'Tap your profile icon (top right)',
      'Tap "Payments & subscriptions"',
      'Tap "Subscriptions"',
      'Select the subscription to cancel',
      'Tap "Cancel subscription"',
      'Follow the prompts to confirm',
    ],
    'cancellationUrl': 'https://play.google.com/store/account/subscriptions',
    'notes': 'Access continues until end of current billing period.',
    'difficultyRating': 1,
  },

  // === Major Services ===
  {
    'serviceName': 'netflix',
    'platform': 'all',
    'steps': [
      'Go to netflix.com and sign in',
      'Click your profile icon → "Account"',
      'Click "Cancel Membership"',
      'Confirm cancellation',
    ],
    'cancellationUrl': 'https://www.netflix.com/cancelplan',
    'notes': 'You can watch until the end of your billing period. Netflix saves your profile for 10 months.',
    'difficultyRating': 1,
  },
  {
    'serviceName': 'spotify',
    'platform': 'all',
    'steps': [
      'Go to spotify.com/account',
      'Click "Your plan"',
      'Click "Cancel Premium" (or "Cancel plan")',
      'Confirm — you\'ll keep Premium until end of billing period',
    ],
    'cancellationUrl': 'https://www.spotify.com/account/subscription/',
    'notes': 'Cannot cancel via the app — must use website. You revert to Free tier with ads.',
    'difficultyRating': 2,
  },
  {
    'serviceName': 'amazon_prime',
    'platform': 'all',
    'steps': [
      'Go to amazon.co.uk/prime',
      'Click "Manage Membership"',
      'Click "Update, cancel and more"',
      'Click "End membership"',
      'Confirm through several "are you sure" screens',
    ],
    'cancellationUrl': 'https://www.amazon.co.uk/mc/pipelines/cancel',
    'notes': 'Amazon shows several retention offers — keep clicking through to actually cancel. Can get partial refund if unused.',
    'difficultyRating': 4,
  },
  {
    'serviceName': 'adobe_creative_cloud',
    'platform': 'all',
    'steps': [
      'Go to account.adobe.com/plans',
      'Click "Manage plan" next to your subscription',
      'Click "Cancel plan"',
      'Choose a reason',
      'Review early termination fee (if on annual plan)',
      'Confirm cancellation',
    ],
    'cancellationUrl': 'https://account.adobe.com/plans',
    'notes': 'Annual plans charged monthly have an early termination fee (50% of remaining months). Switch to month-to-month first if possible.',
    'difficultyRating': 5,
  },
  {
    'serviceName': 'apple_one',
    'platform': 'ios',
    'steps': [
      'Open Settings on your iPhone',
      'Tap your name → "Subscriptions"',
      'Tap "Apple One"',
      'Tap "Cancel All Services" or "Cancel Individual Services"',
      'Confirm',
    ],
    'deepLink': 'https://apps.apple.com/account/subscriptions',
    'difficultyRating': 1,
  },
  {
    'serviceName': 'youtube_premium',
    'platform': 'all',
    'steps': [
      'Go to youtube.com/paid_memberships',
      'Click "Manage membership"',
      'Click "Deactivate"',
      'Confirm cancellation',
    ],
    'cancellationUrl': 'https://www.youtube.com/paid_memberships',
    'notes': 'If subscribed through iOS, cancel via Settings → Subscriptions instead.',
    'difficultyRating': 2,
  },
  {
    'serviceName': 'disney_plus',
    'platform': 'all',
    'steps': [
      'Open Disney+ app or go to disneyplus.com',
      'Go to your Profile → Account',
      'Select your subscription',
      'Click "Cancel Subscription"',
      'Confirm',
    ],
    'cancellationUrl': 'https://www.disneyplus.com/account',
    'difficultyRating': 2,
  },
  {
    'serviceName': 'chatgpt_plus',
    'platform': 'all',
    'steps': [
      'Go to chat.openai.com',
      'Click your profile (bottom left)',
      'Click "My Plan"',
      'Click "Manage my subscription"',
      'Click "Cancel plan"',
    ],
    'notes': 'If subscribed through iOS App Store, cancel via Settings → Subscriptions.',
    'difficultyRating': 2,
  },
  {
    'serviceName': 'xbox_game_pass',
    'platform': 'all',
    'steps': [
      'Go to account.microsoft.com/services',
      'Find your Game Pass subscription',
      'Click "Manage"',
      'Click "Cancel subscription"',
      'Follow the prompts (Microsoft shows several retention screens)',
    ],
    'cancellationUrl': 'https://account.microsoft.com/services',
    'notes': 'Microsoft makes you click through 3-4 retention screens. Keep going.',
    'difficultyRating': 4,
  },
  {
    'serviceName': 'gym',
    'platform': 'all',
    'steps': [
      'Check your contract for the cancellation policy and notice period',
      'Most UK gyms require written notice (email or letter)',
      'Send cancellation email to the gym\'s membership team',
      'Request written confirmation of cancellation',
      'Note: many gyms require 30 days notice — you may owe one more payment',
    ],
    'notes': 'Gym cancellation policies vary wildly. Check your contract for notice period and any cancellation fees.',
    'difficultyRating': 4,
  },
];
```

### Fuzzy Matching Service

When showing a cancel guide for a subscription, match against the `serviceName` field:

```dart
CancelGuide? findGuideForSubscription(Subscription sub) {
  final name = sub.name.toLowerCase().trim();

  // Direct match
  final direct = guides.firstWhereOrNull(
    (g) => g.serviceName == name.replaceAll(' ', '_'),
  );
  if (direct != null) return direct;

  // Partial match
  final partial = guides.firstWhereOrNull(
    (g) => name.contains(g.serviceName.replaceAll('_', ' ')) ||
           g.serviceName.replaceAll('_', ' ').contains(name),
  );
  if (partial != null) return partial;

  // Platform fallback
  if (sub.source == 'ai_scan') {
    // If it was scanned, it's probably an app subscription
    // Return the generic App Store / Google Play guide
    return _getGenericPlatformGuide();
  }

  return null;
}

CancelGuide _getGenericPlatformGuide() {
  // Detect platform at runtime
  if (Platform.isIOS) {
    return guides.firstWhere((g) => g.serviceName == 'app_store_generic');
  } else {
    return guides.firstWhere((g) => g.serviceName == 'google_play_generic');
  }
}
```

## Cancel Guide Screen

### Create `lib/screens/cancel/cancel_guide_screen.dart`

```
┌─────────────────────────────────────────────┐
│  ← Cancel [Service Name]                     │
│                                               │
│  ┌─ Difficulty indicator ──────────────────┐ │
│  │  ████░  Difficulty: 4/5                 │ │
│  │  "Amazon makes this deliberately hard"  │ │
│  └─────────────────────────────────────────┘ │
│                                               │
│  STEP 1                                       │
│  ┌────────────────────────────────────────┐  │
│  │ ○  Go to amazon.co.uk/prime            │  │
│  │    [Open Link ↗]                       │  │
│  └────────────────────────────────────────┘  │
│                                               │
│  STEP 2                                       │
│  ┌────────────────────────────────────────┐  │
│  │ ○  Click "Manage Membership"           │  │
│  └────────────────────────────────────────┘  │
│                                               │
│  STEP 3                                       │
│  ┌────────────────────────────────────────┐  │
│  │ ○  Click "Update, cancel and more"     │  │
│  └────────────────────────────────────────┘  │
│                                               │
│  ...                                          │
│                                               │
│  ┌─ Notes ─────────────────────────────────┐ │
│  │ ⚠️ Amazon shows several retention       │ │
│  │ offers — keep clicking through to       │ │
│  │ actually cancel.                        │ │
│  └─────────────────────────────────────────┘ │
│                                               │
│  [ Open Cancel Page ↗ ]     ← mint button    │
│                                               │
│  [ I've Cancelled ✓ ]      ← outlined        │
│  Marks sub as cancelled + logs savings        │
│                                               │
│  Couldn't cancel?                             │
│  [ Get Refund Help → ]     ← links to        │
│                              Refund Rescue    │
└─────────────────────────────────────────────┘
```

**Key interactions:**
- Each step has a tappable checkbox — user ticks off as they go. Haptic on tick. Progress persists if they leave and come back.
- "Open Cancel Page" button uses `url_launcher` to open the cancellation URL or deep link.
- "I've Cancelled" marks the subscription as cancelled, sets `cancelledDate`, and adds the remaining annual value to the "Money Saved" counter.
- "Couldn't cancel?" links to Refund Rescue (Feature 2 below).

**Difficulty indicator colours:**
```dart
Color get difficultyColor => switch (guide.difficultyRating) {
  1 => AppColors.mint,    // Easy
  2 => AppColors.mint,
  3 => AppColors.amber,   // Medium
  4 => AppColors.amber,
  5 => AppColors.red,     // Hard
  _ => AppColors.textDim,
};

String get difficultyLabel => switch (guide.difficultyRating) {
  1 => 'Easy — straightforward cancel',
  2 => 'Easy — one extra step',
  3 => 'Medium — takes a few minutes',
  4 => 'Hard — they make this deliberately difficult',
  5 => 'Very hard — multiple retention screens or fees',
  _ => '',
};
```

## Entry Points

Cancel guides are accessible from:

1. **Subscription detail screen** → "Cancel" button → shows guide instead of just marking cancelled
2. **Trial alert notifications** → 2-hour alert deep links to cancel guide for that service
3. **Trap Scanner** → "Track Trial Anyway" flow → cancel guide pre-loaded
4. **AI Nudge** → "Maybe cancel?" → links to cancel guide
5. **Home screen** → trial banner → tap → cancel guide

```dart
// Navigation helper:
void navigateToCancelGuide(BuildContext context, Subscription sub) {
  final guide = ref.read(cancelGuideServiceProvider).findGuideForSubscription(sub);
  if (guide != null) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => CancelGuideScreen(subscription: sub, guide: guide),
    ));
  } else {
    // No specific guide — show generic platform guide
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => CancelGuideScreen(
        subscription: sub,
        guide: ref.read(cancelGuideServiceProvider).getGenericPlatformGuide(),
      ),
    ));
  }
}
```

## Storage

### Update `lib/services/storage_service.dart`

```dart
// Add to Isar schema list:
final isar = await Isar.open([
  SubscriptionSchema,
  MerchantSchema,
  DodgedTrapSchema,
  CancelGuideSchema,  // NEW
]);

// Seed on first launch:
Future<void> seedCancelGuides() async {
  final count = await _isar.cancelGuides.count();
  if (count == 0) {
    await _isar.writeTxn(() async {
      for (final data in cancelGuidesData) {
        final guide = CancelGuide()
          ..serviceName = data['serviceName']
          ..platform = data['platform']
          ..steps = List<String>.from(data['steps'])
          ..deepLink = data['deepLink']
          ..cancellationUrl = data['cancellationUrl']
          ..notes = data['notes']
          ..difficultyRating = data['difficultyRating']
          ..lastVerified = DateTime.now();
        await _isar.cancelGuides.put(guide);
      }
    });
  }
}
```

---

# Feature 2: Refund Rescue Guide

## What
When cancellation fails or the user's already been charged, SubSnap walks them through getting their money back with platform-specific instructions and pre-written dispute email templates.

## Data Model

### Create `lib/models/refund_template.dart`

```dart
class RefundTemplate {
  final String id;
  final String name;           // "App Store Refund", "Direct Billing Dispute"
  final RefundPath path;
  final List<String> steps;
  final String? url;           // platform refund URL
  final String? emailTemplate; // pre-written dispute email
  final String successRate;    // "~80% for first request"
  final String timeframe;      // "Usually 48 hours"

  const RefundTemplate({
    required this.id,
    required this.name,
    required this.path,
    required this.steps,
    this.url,
    this.emailTemplate,
    required this.successRate,
    required this.timeframe,
  });
}

enum RefundPath {
  appStore,
  googlePlay,
  directBilling,
  bankChargeback,
}
```

## Pre-loaded Refund Paths

### Create `lib/data/refund_paths_data.dart`

```dart
final List<RefundTemplate> refundPaths = [
  RefundTemplate(
    id: 'app_store',
    name: 'Apple App Store Refund',
    path: RefundPath.appStore,
    steps: [
      'Go to reportaproblem.apple.com',
      'Sign in with your Apple ID',
      'Find the charge in your purchase history',
      'Tap "Report a Problem" next to the charge',
      'Select "I didn\'t intend to purchase this item" or "I didn\'t authorise this purchase"',
      'Add a brief explanation: "I was misled by trial terms"',
      'Submit your request',
    ],
    url: 'https://reportaproblem.apple.com',
    successRate: '~80% for first request',
    timeframe: 'Usually refunded within 48 hours',
  ),

  RefundTemplate(
    id: 'google_play',
    name: 'Google Play Refund',
    path: RefundPath.googlePlay,
    steps: [
      'Go to play.google.com/store/account/orderhistory',
      'Find the charge you want to dispute',
      'Click "Report a problem"',
      'Select "I didn\'t mean to make this purchase" or "My purchase doesn\'t work as expected"',
      'Fill in the details and submit',
    ],
    url: 'https://play.google.com/store/account/orderhistory',
    successRate: '~70% for first request',
    timeframe: 'Usually 1-4 business days',
  ),

  RefundTemplate(
    id: 'direct_billing',
    name: 'Email the Company',
    path: RefundPath.directBilling,
    steps: [
      'Find the company\'s support email (check their website footer or your confirmation email)',
      'Copy the pre-written dispute email below',
      'Fill in the highlighted fields with your details',
      'Send the email',
      'If no response in 7 days, follow up once',
      'If still no response after 14 days, escalate to bank chargeback',
    ],
    emailTemplate: '''Subject: Refund Request — Misleading Subscription Terms

Dear [Company] Support,

I signed up for what I understood to be a {trial_price} trial of {service_name} on {signup_date}.

I was not clearly informed that this would automatically renew at {real_price}. The pricing terms were not presented transparently at the point of purchase.

Under the UK Consumer Rights Act 2015, consumers are entitled to clear and transparent pricing. I am requesting a full refund of {charge_amount} charged on {charge_date}.

Please process this refund within 14 days.

Regards,
[Your name]''',
    successRate: '~50-60% — varies by company',
    timeframe: '3-14 days depending on company',
  ),

  RefundTemplate(
    id: 'bank_chargeback',
    name: 'Bank Chargeback (Last Resort)',
    path: RefundPath.bankChargeback,
    steps: [
      'Open your banking app or call your bank',
      'Find the transaction you want to dispute',
      'Select "Dispute transaction" or "Chargeback"',
      'Reason: "Misleading subscription terms" or "Services not as described"',
      'Provide evidence: screenshot of the original offer showing the trial price',
      'Your bank will investigate — this usually takes 5-10 business days',
    ],
    successRate: '~70-80% — banks are familiar with this pattern',
    timeframe: '5-10 business days',
  ),
];
```

## Email Template Auto-Fill

When the user opens the direct billing template, auto-fill from the subscription record:

```dart
String buildDisputeEmail(Subscription sub) {
  final template = refundPaths
      .firstWhere((p) => p.id == 'direct_billing')
      .emailTemplate!;

  return template
      .replaceAll('{service_name}', sub.name)
      .replaceAll('{trial_price}', '£${sub.trialPrice?.toStringAsFixed(2) ?? "free"}')
      .replaceAll('{real_price}', '£${sub.realPrice?.toStringAsFixed(2) ?? sub.price.toStringAsFixed(2)}/${sub.cycle.shortLabel}')
      .replaceAll('{signup_date}', DateFormat('d MMMM yyyy').format(sub.createdAt))
      .replaceAll('{charge_amount}', '£${sub.realPrice?.toStringAsFixed(2) ?? sub.price.toStringAsFixed(2)}')
      .replaceAll('{charge_date}', DateFormat('d MMMM yyyy').format(sub.nextRenewal));
}
```

## Refund Rescue Screen

### Create `lib/screens/refund/refund_rescue_screen.dart`

```
┌─────────────────────────────────────────────┐
│  ← Refund Rescue                             │
│                                               │
│  🐊 "Don't worry — most people get their     │
│      money back. Let's sort this."            │
│                                               │
│  [Service name] charged you £99.99            │
│                                               │
│  HOW WERE YOU CHARGED?                        │
│                                               │
│  ┌────────────────────────────────────────┐  │
│  │  🍎 App Store          ~80% success   │  │
│  │  Usually refunded in 48 hours          │  │
│  └────────────────────────────────────────┘  │
│                                               │
│  ┌────────────────────────────────────────┐  │
│  │  ▶️ Google Play         ~70% success   │  │
│  │  Usually 1-4 business days             │  │
│  └────────────────────────────────────────┘  │
│                                               │
│  ┌────────────────────────────────────────┐  │
│  │  ✉️ Billed directly     ~50% success   │  │
│  │  Pre-written email template included   │  │
│  └────────────────────────────────────────┘  │
│                                               │
│  ┌────────────────────────────────────────┐  │
│  │  🏦 Bank chargeback     Last resort    │  │
│  │  5-10 business days                    │  │
│  └────────────────────────────────────────┘  │
│                                               │
└─────────────────────────────────────────────┘

→ Tapping a path opens step-by-step guide (same layout as Cancel Guide)
```

**After user selects a path and taps through steps:**

```
┌─────────────────────────────────────────────┐
│                                               │
│  Have you submitted your refund request?      │
│                                               │
│  [ Yes — I've requested a refund ✓ ]         │
│                                               │
│  This logs a pending refund. SubSnap will     │
│  check in with you after the expected          │
│  timeframe to see if it came through.         │
│                                               │
└─────────────────────────────────────────────┘
```

## Refund Follow-Up Notification

When user marks a refund as submitted, schedule a check-in notification:

```dart
Future<void> scheduleRefundFollowUp(Subscription sub, RefundTemplate path) async {
  // Schedule based on expected timeframe
  final delay = switch (path.path) {
    RefundPath.appStore => const Duration(hours: 72),
    RefundPath.googlePlay => const Duration(days: 5),
    RefundPath.directBilling => const Duration(days: 10),
    RefundPath.bankChargeback => const Duration(days: 12),
  };

  await NotificationService.instance.scheduleNotification(
    id: 'refund_${sub.id}'.hashCode,
    scheduledDate: DateTime.now().add(delay),
    title: 'Refund update: ${sub.name}',
    body: 'Did your refund come through? Tap to update.',
    payload: 'sub:${sub.id}:refund_result',
  );
}
```

**On notification tap → show result dialog:**

```dart
// "Did you get your refund?"
// [Yes — Got it back!]  → Log DodgedTrap(source: refundRecovered), celebrate
// [No — Still waiting]  → Reschedule check-in for 5 more days
// [Denied]              → Suggest next escalation path (direct billing → chargeback)
```

## Entry Points

1. **Cancel Guide screen** → "Couldn't cancel?" → Refund Rescue
2. **Trial alert** → post-conversion notification → "Help me get a refund"
3. **Subscription detail** → "Request Refund" action
4. **Trap Scanner** → "Skip It" shows savings, but if they already got charged → "Already charged? Get help"

---

# Feature 3: "Should I Keep This?" AI Nudge

## What
Periodic, gentle prompts that ask users whether they're actually using specific subscriptions. Uses smart heuristics (not AI API calls) to decide WHEN to nudge — no ongoing API cost.

## Nudge Triggers (No API Needed)

The nudge system runs locally. It checks subscriptions against these heuristic rules:

```dart
class NudgeEngine {
  /// Check all active subs and return any that deserve a nudge
  List<NudgeCandidate> evaluate(List<Subscription> subs) {
    final candidates = <NudgeCandidate>[];

    for (final sub in subs.where((s) => s.isActive)) {
      // Rule 1: Expensive + old
      // Subs over £10/mo that haven't been reviewed in 90+ days
      if (sub.monthlyEquivalent >= 10 && _daysSinceLastReview(sub) > 90) {
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.expensiveUnreviewed,
          message: 'You\'ve been paying £${sub.monthlyEquivalent.toStringAsFixed(2)}/mo for ${_monthsActive(sub)} months. Still using it?',
          priority: 2,
        ));
      }

      // Rule 2: Trial converted + never reviewed
      // Trial that auto-converted and user never explicitly confirmed keeping it
      if (sub.isTrap == true && sub.trialExpiresAt != null &&
          DateTime.now().isAfter(sub.trialExpiresAt!) &&
          _daysSinceLastReview(sub) > 14) {
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.trialConverted,
          message: 'Your ${sub.name} trial converted ${_daysAgo(sub.trialExpiresAt!)} days ago. Worth keeping at £${sub.price.toStringAsFixed(2)}/${sub.cycle.shortLabel}?',
          priority: 1, // highest priority
        ));
      }

      // Rule 3: Price increase detected
      // (future: when Price Change Detection is built)

      // Rule 4: Renewal approaching + expensive
      // 7 days before renewal for subs over £15/mo
      if (sub.monthlyEquivalent >= 15 && sub.daysUntilRenewal <= 7 && sub.daysUntilRenewal > 0) {
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.renewalApproaching,
          message: '${sub.name} renews in ${sub.daysUntilRenewal} days at £${sub.price.toStringAsFixed(2)}. That\'s £${sub.yearlyEquivalent.toStringAsFixed(2)}/year. Still worth it?',
          priority: 2,
        ));
      }

      // Rule 5: Duplicate category
      // Multiple subs in the same category (e.g., 3 streaming services)
      final sameCategorySubs = subs.where(
        (s) => s.isActive && s.category == sub.category && s.id != sub.id
      ).toList();
      if (sameCategorySubs.length >= 2 && _daysSinceLastReview(sub) > 60) {
        final totalMonthly = [sub, ...sameCategorySubs]
            .fold(0.0, (sum, s) => sum + s.monthlyEquivalent);
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.duplicateCategory,
          message: 'You have ${sameCategorySubs.length + 1} ${sub.category} subscriptions totalling £${totalMonthly.toStringAsFixed(2)}/mo. Need them all?',
          priority: 3,
        ));
      }

      // Rule 6: Yearly sub approaching renewal
      // 30 days before an annual renewal (big charge coming)
      if (sub.cycle == BillingCycle.yearly &&
          sub.daysUntilRenewal <= 30 && sub.daysUntilRenewal > 7) {
        candidates.add(NudgeCandidate(
          sub: sub,
          reason: NudgeReason.annualRenewalSoon,
          message: '${sub.name} renews in ${sub.daysUntilRenewal} days for £${sub.price.toStringAsFixed(2)}. That\'s a big one — still using it?',
          priority: 1,
        ));
      }
    }

    // Sort by priority (1 = highest), return top 1 per session
    candidates.sort((a, b) => a.priority.compareTo(b.priority));
    return candidates;
  }

  int _daysSinceLastReview(Subscription sub) {
    if (sub.lastReviewedAt == null) {
      return DateTime.now().difference(sub.createdAt).inDays;
    }
    return DateTime.now().difference(sub.lastReviewedAt!).inDays;
  }

  int _monthsActive(Subscription sub) {
    return DateTime.now().difference(sub.createdAt).inDays ~/ 30;
  }

  int _daysAgo(DateTime date) {
    return DateTime.now().difference(date).inDays;
  }
}
```

## Data Model Additions

### Update `lib/models/subscription.dart`

```dart
// Add to Subscription model:
DateTime? lastReviewedAt;    // last time user confirmed "I want to keep this"
DateTime? lastNudgedAt;      // last time we showed a nudge for this sub
bool keepConfirmed = false;  // user explicitly said "keep it" — suppress nudges for 90 days
```

### Create `lib/models/nudge_candidate.dart`

```dart
class NudgeCandidate {
  final Subscription sub;
  final NudgeReason reason;
  final String message;
  final int priority;   // 1 = highest

  const NudgeCandidate({
    required this.sub,
    required this.reason,
    required this.message,
    required this.priority,
  });
}

enum NudgeReason {
  trialConverted,
  expensiveUnreviewed,
  renewalApproaching,
  duplicateCategory,
  annualRenewalSoon,
}
```

## When Nudges Appear

**NOT on every app open.** That would be annoying. Rules:

```dart
class NudgeScheduler {
  static const _minDaysBetweenNudges = 3;  // max 1 nudge every 3 days
  static const _maxNudgesPerWeek = 2;

  /// Call this on app open (in home screen initState)
  Future<NudgeCandidate?> checkForNudge() async {
    final prefs = await SharedPreferences.getInstance();
    final lastNudge = prefs.getString('last_nudge_date');
    final nudgeCount = prefs.getInt('nudge_count_this_week') ?? 0;

    // Check frequency limits
    if (lastNudge != null) {
      final daysSince = DateTime.now()
          .difference(DateTime.parse(lastNudge))
          .inDays;
      if (daysSince < _minDaysBetweenNudges) return null;
    }

    if (nudgeCount >= _maxNudgesPerWeek) return null;

    // Run nudge engine
    final subs = await ref.read(storageServiceProvider).getAllSubscriptions();
    final candidates = NudgeEngine().evaluate(subs);

    if (candidates.isEmpty) return null;

    // Pick the highest priority candidate that hasn't been nudged recently
    final candidate = candidates.firstWhereOrNull(
      (c) => c.sub.lastNudgedAt == null ||
             DateTime.now().difference(c.sub.lastNudgedAt!).inDays > 30,
    );

    if (candidate != null) {
      // Record that we showed a nudge
      await prefs.setString('last_nudge_date', DateTime.now().toIso8601String());
      await prefs.setInt('nudge_count_this_week', nudgeCount + 1);

      // Update sub's lastNudgedAt
      candidate.sub.lastNudgedAt = DateTime.now();
      await ref.read(storageServiceProvider).saveSubscription(candidate.sub);
    }

    return candidate;
  }
}
```

## Nudge UI

Nudges appear as a **dismissible card on the home screen**, above the subscription list, below the category bar. Not a popup, not a modal — just a gentle inline card.

```
┌──────────────────────────────────────────────┐
│  🐊💭                                         │
│                                                │
│  "You have 3 streaming subscriptions           │
│   totalling £32.97/mo. Need them all?"         │
│                                                │
│  Netflix · Disney+ · Crunchyroll               │
│                                                │
│  [ Review These ]          [ I need them all ] │
│                                                │
└──────────────────────────────────────────────┘
```

**Styling:**
- Background: `bgCard` with purple-tinted left border (4px, `AppColors.purple`)
- Snappy thinking asset (tiny, 32px) top-left
- Message text: `textMid`, 13px
- Service names: `text`, 12px, Space Mono
- "Review These" → mint outlined button → navigates to first sub's detail
- "I need them all" → textDim ghost button → marks all as reviewed, suppresses nudge for 90 days
- Swipe to dismiss → same as "I need them all"

```dart
class NudgeCard extends ConsumerWidget {
  final NudgeCandidate nudge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('nudge_${nudge.sub.id}'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => _dismissNudge(ref),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: AppColors.purple, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Snappy thinking + message
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/mascot/snappy_thinking.png',
                    width: 32, height: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nudge.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMid,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _reviewSubscription(context),
                    child: const Text('Review'),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _dismissNudge(ref),
                  child: Text(
                    'I need this',
                    style: TextStyle(color: AppColors.textDim, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _dismissNudge(WidgetRef ref) {
    // Mark as reviewed — won't nudge again for 90 days
    nudge.sub.lastReviewedAt = DateTime.now();
    nudge.sub.keepConfirmed = true;
    ref.read(storageServiceProvider).saveSubscription(nudge.sub);
    HapticService.instance.lightImpact();
  }

  void _reviewSubscription(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => DetailScreen(subscription: nudge.sub),
    ));
  }
}
```

## Home Screen Integration

In `lib/screens/home/home_screen.dart`, add the nudge check:

```dart
// In initState or build:
final nudge = ref.watch(nudgeProvider);

// In the body, between category bar and subscription list:
if (nudge != null)
  NudgeCard(nudge: nudge),
```

### Create `lib/providers/nudge_provider.dart`

```dart
@riverpod
Future<NudgeCandidate?> nudge(NudgeRef ref) async {
  return NudgeScheduler(ref).checkForNudge();
}
```

---

## Files Created/Modified Summary

**New files:**
- `lib/models/cancel_guide.dart` — Isar model
- `lib/models/refund_template.dart` — refund path data class
- `lib/models/nudge_candidate.dart` — nudge result data class
- `lib/data/cancel_guides_data.dart` — pre-loaded cancel guides (~30 services)
- `lib/data/refund_paths_data.dart` — 4 refund paths with templates
- `lib/screens/cancel/cancel_guide_screen.dart` — step-by-step cancel UI
- `lib/screens/refund/refund_rescue_screen.dart` — refund path selector + step-by-step
- `lib/services/nudge_engine.dart` — heuristic nudge rules
- `lib/services/nudge_scheduler.dart` — frequency limiting + scheduling
- `lib/widgets/nudge_card.dart` — inline home screen nudge card
- `lib/providers/nudge_provider.dart` — riverpod nudge state

**Modified files:**
- `lib/models/subscription.dart` — add `lastReviewedAt`, `lastNudgedAt`, `keepConfirmed`
- `lib/services/storage_service.dart` — add CancelGuide Isar schema + seed method
- `lib/services/notification_service.dart` — add `scheduleRefundFollowUp()`
- `lib/screens/home/home_screen.dart` — add NudgeCard + nudge check on load
- `lib/screens/detail/detail_screen.dart` — "Cancel" links to cancel guide, "Refund" links to rescue

**Dependencies:**
- `url_launcher` — for opening cancel/refund URLs (if not already in pubspec)

---

## Build Order

1. **Cancel Guide model + data** — model, seed data, storage
2. **Cancel Guide screen** — step-by-step UI with checkboxes and deep links
3. **Wire cancel guides** — detail screen "Cancel" button → guide, trial alerts → guide
4. **Refund templates** — data + auto-fill email builder
5. **Refund Rescue screen** — path selector + step-by-step + copy email
6. **Refund follow-up** — scheduled notification + result dialog
7. **Subscription model update** — add review/nudge fields, run build_runner
8. **Nudge engine** — heuristic rules (6 triggers)
9. **Nudge scheduler** — frequency limits + provider
10. **Nudge card** — home screen inline card
11. **Test** — manually trigger each nudge rule, test cancel guide matching
