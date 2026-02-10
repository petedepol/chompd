# Trap Scanner — Claude Code Build Spec

> Implementation guide for SubSnap's Trap Scanner feature suite.
> Read this fully before writing any code.

## Overview

The Trap Scanner extends the existing AI scan flow to detect dark pattern subscriptions (deceptive trials, hidden renewals, price framing tricks) BEFORE the user gets charged. It's not a separate feature — it's an upgrade to the existing scan pipeline.

**What gets built (in order):**
1. Extended AI prompt with trap detection
2. New data models (TrapResult, DodgedTrap)
3. Updated Subscription model with trap fields
4. Trap warning UI card
5. "Skip It" flow with savings counter
6. "Track Trial Anyway" flow with aggressive alerts
7. Saved from Traps home screen card
8. Trap Dodger milestone track

---

## Phase 1: Data Models

### 1a. Create `lib/models/trap_result.dart`

```dart
import 'package:isar/isar.dart';

part 'trap_result.g.dart';

/// Result from AI trap detection analysis
class TrapResult {
  final bool isTrap;
  final TrapType? trapType;
  final TrapSeverity severity;
  final double? trialPrice;
  final int? trialDurationDays;
  final double? realPrice;        // actual price after trial/intro
  final String? realBillingCycle;  // 'weekly', 'monthly', 'yearly'
  final double? realAnnualCost;   // calculated yearly cost
  final int confidence;           // 0-100
  final String warningMessage;    // plain English from AI
  final String? serviceName;      // detected service name

  const TrapResult({
    required this.isTrap,
    this.trapType,
    required this.severity,
    this.trialPrice,
    this.trialDurationDays,
    this.realPrice,
    this.realBillingCycle,
    this.realAnnualCost,
    required this.confidence,
    required this.warningMessage,
    this.serviceName,
  });

  factory TrapResult.fromJson(Map<String, dynamic> json) {
    return TrapResult(
      isTrap: json['is_trap'] as bool? ?? false,
      trapType: _parseTrapType(json['trap_type'] as String?),
      severity: _parseSeverity(json['severity'] as String? ?? 'low'),
      trialPrice: (json['trial_price'] as num?)?.toDouble(),
      trialDurationDays: json['trial_duration_days'] as int?,
      realPrice: (json['real_price'] as num?)?.toDouble(),
      realBillingCycle: json['billing_cycle'] as String?,
      realAnnualCost: (json['real_annual_cost'] as num?)?.toDouble(),
      confidence: json['confidence'] as int? ?? 0,
      warningMessage: json['warning_message'] as String? ?? '',
      serviceName: json['service_name'] as String?,
    );
  }

  static TrapType? _parseTrapType(String? type) {
    return switch (type) {
      'trial_bait' => TrapType.trialBait,
      'price_framing' => TrapType.priceFraming,
      'hidden_renewal' => TrapType.hiddenRenewal,
      'cancel_friction' => TrapType.cancelFriction,
      _ => null,
    };
  }

  static TrapSeverity _parseSeverity(String severity) {
    return switch (severity) {
      'high' => TrapSeverity.high,
      'medium' => TrapSeverity.medium,
      _ => TrapSeverity.low,
    };
  }

  /// The amount the user would save by skipping this trap
  double get savingsAmount => realAnnualCost ?? realPrice ?? 0;

  /// Human-readable trap type
  String get trapTypeLabel => switch (trapType) {
    TrapType.trialBait => 'Trial Bait',
    TrapType.priceFraming => 'Price Framing',
    TrapType.hiddenRenewal => 'Hidden Renewal',
    TrapType.cancelFriction => 'Cancel Friction',
    null => 'Subscription Trap',
  };
}

enum TrapType {
  trialBait,      // £1 trial → £99/year
  priceFraming,   // "£1.92/week" hiding £99/year
  hiddenRenewal,  // auto-renew buried in fine print
  cancelFriction, // deliberately hard to cancel
}

enum TrapSeverity {
  low,    // standard trial (Netflix free month → £15.99/mo)
  medium, // intro price that increases significantly (£1 → £9.99/mo)
  high,   // extreme price jump or deceptive framing (£1 → £99.99/year)
}
```

