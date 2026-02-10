# SubSnap — 2026 Design Trends & Visual Polish Guide

> Feed this to Claude Code during Sprint 6 (Polish) or whenever refining UI.
> Compiled from: Dribbble, Behance, Revolut, Trackizer, Wealthsimple, Apple Liquid Glass docs, NN/g, fintech UX research (2025-2026).

---

## The Big Picture: What's Defining 2026 Mobile Finance

Three forces are converging:

1. **Apple Liquid Glass** (iOS 26, Sept 2025) — translucent, refractive materials are now the system standard. Every iOS user sees glass-like nav bars, floating tab bars, and layered depth daily. Apps that don't acknowledge this look dated.

2. **Dark Glassmorphism** — the marriage of dark mode + frosted glass. Not the 2021 Dribbble version (too much blur, unreadable). The 2026 version is *restrained*: dark backgrounds with subtle glass panels, ambient colour gradients behind the glass, high-contrast text on top.

3. **Emotional Fintech** — finance apps are no longer cold dashboards. Revolut, Monzo, Wealthsimple, and Monobank prove that personality, gamification, and "feeling good about money" drive retention. SubSnap fits perfectly here — tracking subscriptions is anxiety-inducing, so the app should make it feel *empowering*.

---

## 1. Dark Theme — Do It Right

SubSnap ships dark-only for v1. Here's how to make it premium, not just "black".

### Layered Depth (Not Flat Black)
Use 3-4 background tiers to create spatial hierarchy:

```
Level 0 (canvas):     #07070C  — deepest background
Level 1 (card):       #111118  — subscription cards, sections
Level 2 (elevated):   #1A1A24  — modals, bottom sheets, active states
Level 3 (glass):      rgba(26,26,36,0.85) + blur  — nav bar, overlays
```

**Why:** Flat #000000 looks cheap on OLED. Layered dark greys with slight blue/purple undertones feel premium (see: Revolut dark mode, Fey investment app, Discord).

