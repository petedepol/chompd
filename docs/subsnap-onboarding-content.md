# SubSnap — Onboarding Screens with Snappy

> 4-page onboarding flow. Structure already built (PageView with dots + buttons).
> This spec adds Snappy, copy, and polish. Read fully before editing.

---

## Overview

The onboarding exists (`lib/screens/onboarding/onboarding_screen.dart`) with 4 pages:
1. Welcome
2. How It Works
3. Notifications
4. Get Started

Currently parked because it needs Snappy assets and polished copy. This spec provides both.

**Onboarding only shows once** (fix for the "shows every launch" bug is in `subsnap-quick-fixes.md` — SharedPreferences `onboarding_seen` flag).

---

## Screen 1: Welcome

### Layout
```
┌─────────────────────────────────────────┐
│                                          │
│                                          │
│         [Snappy wave — 200px]            │
│         slides in from right             │
│         with spring bounce               │
│                                          │
│                                          │
│    Hey! I'm Snappy 🐊                    │
│                                          │
│    Your subscriptions are out to          │
│    get you. I'm here to fight back.      │
│                                          │
│                                          │
│                                          │
│                                          │
│              ● ○ ○ ○                     │
│                                          │
│         [ Next → ]                       │
│                                          │
└─────────────────────────────────────────┘
```

### Content
- **Asset:** `Mascot.wave` — 200px, centred
- **Headline:** `Hey! I'm Snappy 🐊`
- **Body:** `Your subscriptions are out to get you. I'm here to fight back.`
- **Animation:** Snappy slides in from off-screen right with a spring curve (300ms, `Curves.elasticOut`). Slight overshoot then settle. Starts at `Offset(1.5, 0)` → `Offset.zero`.
- **Background:** Subtle radial mint glow behind Snappy (20% opacity, 300px radius)

### Styling
```dart
// Headline
TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: AppColors.text,
)

// Body
TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: AppColors.textMid,
  height: 1.5,
)
```

---

## Screen 2: How It Works

### Layout
```
┌─────────────────────────────────────────┐
│                                          │
│                                          │
│       [Snappy full — 180px]              │
│       holding phone up                   │
│       (use snappy_full.png)              │
│                                          │
│                                          │
│    Snap it. Track it. Save.              │
│                                          │
│    ┌──────────────────────────────────┐  │
│    │ 📸  Screenshot any subscription  │  │
│    │     email, receipt, or app page  │  │
│    ├──────────────────────────────────┤  │
│    │ 🤖  AI reads the fine print      │  │
│    │     and spots hidden traps       │  │
│    ├──────────────────────────────────┤  │
│    │ 🛡️  Get alerts before trials     │  │
│    │     auto-charge you              │  │
│    └──────────────────────────────────┘  │
│                                          │
│              ○ ● ○ ○                     │
│                                          │
│         [ Next → ]                       │
│                                          │
└─────────────────────────────────────────┘
```