### 1b. Create `lib/models/dodged_trap.dart`

```dart
import 'package:isar/isar.dart';

part 'dodged_trap.g.dart';

@collection
class DodgedTrap {
  Id id = Isar.autoIncrement;

  late String serviceName;
  late double savedAmount;
  late DateTime dodgedAt;
  late String trapType;  // stored as string for Isar

  @enumerated
  late DodgedTrapSource source;
}

enum DodgedTrapSource {
  skipped,           // user chose "Skip It" on trap warning
  trialCancelled,    // cancelled trial before conversion
  refundRecovered,   // got money back via refund guide
}
```

### 1c. Update `lib/models/subscription.dart`

Add these fields to the existing Subscription model:

```dart
// === Trap Scanner fields ===
bool? isTrap;
String? trapType;          // 'trial_bait', 'price_framing', etc.
double? trialPrice;        // introductory/trial price
int? trialDurationDays;    // how long the trial lasts
double? realPrice;         // price after trial ends
double? realAnnualCost;    // calculated annual cost at real price
String? trapSeverity;      // 'low', 'medium', 'high'
DateTime? trialExpiresAt;  // exact expiry timestamp
bool trialReminderSet = false;
```

Run `flutter pub run build_runner build` after model changes to regenerate Isar schemas.

---

## Phase 2: AI Prompt Extension

### 2a. Update `lib/services/ai_scan_service.dart`

The existing scan sends a screenshot to Claude Haiku and gets back subscription details. Extend the system prompt to ALSO perform trap detection in the same API call. This avoids a second API call.

**Updated system prompt** (append to existing scan prompt):

```dart
static const String _systemPrompt = '''
You are SubSnap, an AI that analyses screenshots to extract subscription details.

TASK 1 — SUBSCRIPTION EXTRACTION:
Extract from the screenshot:
- service_name: string
- price: number
- currency: string (GBP, USD, EUR)
- billing_cycle: "weekly" | "monthly" | "quarterly" | "yearly"
- is_trial: boolean
- trial_end_date: ISO date string or null
- confidence: 0-100

TASK 2 — TRAP DETECTION:
Also analyse the screenshot for subscription dark patterns:
1. Trial periods — what is the trial length? What happens after?
2. Auto-renewal terms — is there automatic billing after the trial?
3. Real price — what will the user actually pay per year after any intro period?
4. Price framing tricks — is an annual price disguised as weekly/daily to look smaller?
5. Hidden terms — any fine print about recurring charges that isn't prominently displayed?

RESPOND WITH VALID JSON ONLY (no markdown, no backticks):
{
  "subscription": {
    "service_name": "string",
    "price": number,
    "currency": "string",
    "billing_cycle": "string",
    "is_trial": boolean,
    "trial_end_date": "string or null",
    "confidence": number
  },
  "trap": {
    "is_trap": boolean,
    "trap_type": "trial_bait" | "price_framing" | "hidden_renewal" | "cancel_friction" | null,
    "severity": "low" | "medium" | "high",
    "trial_price": number or null,
    "trial_duration_days": number or null,
    "real_price": number or null,
    "billing_cycle": "weekly" | "monthly" | "yearly" | null,
    "real_annual_cost": number or null,
    "confidence": number,
    "warning_message": "string — plain English explanation of the trap, max 2 sentences",
    "service_name": "string"
  }
}

SEVERITY GUIDE:
- "low": Standard trial with reasonable auto-renewal. E.g., Netflix free month then £15.99/mo. User likely knows what they're signing up for.
- "medium": Introductory price that significantly increases. E.g., £1 first month then £9.99/mo. The jump is notable but not extreme.
- "high": Extreme price jump OR deceptive framing. E.g., £1 trial then £99.99/year, or showing "just £1.92/week" when the annual cost is £99.99. Designed to mislead.

If no subscription or trap is detected, return is_trap: false and confidence: 0 in the trap object.
''';
```