### Ambient Colour Behind Glass
For any glass/translucent element, place subtle gradient orbs behind it:
- Deep purple (#A78BFA at 8% opacity)
- Mint (#6EE7B7 at 6% opacity)
- These create the "something to refract" that makes glass effects work

### Text Contrast Rules
- Primary text: #F0F0F5 (not pure white — reduces eye strain)
- Secondary: #A0A0B8
- Tertiary/disabled: #6A6A82
- **Minimum contrast ratio:** 4.5:1 for body text, 3:1 for large text
- Test on real devices in both daylight and dark rooms

### What NOT To Do
- Don't make everything transparent — NN/g's critique of Liquid Glass applies: "anything placed on top of something else becomes harder to see"
- Glass effects on navigation and overlays only, never on content cards with data
- No glass on the spending ring or price text — those need rock-solid legibility

---

## 2. Glassmorphism — Restrained, Not Overdone

### Where To Use Glass in SubSnap
✅ Bottom navigation bar (floating, with backdrop blur)
✅ AI scan conversation overlay
✅ Modal sheets (paywall, add subscription)
✅ Toast notifications (temporary, brief)

### Where NOT To Use Glass
❌ Subscription cards (need clear price readability)
❌ Spending ring / data visualisations
❌ Settings screens (functional, not decorative)
❌ Reminder toggles and form inputs

### Implementation in Flutter
```dart
// Glass panel effect
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: content,
    ),
  ),
)
```

### Key Parameters
- Blur: sigmaX/Y 12-20 (not more — performance cost on older devices)
- Background opacity: 0.04-0.08 white on dark (subtle, not milky)
- Border: 1px white at 6-10% opacity (defines the edge)
- Test on mid-range Android devices — blur is GPU-expensive

---

## 3. Typography That Signals Premium

### The Dual-Font Strategy
SubSnap uses two typefaces with distinct roles:

**Data font — Space Mono (monospace)**
- All prices: £15.99/mo
- Dates: 14 Mar 2026
- Counters: 3 of 3 free scans
- Tier labels: TIER 1, AUTO-DETECT
- Savings totals: +£313.92

**UI font — System default (SF Pro / Roboto)**
- Navigation labels
- Button text
- Descriptions and body copy
- Conversational AI messages

**Why monospace for money?** It creates visual alignment in lists (prices stack neatly), signals precision/data, and gives a fintech "terminal" feel that reads as trustworthy. Revolut, Wise, and most crypto apps use monospace for figures.

### Type Scale
```
XS:   10px — labels, badges, metadata
SM:   12px — secondary text, card descriptions  
BASE: 14px — body text, button labels
LG:   16px — section headers, screen titles
XL:   20px — screen hero titles
XXL:  28px — spending ring total, savings counter
HERO: 48px — money saved celebration number
```

### Bold Typography Trend 2026
- Screen titles can be bolder and larger than 2024 conventions
- "Money Saved: £313.92" should be the biggest, proudest element on the savings screen
- Treat key numbers as *hero content*, not just data

---

## 4. Colour System — Semantic, Not Decorative

### Primary Palette
```
Mint:    #6EE7B7 → #34D399  (gradient pair — primary accent, positive actions)
Amber:   #FBBF24              (warnings: trials expiring, approaching budget)
Red:     #F87171              (danger: overdue, cancel, over budget)
Purple:  #A78BFA              (AI/intelligence indicators)
Blue:    #60A5FA              (informational, confirmations)
```

### How Colour Tells Stories
| State | Colour | Example |
|---|---|---|
| Active, healthy sub | Mint text/borders | "Renews in 22 days" |
| Trial expiring soon | Amber badge + pulse | "3d trial" with glow |
| Over budget | Red ring + text | Ring turns red, "£12 over budget" |
| AI scanning | Purple shimmer | Scan animation accent |
| Money saved | Mint celebration | "+£313" with confetti |
| Cancelled sub | Dimmed + strikethrough | Grey text, mint saved amount |

### Service Brand Colours
Each subscription card uses the service's actual brand colour for its icon background:
- Netflix: #E50914
- Spotify: #1DB954
- Figma: #A259FF

This creates visual variety within a consistent system. The brand colour appears ONLY on the icon dot — never on the card background (keeps the dark theme consistent).

### Glow Effects
Subtle coloured glows (box-shadow or outer shadow) create depth:
```dart
// Mint glow for positive actions
BoxShadow(
  color: Color(0xFF6EE7B7).withOpacity(0.15),
  blurRadius: 20,
  spreadRadius: -4,
)

// Amber glow for trial warnings
BoxShadow(
  color: Color(0xFFFBBF24).withOpacity(0.12),
  blurRadius: 16,
  spreadRadius: -4,
)
```
Use sparingly — 2-3 glowing elements per screen maximum.

---

## 5. Microinteractions — The Invisible Polish

Research shows well-designed microinteractions boost 30-day retention by 23% and reduce support tickets by 18%. These are the ones that matter for SubSnap:

### P0 — Must Have (Sprint 6)

**Scan Shimmer**
- Sweeping light passes across the screenshot during AI analysis
- Linear gradient moving left-to-right, 1.8s loop
- Stops when analysis completes, transitions to result
- Conveys "AI is working" without a boring spinner

**Add Confirmation**
- Button: pulse glow → tap → shrink slightly → checkmark draws → "Added ✓"
- Haptic: `HapticFeedback.mediumImpact()` on success
- Toast slides up from bottom with service icon + name
- Total: 0.8s feel-good moment

**Number Transitions**
- Spending ring total should *count up* when the screen loads (0.6s)
- When adding/removing a sub, the total animates to new value
- Use `TweenAnimationBuilder` or `AnimatedSwitcher` with `SlideTransition`

**Card Entrance**
- Subscription cards stagger-animate on first load
- Each card fades up (translateY: 12→0, opacity: 0→1)
- 50ms delay between each card
- Gives a "waterfall" effect that feels alive

### P1 — Should Have (Sprint 6-7)

**Trial Countdown Pulse**
- Amber badges on trial subs pulse subtly (opacity 1→0.6→1, 1.5s)
- Only for trials ≤7 days — don't pulse everything
- Draws the eye to urgency without being annoying

**Swipe Actions**
- Swipe left on subscription card → delete (red background slides in)
- Swipe right → edit (blue background)
- Spring physics on the swipe (slight overshoot + settle)

**Pull to Refresh**
- Custom pull indicator using the SubSnap logo or a mint-coloured ring
- Not the default Material/Cupertino spinner

**Tab Bar Interaction**
- Active tab icon scales up slightly (1.0→1.15) with spring curve
- Inactive tabs dim to textDim colour
- Haptic: `HapticFeedback.selectionClick()` on tab switch

### P2 — Nice to Have (Sprint 7+)

**Confetti Burst**
- Triggers on savings milestones (£50, £100, £250, £500)
- Lottie animation, 1.5s duration, doesn't block interaction
- Paired with `HapticFeedback.heavyImpact()`

**Spending Ring Draw**
- On first load, the ring "draws" from 0 to current percentage
- Use `TweenAnimationBuilder` with 1.2s ease-out curve
- Combined with the number count-up for a satisfying reveal

**Parallax on Cards**
- Slight parallax/tilt effect on subscription detail hero card
- Responds to device accelerometer (subtle, 2-3px movement)
- Premium feel, like Revolut's card widget

---

## 6. Haptic Feedback Map

Haptics are free polish. Every fintech app worth using in 2026 has them. Here's SubSnap's haptic map:

```dart
// SUCCESS — Subscription added, scan complete, save confirmed
HapticFeedback.mediumImpact();

// WARNING — Trial expiring notification, approaching budget
HapticFeedback.heavyImpact();

// SELECTION — Tab switch, option selected in Q&A, toggle
HapticFeedback.selectionClick();

// ERROR — Scan failed, network error
HapticFeedback.heavyImpact(); // doubled with 50ms gap

// CELEBRATION — Milestone reached, confetti moment
HapticFeedback.heavyImpact(); // paired with confetti animation
```

**Rules:**
- Never haptic on scroll or passive viewing
- Always haptic on user-initiated state changes
- Provide a "Haptics Off" toggle in settings
- Test on real devices — emulators don't convey feel

---

## 7. Gamification — Make Saving Money Feel Good

This is SubSnap's emotional differentiator. Cancelling subscriptions is anxiety-inducing ("what if I need it?"). The app should celebrate the decision.

### Money Saved Counter
- Hero element on the Saved screen
- Largest text in the app (48px, Space Mono, mint)
- Counts up on load with number roll animation
- Shows equivalencies: "That's 69 coffees ☕ or 19 months of Netflix"
- Updates in real-time when a sub is cancelled

### Milestone System
Progressive goals that unlock celebrations:

| Amount | Emoji | Name | Reward |
|---|---|---|---|
| £50 | ☕ | Coffee Fund | Confetti burst |
| £100 | 🎮 | Game Pass | Confetti + share prompt |
| £250 | ✈️ | Weekend Away | Confetti + badge |
| £500 | 💻 | New Gadget | Confetti + special badge |
| £1000 | 🏝️ | Dream Holiday | Full celebration screen |

### Progress Bars on Milestones
- Horizontal scrollable milestone cards
- Each shows progress bar toward next milestone
- Reached milestones glow mint, unreached are greyed
- Creates a "just £23 more" motivation loop

### Share Card
- "Share My Savings" generates a branded card image
- Shows: SubSnap logo, total saved, time period, milestone badges
- Optimised for Instagram Stories (9:16) and Twitter (16:9)
- Free marketing — users showing off savings = organic growth

### Cancelled Sub "Graveyard"
- Don't just delete cancelled subs — celebrate them
- Show each with: original price, months since cancellation, total saved
- Strikethrough on the name, mint "+£X saved" on the right
- Makes the act of cancelling feel like a *win*

---

## 8. Navigation — iOS 26 Aware

### Bottom Tab Bar
With iOS 26 Liquid Glass, system tab bars are now translucent and float. SubSnap should mirror this:

```
[🏠 Home]    [📸 SCAN]    [💰 Saved]
```

- 3 tabs only (simplicity)
- Centre tab (Scan) is elevated — the signature action
  - Larger icon, mint gradient background, raised above the bar
  - Subtle glow underneath
- Bar itself: glass material (BackdropFilter blur, slight white border)
- On scroll: bar can optionally shrink (matching iOS 26 behaviour)

### Screen Transitions
- Push transitions for drill-down (Home → Detail)
- Bottom sheet for quick actions (Add manually, Edit)
- Full-screen modal for Scan flow and Paywall
- Shared element transition: subscription icon animates from card to detail hero

### Gesture Navigation
- Swipe back from left edge (standard iOS)
- Swipe down to dismiss bottom sheets
- Long press on subscription card → quick actions context menu

---

## 9. The Scan Screen — Your Showpiece

The AI scan is what makes SubSnap different. It needs to feel *magical*.

### Visual Flow
1. **Screenshot appears** — slight scale-up animation (0.95→1.0), subtle shadow
2. **Shimmer sweeps** — linear gradient light passes across the image (1.8s loop)
3. **Highlights extract** — key data points (price, date, service name) briefly glow/outline on the screenshot
4. **Typing indicator** — 3 bouncing dots (like iMessage) while AI processes
5. **Result card slides in** — from bottom, spring animation, with service icon
6. **Confidence badge** — "98% confident" in mint, or "78%" in amber with question
7. **Questions (if needed)** — conversational bubbles, option pills with tap feedback
8. **Add button** — appears with glow pulse, haptic on tap, checkmark draw on confirm

### Key Visual Details
- AI messages come from a bot avatar (small mint gradient circle with 🤖)
- User responses appear right-aligned in mint-tinted bubbles
- The "Other" option in Q&A reveals a text input inline
- Scan cost badge at bottom: "⚡ Tier 1 · $0.00 · DB match" — builds trust in the flywheel

### Performance Feel
- The entire scan should feel FAST even if the API takes 2-3 seconds
- Front-load the shimmer animation to cover latency
- Show partial results as they arrive (service name first, then price, then date)
- Never show a loading spinner — the shimmer IS the loading state

---

## 10. Paywall — Sell Without Sleaze

### Psychology
The paywall triggers at a natural limit (3 subs or 3 scans). The user has already experienced value. The paywall should feel like "unlocking more of something great" not "pay to remove a wall."

### Visual Treatment
- Dim/blur the background (the home screen they were just using)
- Feature list with small icons — 6 features, each 1 line
- Price card with gradient glow: "£4.99 — one-time payment"
- Tagline in italic: "A subscription tracker that isn't a subscription." 🎯
- CTA button: full-width mint gradient with glow animation
- "Restore Purchase" link below in dim text

### What NOT To Do
- No countdown timers or fake urgency
- No "70% OFF!" — it's already cheap at £4.99
- No comparison table with checkmarks (feels enterprise-y)
- No multiple pricing tiers — one price, simple

---

## 11. App Icon — iOS 26 Liquid Glass Ready

### Requirements for iOS 26
- 1024×1024 master, layered (foreground + background)
- Must work in Light, Dark, and Clear (transparent) modes
- Round-rect mask applied by system — keep elements centred
- Specular highlights and glass shimmer applied by iOS automatically

### SubSnap Icon Concept
- Background layer: dark (#111118) with subtle mint gradient
- Foreground layer: stylised camera/snap icon merged with a receipt/list
- Mint accent colour (#6EE7B7) as the primary icon colour
- Simple silhouette that reads at 29×29 on the home screen
- In "Clear" mode on iOS 26, the icon becomes semi-transparent — ensure the silhouette is strong enough to read

### Generate Options
Use AI image generation (Midjourney, DALL-E) to explore concepts, then refine the winner in Figma or Illustrator. Key prompt elements:
- "Minimalist app icon, dark background, mint green accent"
- "Camera shutter + receipt list, single colour, simple geometry"
- "Subscription tracker icon, modern, clean silhouette"

---

## 12. Platform-Specific Polish

### iOS
- Use Cupertino widgets where appropriate (CupertinoActionSheet for delete confirmation)
- Respect safe areas (notch, Dynamic Island, home indicator)
- Support Dynamic Type (accessibility text scaling)
- SF Symbols for system icons where possible (or Lucide as cross-platform alternative)

### Android
- Material You dynamic colour is available but SubSnap uses its own theme — override it
- Edge-to-edge display (transparent status/nav bars)
- Predictive back gesture support
- Adaptive icon with foreground/background layers

### Both Platforms
- Minimum touch target: 44×44 points (Apple HIG) / 48×48dp (Material)
- Support reduced motion preference (`MediaQuery.of(context).disableAnimations`)
- Test with screen readers (VoiceOver / TalkBack)
- Add semantic labels to all interactive elements

---

## Summary — SubSnap Design DNA

| Principle | Implementation |
|---|---|
| Dark-first with depth | 3-4 layered background tiers, not flat black |
| Restrained glass | Glass on nav + overlays only, never on data |
| Dual typography | Space Mono for money, system font for UI |
| Semantic colour | Mint = good, Amber = caution, Red = danger |
| Purposeful motion | Every animation serves feedback, not decoration |
| Haptic conversation | Touch confirms every state change |
| Emotional finance | Celebrate savings, gamify cancellation |
| Scan = magic | Shimmer → extract → confirm → celebrate |
| Honest paywall | Value first, simple price, no manipulation |
| iOS 26 native feel | Liquid Glass aware, adaptive icon, system gestures |

**The one thing someone should remember about SubSnap's design:**
It makes tracking subscriptions feel like *winning*, not worrying.
