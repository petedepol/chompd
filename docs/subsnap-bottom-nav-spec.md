# SubSnap Bottom Nav — Implementation Spec (D3 Liquid Glass)

## Overview
Replace the current bottom navigation bar with a floating glassmorphic nav bar using the iOS 26 Liquid Glass aesthetic. Three tabs: Subs (home), Scan (centre FAB), Saved. Custom SVG icons with micro-animations.

## Architecture
- Widget: `BottomNavBar` — a `StatefulWidget` positioned with `Scaffold.bottomNavigationBar` or a `Stack` overlay
- State: managed via Riverpod — `bottomNavIndexProvider` (0 = Subs, 1 = Scan, 2 = Saved)
- The nav overlays content — content should have bottom padding of ~100px to avoid clipping

## Visual Spec

### Glass Bar Container
```
- Position: floating, 20px horizontal margin, 22px bottom margin
- Background: Colors.white.withOpacity(0.035)
- Backdrop blur: 40px (use BackdropFilter + ClipRRect)
- Border radius: 26px
- Border: 1px solid Colors.white.withOpacity(0.07)
- Box shadow: 
  - Outer: BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: Offset(0, 4))
  - Inner highlight: simulate with a 1px top border at Colors.white.withOpacity(0.05)
- Padding: 5px all sides
```

### Gradient Fade Above Bar
```
- Container above the nav bar
- Height: ~60px
- Gradient: transparent → background color (0x07070C) at ~35% → solid at 100%
- IgnorePointer so content behind remains scrollable
```

### Ambient Orbs (Behind Glass)
```
- Two Container widgets positioned behind the glass bar
- Orb 1: left 25%, width 80, height 40, radial gradient mint (#6EE7B7) at 5% opacity, blur 14
- Orb 2: right 22%, width 60, height 35, radial gradient purple (#A78BFA) at 4% opacity, blur 12
- Both: slow translate animation, 8-10s duration, ease-in-out, repeat
- Use AnimationController + Transform.translate with sin/cos for organic drift
```

## Tab Buttons

### Subs Tab (index 0) — Card Stack Icon
```
Active state:
- Background: mint.withOpacity(0.08)
- Border: 1px solid mint.withOpacity(0.09)
- Border radius: 20
- Subtle glow pulse: animate boxShadow opacity 0.08 → 0.15 over 3s
- Padding: 7px horizontal 22px, 5px vertical

Inactive state:
- Background: transparent
- Border: transparent
- Same padding
```

#### Card Stack SVG Icon (22x22 viewBox 0 0 24 24)
```xml
<!-- Back card (rotated -3deg) -->
<rect x="5" y="4" width="14" height="10" rx="2.5"
  fill="[active ? mint@10% : none]"
  stroke="[active ? mint@33% : textDim@33%]"
  stroke-width="1.2"
  transform="rotate(-3 12 9)" />

<!-- Front card -->
<rect x="4" y="6" width="16" height="11" rx="2.5"
  fill="[active ? mint@12% : none]"
  stroke="[active ? mint : textDim]"
  stroke-width="1.5" />

<!-- Detail lines on card -->
<line x1="7.5" y1="10" x2="12" y2="10" stroke="[active ? mint : textDim]" stroke-width="1.2" opacity="0.6" />
<line x1="7.5" y1="13" x2="16.5" y2="13" stroke="[active ? mint : textDim]" stroke-width="1.2" opacity="0.4" />

<!-- £ symbol on card -->
<text x="15" y="10.5" font-size="4" fill="[active ? mint : textDim]" font-weight="700" opacity="0.7">£</text>

<!-- When active: subtle pulse on outer card rect -->
Animate stroke opacity 0.3 → 0.1 → 0.3 over 2.5s repeat
```

#### Label: "SUBS"
```
- Font: Space Mono, 7.5px, letter-spacing 0.08em
- Active: mint, weight 700
- Inactive: textDim (#6a6a82), weight 400
- Transition: color 300ms
```

#### Active Indicator Bar
```
- Width: 14px, height: 2.5px, border-radius: 2
- Color: mint
- Box shadow: 0 0 8px mint@37%
- Animate in: scale from 0 to 1, 300ms ease
- Only visible when active
```

### Scan FAB (centre, index 1)

#### Button
```
- Size: 56x56
- Border radius: 18
- Offset: marginTop -26 (raised above the glass bar)
- Background: LinearGradient(begin: topLeft, end: bottomRight, colors: [#34D399@93%, #6EE7B7@87%])
- Clip: overflow hidden (for specular sweep)
```

#### Breathing Glow Animation
```
- Animate box shadow: 
  - Rest: BoxShadow(color: mint@25%, blur: 20, offset: Offset(0, 6))
  - Peak: BoxShadow(color: mint@45%, blur: 32, offset: Offset(0, 8))
- Duration: 3.5s, ease-in-out, repeat forever
- Also include: inset highlight simulation — top border Colors.white@20%
```

#### Specular Light Sweep
```
- A thin vertical gradient bar (30% width, full height) that translates from left -120% to right +220%
- Gradient: transparent → white@15% → transparent
- Rotated 25deg
- Duration: 4s, ease-in-out, repeat forever
- Clipped inside the FAB's border radius
```