### Content
- **Asset:** `Mascot.full` — 180px, centred (Snappy with phone = he's the one doing the scanning)
- **Headline:** `Snap it. Track it. Save.`
- **Steps:** Three rows, each with an emoji icon and two lines of text
  1. 📸 `Screenshot any subscription` / `email, receipt, or app page`
  2. 🤖 `AI reads the fine print` / `and spots hidden traps`
  3. 🛡️ `Get alerts before trials` / `auto-charge you`
- **Animation:** Steps stagger in one by one (fade + slide up, 150ms delay between each). Snappy fades in simultaneously.

### Step Row Styling
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    color: AppColors.bgCard,
    border: Border(
      bottom: BorderSide(color: AppColors.border, width: 0.5),
    ),
  ),
  child: Row(
    children: [
      Text(emoji, style: TextStyle(fontSize: 24)),
      const SizedBox(width: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(line1, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          )),
          Text(line2, style: TextStyle(
            fontSize: 13,
            color: AppColors.textMid,
          )),
        ],
      ),
    ],
  ),
)
```

---

## Screen 3: Trap Scanner Highlight

**This replaces the generic "Notifications" page.** Notifications permission gets requested in context (when user tracks a trial), not during onboarding. This screen sells the headline feature instead.

### Layout
```
┌─────────────────────────────────────────┐
│                                          │
│                                          │
│       [Snappy thinking — 180px]          │
│       concerned expression               │
│                                          │
│                                          │
│    See the trap before it bites.         │
│                                          │
│    ┌──────────────────────────────────┐  │
│    │                                  │  │
│    │  "£1 health scan"               │  │
│    │                                  │  │
│    │   £1.00  ──→  £99.99/year       │  │
│    │   today       auto-renews       │  │
│    │                                  │  │
│    │  ⚠️ That £1 is bait. You'll be  │  │
│    │  charged £99.99 in 3 days.      │  │
│    │                                  │  │
│    └──────────────────────────────────┘  │
│                                          │
│    This happened to real people.         │
│    SubSnap makes sure it doesn't         │
│    happen to you.                        │
│                                          │
│              ○ ○ ● ○                     │
│                                          │
│         [ Next → ]                       │
│                                          │
└─────────────────────────────────────────┘
```

### Content
- **Asset:** `Mascot.thinking` — 180px, centred
- **Headline:** `See the trap before it bites.`
- **Mock trap card:** A simplified version of the trap warning card — shows a fake "£1 health scan" example with the price breakdown (£1 → £99.99/year) and a warning quote
- **Footer:** `This happened to real people. SubSnap makes sure it doesn't happen to you.`
- **Animation:** The mock trap card slides up from bottom (200ms), then the arrow between prices animates left→right (300ms, slight delay). Warning text fades in last.

### Mock Trap Card Styling
```dart
Container(
  margin: const EdgeInsets.symmetric(horizontal: 24),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.bgElevated,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.amber.withOpacity(0.3)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Service name
      Text(
        '"£1 health scan"',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
      const SizedBox(height: 12),

      // Price breakdown row
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Trial price
          Column(children: [
            Text('£1.00', style: TextStyle(
              fontFamily: 'SpaceMono', fontSize: 20,
              fontWeight: FontWeight.w700, color: AppColors.mint,
            )),
            Text('today', style: TextStyle(
              fontSize: 11, color: AppColors.textDim,
            )),
          ]),
          // Arrow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.arrow_forward_rounded,
                color: AppColors.amber, size: 24),
          ),
          // Real price
          Column(children: [
            Text('£99.99', style: TextStyle(
              fontFamily: 'SpaceMono', fontSize: 20,
              fontWeight: FontWeight.w700, color: AppColors.red,
            )),
            Text('/year', style: TextStyle(
              fontSize: 11, color: AppColors.textDim,
            )),
          ]),
        ],
      ),
      const SizedBox(height: 12),

      // Warning
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠️ ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              'That £1 is bait. You\'ll be charged £99.99 in 3 days.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.amber,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ],
  ),
)
```

---

## Screen 4: Get Started

### Layout
```
┌─────────────────────────────────────────┐
│                                          │
│                                          │
│       [Snappy celebrate — 200px]         │
│       arms up, sparkles                  │
│                                          │
│                                          │
│    Ready to take control?                │
│                                          │
│    3 free scans to start.                │
│    No subscription needed.               │
│    (The irony isn't lost on us.)         │
│                                          │
│                                          │
│                                          │
│                                          │
│              ○ ○ ○ ●                     │
│                                          │
│    [ 📸 Scan My First Sub ]              │
│                                          │
│    Skip for now                          │
│                                          │
└─────────────────────────────────────────┘
```