### 2b. Update the response parser

In the existing scan result handler, parse the new `trap` object alongside the `subscription` object:

```dart
Future<ScanOutput> processScreenshot(Uint8List imageBytes) async {
  // ... existing API call to Claude Haiku ...

  final jsonResponse = _parseResponse(response);

  // Parse subscription as before
  final subscription = ScanResult.fromJson(jsonResponse['subscription']);

  // NEW: Parse trap detection
  final trapData = jsonResponse['trap'] as Map<String, dynamic>?;
  final trapResult = trapData != null
      ? TrapResult.fromJson(trapData)
      : const TrapResult(
          isTrap: false,
          severity: TrapSeverity.low,
          confidence: 0,
          warningMessage: '',
        );

  return ScanOutput(
    subscription: subscription,
    trap: trapResult,
  );
}
```

### 2c. Create `lib/models/scan_output.dart`

```dart
class ScanOutput {
  final ScanResult subscription;
  final TrapResult trap;

  const ScanOutput({
    required this.subscription,
    required this.trap,
  });

  /// Whether to show the trap warning instead of normal add flow
  bool get shouldShowTrapWarning =>
      trap.isTrap && trap.confidence >= 60 && trap.severity != TrapSeverity.low;

  /// Whether to show a softer info notice (low severity traps)
  bool get shouldShowTrialNotice =>
      trap.isTrap && trap.severity == TrapSeverity.low;
}
```

---

## Phase 3: Updated Scan Flow

### 3a. Update `lib/providers/scan_provider.dart`

Update the scan state to include trap results:

```dart
@riverpod
class ScanNotifier extends _$ScanNotifier {

  // Existing states: idle, scanning, result, error
  // ADD new states:
  //   - trapDetected (shows trap warning card)
  //   - trapSkipped (shows celebration + savings)

  Future<void> processScan(Uint8List imageBytes) async {
    state = const ScanState.scanning();

    try {
      final output = await ref.read(aiScanServiceProvider).processScreenshot(imageBytes);

      if (output.shouldShowTrapWarning) {
        // HIGH/MEDIUM severity trap — show warning screen
        state = ScanState.trapDetected(
          subscription: output.subscription,
          trap: output.trap,
        );
      } else if (output.shouldShowTrialNotice) {
        // LOW severity — show normal result with trial info badge
        state = ScanState.result(
          subscription: output.subscription,
          trialNotice: output.trap,
        );
      } else {
        // No trap — normal flow
        state = ScanState.result(subscription: output.subscription);
      }
    } catch (e) {
      state = ScanState.error(e.toString());
    }
  }

  /// User chose "Skip It" on trap warning
  Future<void> skipTrap(TrapResult trap) async {
    // Log dodged trap
    final dodgedTrap = DodgedTrap()
      ..serviceName = trap.serviceName ?? 'Unknown'
      ..savedAmount = trap.savingsAmount
      ..dodgedAt = DateTime.now()
      ..trapType = trap.trapType?.name ?? 'unknown'
      ..source = DodgedTrapSource.skipped;

    await ref.read(storageServiceProvider).saveDodgedTrap(dodgedTrap);

    state = ScanState.trapSkipped(
      savedAmount: trap.savingsAmount,
      serviceName: trap.serviceName ?? 'Unknown',
    );

    // Haptic feedback — celebration
    HapticFeedback.heavyImpact();
  }

  /// User chose "Track Trial Anyway"
  Future<void> trackTrapTrial(ScanResult subscription, TrapResult trap) async {
    // Create subscription with trap metadata
    final sub = Subscription()
      ..name = subscription.serviceName
      ..price = trap.trialPrice ?? subscription.price
      ..currency = subscription.currency
      ..cycle = _parseCycle(subscription.billingCycle)
      ..nextRenewal = _calculateNextRenewal(subscription)
      ..isTrial = true
      ..trialEndDate = _calculateTrialEnd(trap.trialDurationDays)
      ..isActive = true
      ..source = 'ai_scan'
      ..createdAt = DateTime.now()
      // Trap fields
      ..isTrap = true
      ..trapType = trap.trapType?.name
      ..trialPrice = trap.trialPrice
      ..trialDurationDays = trap.trialDurationDays
      ..realPrice = trap.realPrice
      ..realAnnualCost = trap.realAnnualCost
      ..trapSeverity = trap.severity.name
      ..trialExpiresAt = _calculateTrialEnd(trap.trialDurationDays)
      ..trialReminderSet = true;

    await ref.read(storageServiceProvider).saveSubscription(sub);

    // Schedule aggressive trial alerts
    await ref.read(notificationServiceProvider).scheduleTrialAlerts(sub);

    state = ScanState.result(subscription: subscription);
  }

  DateTime? _calculateTrialEnd(int? days) {
    if (days == null) return null;
    return DateTime.now().add(Duration(days: days));
  }
}
```