#### Specular Highlight (Static)
```
- Positioned: top 3px, left 12%, right 12%, height 14px
- Gradient: white@30% top → transparent bottom
- Border radius: 50% (ellipse)
- Purely decorative, no animation
```

#### Icon: Camera with Rotating Lens Ring (24x24)
```xml
<!-- Camera body -->
<rect x="2" y="7" width="20" height="14" rx="3" stroke="bgColor" stroke-width="2" />

<!-- Lens bump -->
<path d="M8 7V5.5A1.5 1.5 0 019.5 4h5A1.5 1.5 0 0116 5.5V7" stroke="bgColor" stroke-width="2" />

<!-- Lens outer ring -->
<circle cx="12" cy="14" r="4.5" stroke="bgColor" stroke-width="1.5" />

<!-- Rotating dashed inner ring -->
<circle cx="12" cy="14" r="2.5" stroke="bgColor" stroke-width="0.8" stroke-dasharray="3 2"
  <!-- Rotate 360deg over 6s, repeat forever --> />

<!-- Lens centre -->
<circle cx="12" cy="14" r="1.2" fill="bgColor" opacity="0.4" />

<!-- Lens highlight -->
<circle cx="10.5" cy="12.5" r="1" fill="white@35%" />

<!-- Flash indicator (pulsing) -->
<circle cx="18" cy="9.5" r="0.8" fill="white@50%"
  <!-- Animate opacity 0.3 → 0.7 → 0.3, 2s repeat --> />
```

#### Tap Feedback
```
- On tap down: scale to 0.9 over 150ms
- On tap up: scale back to 1.0
- Trigger: HapticFeedback.mediumImpact()
- Navigate to scan screen
```

### Saved Tab (index 2) — Shield Icon

#### Shield SVG Icon (22x22 viewBox 0 0 24 24)
```xml
<!-- Shield shape -->
<path d="M12 3L4 7v5c0 5 3.5 8.5 8 10 4.5-1.5 8-5 8-10V7l-8-4z"
  fill="[active ? mint@9% : none]"
  stroke="[active ? mint : textDim]"
  stroke-width="1.5"
  stroke-linejoin="round" />

<!-- £ symbol centred -->
<text x="9" y="16" font-size="9" fill="[active ? mint : textDim]" font-weight="700" opacity="0.8">£</text>

<!-- Sparkles when active (3 circles, staggered animation) -->
<!-- Sparkle 1: cx=18, cy=5, animate r 0.5→1.2→0.5 and opacity 0→0.6→0, 1.8s repeat -->
<!-- Sparkle 2: cx=6, cy=4, same but 2.2s, delayed 0.5s -->
<!-- Sparkle 3: cx=20, cy=10, r=0.6, opacity pulse 0→0.4→0, 2.5s, delayed 1s -->
```

Same label, indicator bar, and tap behaviour as Subs tab.

## Colour Tokens
```dart
static const bg = Color(0xFF07070C);
static const bgCard = Color(0xFF111118);
static const bgElevated = Color(0xFF1A1A24);
static const border = Color(0xFF242436);
static const text = Color(0xFFF0F0F5);
static const textMid = Color(0xFFA0A0B8);
static const textDim = Color(0xFF6A6A82);
static const mint = Color(0xFF6EE7B7);
static const mintDark = Color(0xFF34D399);
static const purple = Color(0xFFA78BFA);
```

## Typography
```dart
// Tab labels
TextStyle(
  fontFamily: 'SpaceMono',
  fontSize: 7.5,
  letterSpacing: 0.08 * 7.5, // 0.08em
  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
  color: isActive ? mint : textDim,
)
```

## Animation Controllers
```
1. breatheController — 3.5s, repeat, drives FAB glow
2. specularController — 4s, repeat, drives light sweep
3. orbController — 8s + 10s (two controllers), repeat, drives ambient orb drift
4. tabGlowController — 3s, repeat, drives active tab shadow pulse
5. indicatorController — 300ms, forward only, drives underline bar scale-in
```

Dispose all controllers in dispose(). Use `TickerProviderStateMixin` for multiple controllers.

## Haptic Feedback Map
```dart
// Tab switch
HapticFeedback.selectionClick();

// Scan button tap  
HapticFeedback.mediumImpact();
```

## Implementation Notes
- Use `CustomPaint` or `SvgPicture.string()` for the SVG icons — string SVGs keep everything self-contained
- The rotating lens ring on the scan icon: use `AnimatedBuilder` with a `Transform.rotate` wrapping just that circle
- Sparkles on the shield: use `FadeTransition` with staggered `AnimationController`s or a single controller with `Interval` curves
- The ambient orbs should use `sin()` and `cos()` with different frequencies for organic movement
- Test BackdropFilter performance on mid-range Android — if laggy, reduce blur to 20 and remove one orb
- Content beneath nav needs `padding-bottom: 100` to prevent last card clipping behind the bar
- The gradient fade is a separate `IgnorePointer` widget in the Stack, sitting between content and the nav bar