### Content
- **Asset:** `Mascot.celebrate` — 200px, centred
- **Headline:** `Ready to take control?`
- **Body:** `3 free scans to start.\nNo subscription needed.\n(The irony isn't lost on us.)`
- **Primary CTA:** `📸 Scan My First Sub` — full width mint button, navigates to scan screen
- **Secondary CTA:** `Skip for now` — text link below, navigates to home screen
- **Animation:** Snappy drops in from above with a bounce (like landing). Confetti particles burst briefly on landing. CTA buttons fade in after Snappy lands (200ms delay).

### CTA Styling
```dart
// Primary button
SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton(
    onPressed: () => _completeOnboarding(goToScan: true),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.mint,
      foregroundColor: AppColors.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
    child: const Text('📸  Scan My First Sub'),
  ),
),
const SizedBox(height: 12),

// Skip link
TextButton(
  onPressed: () => _completeOnboarding(goToScan: false),
  child: Text(
    'Skip for now',
    style: TextStyle(
      fontSize: 13,
      color: AppColors.textDim,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.textDim.withOpacity(0.5),
    ),
  ),
),
```

### Complete Onboarding Handler
```dart
Future<void> _completeOnboarding({required bool goToScan}) async {
  // Set seen flag
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_seen', true);

  if (goToScan) {
    // Go directly to scan screen
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => const ScanScreen(),
    ));
  } else {
    // Go to home
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    ));
  }
}
```

---

## Cross-Page Animation Details

### Snappy Transition Between Pages
Snappy should feel like he's one character moving through the screens, not 4 separate images.

```dart
// Option A — Hero animation (simplest)
// Wrap each Snappy image in a Hero widget with the same tag:
Hero(
  tag: 'snappy',
  child: Image.asset(currentPose, width: poseSize),
)
// This gives a smooth morph between poses as pages swipe

// Option B — If Hero doesn't work well with PageView (it can be janky),
// use AnimatedSwitcher with a fade:
AnimatedSwitcher(
  duration: const Duration(milliseconds: 400),
  switchInCurve: Curves.easeOut,
  child: Image.asset(
    currentPose,
    key: ValueKey(currentPage),
    width: poseSize,
  ),
)
```

### Page Indicator Dots
Already built — but make sure they use the design system colours:
```dart
// Active dot: AppColors.mint, 8px diameter
// Inactive dot: AppColors.textDim.withOpacity(0.3), 6px diameter
// Spacing: 8px between dots
// Animation: smooth scale + colour transition (200ms)
```

### Background
Each page should have a subtle, unique background accent to differentiate:
- Page 1: Radial mint glow (top centre, 15% opacity)
- Page 2: No accent (clean)
- Page 3: Subtle amber glow (matching trap warning theme, 8% opacity)
- Page 4: Radial mint glow (bottom centre, 15% opacity) — brighter, energy

All on top of the standard `AppColors.bg` (#07070C).

---

## Assets Needed Per Screen

| Screen | Asset | Status |
|---|---|---|
| 1. Welcome | `snappy_wave.png` | ✅ Generated |
| 2. How It Works | `snappy_full.png` | ✅ Generated |
| 3. Trap Scanner | `snappy_thinking.png` | ✅ Generated |
| 4. Get Started | `snappy_celebrate.png` | ✅ Generated |

All 4 assets are already generated from the MJ session. Just need background removal and export at @1x/@2x/@3x.

---

## Key Copy Decisions

- **Tone:** Friendly, slightly cheeky, never corporate. Snappy talks like a mate, not a bank.
- **Length:** Headlines 4-6 words max. Body text 2-3 lines max.
- **The "irony" line** on screen 4 is deliberate — acknowledges that a subscription tracker not being a subscription is a selling point. Users appreciate self-awareness.
- **Screen 3 uses a real example** — the £1 health app trap is based on a true story (Pete's wife). This is way more powerful than generic feature marketing.
- **"Fight back"** language throughout reinforces the defence positioning.

---

## Files Modified

**Modified:**
- `lib/screens/onboarding/onboarding_screen.dart` — replace existing page content with Snappy + new copy + animations

**No new files needed** — the onboarding screen structure already exists. This is a content + asset update.