---

## Phase 4: Trap Warning UI

### 4a. Create `lib/screens/scan/trap_warning_card.dart`

This is the main trap warning screen shown when a medium/high severity trap is detected.

**Design spec:**

```
┌─ Full screen overlay on dark scrim ──────────────────┐
│                                                        │
│  [Snappy sad/thinking image - 80px, top-right]        │
│                                                        │
│  ⚠️ TRAP DETECTED                                     │
│  ─────────────────                                     │
│  [severity badge: MEDIUM or HIGH]                      │
│                                                        │
│  This "[service name]" offer is actually:              │
│                                                        │
│  ┌─ Price breakdown card (bgElevated) ─────────────┐  │
│  │  [trial price]  →  [real price]                  │  │
│  │  £1.00 today      £99.99/year                    │  │
│  │  (3-day trial)    (auto-renews)                  │  │
│  │                                                   │  │
│  │  Real cost first year: £100.99                   │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
│  💬 "[AI warning message from Claude]"                 │
│                                                        │
│  ┌─ Actions ────────────────────────────────────────┐  │
│  │                                                   │  │
│  │  [  SKIP IT — SAVE £99.99  ]  ← mint, primary    │  │
│  │                                                   │  │
│  │  [  Track Trial Anyway     ]  ← outlined, subtle  │  │
│  │  ⏰ We'll remind you before it charges             │  │
│  │                                                   │  │
│  └──────────────────────────────────────────────────┘  │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Key styling:**
- Background: dark scrim (bg colour at 95% opacity) with backdrop blur
- Warning icon: amber for medium, red for high
- Severity badge: `TrapSeverity.high` → red background with "HIGH RISK", `medium` → amber with "CAUTION"
- Price breakdown card: `bgElevated` background, border `amber` or `red` depending on severity
- Trial price → arrow → real price: use Space Mono, the arrow animates on load (slides in from left)
- "SKIP IT" button: full width, mint gradient background, bold text, `savingsAmount` displayed
- "Track Trial Anyway" button: ghost/outlined style, textDim colour, less prominent
- Snappy asset: `Mascot.sad` for high severity, `Mascot.thinking` for medium — positioned top-right, 80px, slight bob animation
- Warning message: italic, textMid colour, wrapped in subtle quote styling

**Widget structure:**
```dart
class TrapWarningCard extends ConsumerWidget {
  final ScanResult subscription;
  final TrapResult trap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      // Full screen overlay
      child: Column(
        children: [
          // Header: icon + "TRAP DETECTED" + severity badge
          _buildHeader(),

          // Snappy mascot (positioned)
          _buildSnappy(),

          // Service name
          _buildServiceName(),

          // Price breakdown card
          _buildPriceBreakdown(),

          // AI warning message
          _buildWarningMessage(),

          const Spacer(),

          // Action buttons
          _buildSkipButton(ref),    // Primary — mint
          _buildTrackButton(ref),   // Secondary — outlined
        ],
      ),
    );
  }
}
```

### 4b. Create `lib/widgets/severity_badge.dart`

```dart
class SeverityBadge extends StatelessWidget {
  final TrapSeverity severity;

  Color get _bgColor => switch (severity) {
    TrapSeverity.high => AppColors.red.withOpacity(0.15),
    TrapSeverity.medium => AppColors.amber.withOpacity(0.15),
    TrapSeverity.low => AppColors.blue.withOpacity(0.15),
  };

  Color get _textColor => switch (severity) {
    TrapSeverity.high => AppColors.red,
    TrapSeverity.medium => AppColors.amber,
    TrapSeverity.low => AppColors.blue,
  };

  String get _label => switch (severity) {
    TrapSeverity.high => 'HIGH RISK',
    TrapSeverity.medium => 'CAUTION',
    TrapSeverity.low => 'INFO',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _textColor.withOpacity(0.3)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _textColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
```

### 4c. Create `lib/widgets/price_breakdown_card.dart`

The visual centrepiece — shows trial price → arrow → real price.

```dart
class PriceBreakdownCard extends StatefulWidget {
  final TrapResult trap;

  @override
  Widget build(BuildContext context) {
    // Container with bgElevated, rounded corners, severity-coloured border
    // Row: [trial price column] → [animated arrow] → [real price column]
    // Below: "Real cost first year: £X" in bold Space Mono

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: trap.severity == TrapSeverity.high
              ? AppColors.red.withOpacity(0.3)
              : AppColors.amber.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Trial price
              _PriceColumn(
                label: 'TODAY',
                price: '£${trap.trialPrice?.toStringAsFixed(2) ?? "0.00"}',
                sublabel: '${trap.trialDurationDays ?? "?"}-day trial',
                color: AppColors.mint,
              ),

              // Arrow (animated slide-in)
              _AnimatedArrow(),

              // Real price
              _PriceColumn(
                label: 'THEN',
                price: '£${trap.realPrice?.toStringAsFixed(2) ?? "?"}',
                sublabel: '/${trap.realBillingCycle ?? "year"}',
                color: trap.severity == TrapSeverity.high
                    ? AppColors.red
                    : AppColors.amber,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Annual total
          if (trap.realAnnualCost != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Real cost first year: £${trap.realAnnualCost!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

### 4d. Trap skipped celebration

When user taps "Skip It", show a brief celebration:

```dart
// In scan screen — after skipTrap() completes:
// 1. Snappy celebrate asset slides in (300ms)
// 2. "Smart move!" text fades in
// 3. "You just saved £99.99" counts up in Space Mono (600ms)
// 4. Confetti burst (Lottie)
// 5. HapticFeedback.heavyImpact()
// 6. Auto-dismiss after 2.5s → return to home
```

---

## Phase 5: Aggressive Trial Alerts

### 5a. Update `lib/services/notification_service.dart`

Add a method to schedule the multi-stage trial alert timeline:

```dart
/// Schedule aggressive alerts for a tracked trial subscription
Future<void> scheduleTrialAlerts(Subscription sub) async {
  if (sub.trialExpiresAt == null) return;

  final expiry = sub.trialExpiresAt!;
  final name = sub.name;
  final price = sub.realPrice ?? sub.price;
  final priceStr = '£${price.toStringAsFixed(2)}';

  // 72 hours before
  final alert72h = expiry.subtract(const Duration(hours: 72));
  if (alert72h.isAfter(DateTime.now())) {
    await _scheduleNotification(
      id: _notifId(sub.id, 72),
      scheduledDate: alert72h,
      title: '$name trial ends in 3 days',
      body: 'It\'ll auto-charge $priceStr. Cancel now if you don\'t want it.',
      payload: 'sub:${sub.id}:cancel',
    );
  }

  // 24 hours before
  final alert24h = expiry.subtract(const Duration(hours: 24));
  if (alert24h.isAfter(DateTime.now())) {
    await _scheduleNotification(
      id: _notifId(sub.id, 24),
      scheduledDate: alert24h,
      title: '⚠️ TOMORROW: $name will charge $priceStr',
      body: 'Cancel now if you don\'t want to keep it.',
      payload: 'sub:${sub.id}:cancel',
      importance: Importance.high,
    );
  }

  // 2 hours before — URGENT
  final alert2h = expiry.subtract(const Duration(hours: 2));
  if (alert2h.isAfter(DateTime.now())) {
    await _scheduleNotification(
      id: _notifId(sub.id, 2),
      scheduledDate: alert2h,
      title: '🚨 $name charges $priceStr in 2 HOURS',
      body: 'This is your last chance to cancel. Tap for instructions.',
      payload: 'sub:${sub.id}:cancel_guide',
      importance: Importance.max,
    );
  }

  // After conversion — check-in
  final afterConvert = expiry.add(const Duration(hours: 2));
  await _scheduleNotification(
    id: _notifId(sub.id, 0),
    scheduledDate: afterConvert,
    title: 'Did you mean to keep $name?',
    body: 'You were charged $priceStr. Tap if you need help getting a refund.',
    payload: 'sub:${sub.id}:refund_check',
  );
}

/// Cancel all trial alerts for a subscription (when user cancels the trial)
Future<void> cancelTrialAlerts(String subId) async {
  for (final offset in [72, 24, 2, 0]) {
    await _flutterLocalNotificationsPlugin.cancel(_notifId(subId, offset));
  }
}

/// Generate a deterministic notification ID from sub ID + hour offset
int _notifId(String subId, int hourOffset) {
  return '${subId}_trial_$hourOffset'.hashCode;
}
```

### 5b. Handle notification taps

In the notification tap handler, route based on payload:

```dart
void _onNotificationTap(String? payload) {
  if (payload == null) return;

  final parts = payload.split(':');
  if (parts.length < 3 || parts[0] != 'sub') return;

  final subId = parts[1];
  final action = parts[2];

  switch (action) {
    case 'cancel':
      // Navigate to subscription detail with cancel prompt
      _router.push('/subscription/$subId?action=cancel');
      break;
    case 'cancel_guide':
      // Navigate to cancel guide for this service
      _router.push('/subscription/$subId?action=cancel_guide');
      break;
    case 'refund_check':
      // Navigate to subscription detail with refund option
      _router.push('/subscription/$subId?action=refund');
      break;
  }
}
```

### 5c. Request notification permission at the right moment

DON'T request at app launch. Request when user tracks a trial:

```dart
// In trackTrapTrial() flow, before scheduling alerts:
final hasPermission = await _requestNotificationPermission();
if (hasPermission) {
  await scheduleTrialAlerts(sub);
  sub.trialReminderSet = true;
} else {
  // Show in-app banner: "Enable notifications to get trial alerts"
}
```

---

## Phase 6: Saved from Traps Counter

### 6a. Create `lib/providers/trap_stats_provider.dart`

```dart
@riverpod
class TrapStats extends _$TrapStats {
  @override
  Future<TrapStatsData> build() async {
    final storage = ref.read(storageServiceProvider);
    final dodgedTraps = await storage.getAllDodgedTraps();

    double totalSaved = 0;
    int trapsSkipped = 0;
    int trialsCancelled = 0;
    int refundsRecovered = 0;

    for (final trap in dodgedTraps) {
      totalSaved += trap.savedAmount;
      switch (trap.source) {
        case DodgedTrapSource.skipped:
          trapsSkipped++;
          break;
        case DodgedTrapSource.trialCancelled:
          trialsCancelled++;
          break;
        case DodgedTrapSource.refundRecovered:
          refundsRecovered++;
          break;
      }
    }

    return TrapStatsData(
      totalSaved: totalSaved,
      trapsSkipped: trapsSkipped,
      trialsCancelled: trialsCancelled,
      refundsRecovered: refundsRecovered,
    );
  }
}

class TrapStatsData {
  final double totalSaved;
  final int trapsSkipped;
  final int trialsCancelled;
  final int refundsRecovered;

  const TrapStatsData({
    required this.totalSaved,
    required this.trapsSkipped,
    required this.trialsCancelled,
    required this.refundsRecovered,
  });

  int get totalActions => trapsSkipped + trialsCancelled + refundsRecovered;
  bool get hasStats => totalActions > 0;
}
```

### 6b. Create `lib/widgets/trap_stats_card.dart`

Home screen card that shows the running savings total.

**Only shows when user has dodged at least 1 trap.**

```
Design:
┌──────────────────────────────────────────┐
│  🛡️  Snappy saved you                    │
│                                           │
│  £347.96          ← Space Mono, 28px,    │
│                      count-up animation   │
│  from subscription traps                  │
│                                           │
│  3 dodged · 1 cancelled · 1 refunded     │
│                                           │
│  [See Details →]                          │
└──────────────────────────────────────────┘

- Background: bgCard
- Border: 1px border with mint at 15% opacity
- Shield icon: mint colour
- Savings amount: Space Mono, 28px, mint, count-up on load (0.6s)
- Breakdown: textDim, 10px, Space Mono
- Position: below spending ring, above subscription list
```

### 6c. Trap Dodger milestones

Add to the existing milestones system:

```dart
static const trapMilestones = [
  Milestone(
    amount: 50,
    title: 'Rookie Dodger',
    icon: '🛡️',
    track: 'trap',
  ),
  Milestone(
    amount: 100,
    title: 'Trap Spotter',
    icon: '🔍',
    track: 'trap',
  ),
  Milestone(
    amount: 250,
    title: 'Dark Pattern Destroyer',
    icon: '⚔️',
    track: 'trap',
  ),
  Milestone(
    amount: 500,
    title: 'Subscription Sentinel',
    icon: '🏰',
    track: 'trap',
  ),
  Milestone(
    amount: 1000,
    title: 'The Untrappable',
    icon: '👑',
    track: 'trap',
  ),
];
```

When `totalSaved` crosses a milestone threshold, trigger:
1. Snappy celebrate asset
2. Confetti Lottie
3. HapticFeedback.heavyImpact()
4. Toast with milestone name

---

## Phase 7: Subscription Card Updates

### 7a. Trial trap badge on subscription cards

For subscriptions where `isTrap == true`, show a prominent badge:

```dart
// In subscription_card.dart, add to the badge row:
if (sub.isTrap == true)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: (sub.trapSeverity == 'high'
          ? AppColors.red
          : AppColors.amber).withOpacity(0.15),
      borderRadius: BorderRadius.circular(100),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.warning_rounded, size: 10,
          color: sub.trapSeverity == 'high'
              ? AppColors.red
              : AppColors.amber),
        const SizedBox(width: 3),
        Text(
          '${sub.trialDurationDays ?? "?"}d trap',
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: sub.trapSeverity == 'high'
                ? AppColors.red
                : AppColors.amber,
          ),
        ),
      ],
    ),
  ),
```

### 7b. Dual price display

For trap subscriptions, show both prices:

```dart
// Instead of just the current price:
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text(
      '£${sub.price.toStringAsFixed(2)}',
      style: TextStyle(
        fontFamily: 'SpaceMono',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        decoration: sub.isTrap == true
            ? TextDecoration.lineThrough
            : null,
        color: sub.isTrap == true ? AppColors.textDim : null,
      ),
    ),
    if (sub.isTrap == true && sub.realPrice != null)
      Text(
        '→ £${sub.realPrice!.toStringAsFixed(2)}',
        style: TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: sub.trapSeverity == 'high'
              ? AppColors.red
              : AppColors.amber,
        ),
      ),
  ],
),
```

---

## Phase 8: Storage Layer

### 8a. Update `lib/services/storage_service.dart`

Add DodgedTrap CRUD operations:

```dart
// Add DodgedTrap to Isar schema list in init()
final isar = await Isar.open([
  SubscriptionSchema,
  MerchantSchema,
  DodgedTrapSchema,  // NEW
]);

Future<void> saveDodgedTrap(DodgedTrap trap) async {
  await _isar.writeTxn(() => _isar.dodgedTraps.put(trap));
}

Future<List<DodgedTrap>> getAllDodgedTraps() async {
  return _isar.dodgedTraps.where().findAll();
}

Future<double> getTotalTrapSavings() async {
  final traps = await getAllDodgedTraps();
  return traps.fold(0.0, (sum, t) => sum + t.savedAmount);
}
```

---

## Build Order (step by step)

1. **Models first** — TrapResult, DodgedTrap, update Subscription, ScanOutput. Run build_runner.
2. **AI prompt** — Update system prompt in ai_scan_service.dart. Test with a few real screenshots.
3. **Scan provider** — Add trapDetected/trapSkipped states, skipTrap(), trackTrapTrial().
4. **Trap warning UI** — TrapWarningCard, SeverityBadge, PriceBreakdownCard.
5. **Skip celebration** — Snappy celebrate + confetti + savings animation.
6. **Storage** — DodgedTrap Isar schema + CRUD methods.
7. **Trial alerts** — scheduleTrialAlerts() in notification_service.dart.
8. **Trap stats provider** — TrapStats riverpod provider.
9. **Home screen card** — TrapStatsCard widget, place below spending ring.
10. **Subscription card updates** — Trap badge, dual price display.
11. **Milestones** — Add trap milestone track, hook up to trap stats.
12. **Test** — Scan real screenshots of known dark pattern apps.

---

## Test Screenshots to Try

Scan these to verify trap detection works:
- Any "£1 trial" health/astrology app from App Store (high severity)
- Netflix signup page showing "free month" (low severity — should NOT trigger warning)
- A "£1.92/week" type offer (price framing — should calculate annual)
- A normal subscription confirmation email (should NOT detect trap)
- An app store receipt with auto-renewal terms in fine print

---

## Files Created/Modified Summary

**New files:**
- `lib/models/trap_result.dart`
- `lib/models/dodged_trap.dart`
- `lib/models/scan_output.dart`
- `lib/screens/scan/trap_warning_card.dart`
- `lib/widgets/severity_badge.dart`
- `lib/widgets/price_breakdown_card.dart`
- `lib/widgets/trap_stats_card.dart`
- `lib/providers/trap_stats_provider.dart`

**Modified files:**
- `lib/models/subscription.dart` — add trap fields
- `lib/services/ai_scan_service.dart` — extended prompt + response parsing
- `lib/services/storage_service.dart` — DodgedTrap schema + methods
- `lib/services/notification_service.dart` — scheduleTrialAlerts()
- `lib/providers/scan_provider.dart` — trap states + skip/track actions
- `lib/widgets/subscription_card.dart` — trap badge + dual price
- `lib/screens/home/` — add TrapStatsCard

**Assets needed:**
- `assets/mascot/snappy_sad.png` (for high severity warning)
- `assets/mascot/snappy_thinking.png` (for medium severity warning)
- `assets/mascot/snappy_celebrate.png` (for skip celebration)
