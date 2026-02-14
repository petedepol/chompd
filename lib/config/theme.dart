import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Chompd Design System v2 — Dark & Light Themes
///
/// Updated colour tokens from the theme v2 spec.
/// Typography: System default for UI, Space Mono for data/prices.

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DARK THEME COLOURS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ChompdColors {
  ChompdColors._();

  // ─── Backgrounds (deep green-black) ───
  static const bg = Color(0xFF0B0F0E);
  static const bgCard = Color(0xFF141C1A);       // = surface
  static const bgElevated = Color(0xFF1A2422);    // = card
  static const bgGlass = Color(0xD91A2422);       // 85% opacity of card

  // ─── Borders ───
  static const border = Color(0xFF243430);        // = cardBorder
  static const borderLight = Color(0xFF2A3632);
  static const borderHighlight = Color(0xFF2A3632);

  // ─── Text ───
  static const text = Color(0xFFF0F5F3);
  static const textMid = Color(0xFF8A9B95);
  static const textDim = Color(0xFF5A6B65);

  // ─── Accent: Teal (primary) ───
  static const mint = Color(0xFF4ECCA3);
  static const mintDark = Color(0xFF4ECCA3);
  static const mintGlow = Color(0x1F4ECCA3);      // 12% opacity

  // ─── Semantic Colours ───
  static const amber = Color(0xFFE8B341);
  static const amberGlow = Color(0x1FE8B341);
  static const red = Color(0xFFE85D4A);
  static const redGlow = Color(0x1FE85D4A);
  static const purple = Color(0xFF9B7FE6);
  static const blue = Color(0xFF4A9DE8);
  static const pink = Color(0xFFF472B6);

  // ─── New v2 tokens ───
  static const surface = Color(0xFF141C1A);
  static const card = Color(0xFF1A2422);
  static const cardBorder = Color(0xFF243430);
  static const accentSoft = Color(0x1F4ECCA3);    // 12% opacity
  static const divider = Color(0xFF1E2D28);
  static const toggleOn = Color(0xFF4ECCA3);
  static const toggleOff = Color(0xFF2A3632);
  static const ringTrack = Color(0xFF1E2D28);
  static const proTag = Color(0xFF9B7FE6);
  static const proTagBg = Color(0x269B7FE6);      // 15% opacity
  static const warningSoft = Color(0x1FE8B341);
  static const dangerSoft = Color(0x1FE85D4A);
  static const infoSoft = Color(0x1F4A9DE8);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIGHT THEME COLOURS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ChompdColorsLight {
  ChompdColorsLight._();

  // ─── Backgrounds (warm parchment) ───
  static const bg = Color(0xFFF4F1EC);
  static const bgCard = Color(0xFFFAFAF8);        // = surface
  static const bgElevated = Color(0xFFFFFFFF);     // = card
  static const bgGlass = Color(0xD9FFFFFF);

  // ─── Borders ───
  static const border = Color(0xFFE8E3DB);        // = cardBorder
  static const borderLight = Color(0xFFD4CFC7);
  static const borderHighlight = Color(0xFFE8E3DB);

  // ─── Text ───
  static const text = Color(0xFF1A2B25);
  static const textMid = Color(0xFF566560);        // ~5.1:1 vs parchment
  static const textDim = Color(0xFF6E7B76);        // ~4.5:1 vs parchment (WCAG AA)

  // ─── Accent: Forest green ───
  static const mint = Color(0xFF1B8F6A);
  static const mintDark = Color(0xFF1B8F6A);
  static const mintGlow = Color(0x141B8F6A);       // 8% opacity

  // ─── Semantic Colours ───
  static const amber = Color(0xFFC4890E);
  static const amberGlow = Color(0x14C4890E);
  static const red = Color(0xFFC9402E);
  static const redGlow = Color(0x14C9402E);
  static const purple = Color(0xFF7B5FC4);
  static const blue = Color(0xFF2D7BC4);
  static const pink = Color(0xFFEC4899);

  // ─── New v2 tokens ───
  static const surface = Color(0xFFFAFAF8);
  static const card = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE8E3DB);
  static const accentSoft = Color(0x141B8F6A);    // 8% opacity
  static const divider = Color(0xFFE8E3DB);
  static const toggleOn = Color(0xFF1B8F6A);
  static const toggleOff = Color(0xFFD4CFC7);
  static const ringTrack = Color(0xFFE8E3DB);
  static const proTag = Color(0xFF7B5FC4);
  static const proTagBg = Color(0x1A7B5FC4);      // 10% opacity
  static const warningSoft = Color(0x14C4890E);
  static const dangerSoft = Color(0x14C9402E);
  static const infoSoft = Color(0x142D7BC4);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// THEME-AWARE COLOUR SET (context.colors)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Extension to get the correct colour tokens based on brightness.
///
/// Usage: `context.colors.bg`, `context.colors.accent`, etc.
extension ChompdColorScheme on BuildContext {
  _ChompdColorSet get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? _ChompdColorSet.dark : _ChompdColorSet.light;
  }

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

class _ChompdColorSet {
  // ─── Backgrounds ───
  final Color bg;
  final Color surface;
  final Color card;
  final Color bgGlass;

  // ─── Backward compat aliases ───
  Color get bgCard => surface;
  Color get bgElevated => card;

  // ─── Borders ───
  final Color cardBorder;
  final Color borderLight;
  final Color borderHighlight;

  // Backward compat alias
  Color get border => cardBorder;

  // ─── Text ───
  final Color text;
  final Color textMid;
  final Color textDim;

  // ─── Accent ───
  final Color accent;
  final Color accentSoft;
  final Color mintGlow;

  // Backward compat aliases
  Color get mint => accent;
  Color get mintDark => accent;

  // ─── Semantic ───
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;
  final Color proTag;
  final Color proTagBg;
  final Color pink;

  // Backward compat aliases
  Color get amber => warning;
  Color get amberGlow => warningSoft;
  Color get red => danger;
  Color get redGlow => dangerSoft;
  Color get blue => info;
  Color get purple => proTag;

  // ─── UI Components ───
  final Color divider;
  final Color toggleOn;
  final Color toggleOff;
  final Color ringTrack;

  const _ChompdColorSet({
    required this.bg,
    required this.surface,
    required this.card,
    required this.bgGlass,
    required this.cardBorder,
    required this.borderLight,
    required this.borderHighlight,
    required this.text,
    required this.textMid,
    required this.textDim,
    required this.accent,
    required this.accentSoft,
    required this.mintGlow,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
    required this.proTag,
    required this.proTagBg,
    required this.pink,
    required this.divider,
    required this.toggleOn,
    required this.toggleOff,
    required this.ringTrack,
  });

  static const dark = _ChompdColorSet(
    bg: ChompdColors.bg,
    surface: ChompdColors.surface,
    card: ChompdColors.card,
    bgGlass: ChompdColors.bgGlass,
    cardBorder: ChompdColors.cardBorder,
    borderLight: ChompdColors.borderLight,
    borderHighlight: ChompdColors.borderHighlight,
    text: ChompdColors.text,
    textMid: ChompdColors.textMid,
    textDim: ChompdColors.textDim,
    accent: ChompdColors.mint,
    accentSoft: ChompdColors.accentSoft,
    mintGlow: ChompdColors.mintGlow,
    warning: ChompdColors.amber,
    warningSoft: ChompdColors.warningSoft,
    danger: ChompdColors.red,
    dangerSoft: ChompdColors.dangerSoft,
    info: ChompdColors.blue,
    infoSoft: ChompdColors.infoSoft,
    proTag: ChompdColors.proTag,
    proTagBg: ChompdColors.proTagBg,
    pink: ChompdColors.pink,
    divider: ChompdColors.divider,
    toggleOn: ChompdColors.toggleOn,
    toggleOff: ChompdColors.toggleOff,
    ringTrack: ChompdColors.ringTrack,
  );

  static const light = _ChompdColorSet(
    bg: ChompdColorsLight.bg,
    surface: ChompdColorsLight.surface,
    card: ChompdColorsLight.card,
    bgGlass: ChompdColorsLight.bgGlass,
    cardBorder: ChompdColorsLight.cardBorder,
    borderLight: ChompdColorsLight.borderLight,
    borderHighlight: ChompdColorsLight.borderHighlight,
    text: ChompdColorsLight.text,
    textMid: ChompdColorsLight.textMid,
    textDim: ChompdColorsLight.textDim,
    accent: ChompdColorsLight.mint,
    accentSoft: ChompdColorsLight.accentSoft,
    mintGlow: ChompdColorsLight.mintGlow,
    warning: ChompdColorsLight.amber,
    warningSoft: ChompdColorsLight.warningSoft,
    danger: ChompdColorsLight.red,
    dangerSoft: ChompdColorsLight.dangerSoft,
    info: ChompdColorsLight.blue,
    infoSoft: ChompdColorsLight.infoSoft,
    proTag: ChompdColorsLight.proTag,
    proTagBg: ChompdColorsLight.proTagBg,
    pink: ChompdColorsLight.pink,
    divider: ChompdColorsLight.divider,
    toggleOn: ChompdColorsLight.toggleOn,
    toggleOff: ChompdColorsLight.toggleOff,
    ringTrack: ChompdColorsLight.ringTrack,
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EFFECTS — Glows, gradients, shadows
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ChompdEffects {
  ChompdEffects._();

  /// Card shadow — subtle accent-tinted elevation.
  static List<BoxShadow> cardShadow(bool isDark, Color accent) {
    return isDark
        ? [BoxShadow(color: accent.withValues(alpha: 0.06), blurRadius: 20)]
        : [BoxShadow(color: accent.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))];
  }

  /// Ring glow — dual shadow for the spending ring arc.
  static List<Shadow> ringGlow(bool isDark, Color accent) {
    return isDark
        ? [
            Shadow(color: accent.withValues(alpha: 0.5), blurRadius: 8),
            Shadow(color: accent.withValues(alpha: 0.2), blurRadius: 20),
          ]
        : [
            Shadow(color: accent.withValues(alpha: 0.3), blurRadius: 6),
            Shadow(color: accent.withValues(alpha: 0.1), blurRadius: 14),
          ];
  }

  /// Ring gradient — accent → blue-teal sweep.
  static LinearGradient ringGradient(bool isDark) {
    return isDark
        ? const LinearGradient(colors: [Color(0xFF4ECCA3), Color(0xFF3DBEE0)])
        : const LinearGradient(colors: [Color(0xFF1B8F6A), Color(0xFF2D7BC4)]);
  }

  /// Yearly burn card gradient — 3-stop moody gradient.
  static LinearGradient burnCardGradient(bool isDark) {
    return isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2422), Color(0xFF1E2838), Color(0xFF2A1F3A)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF0FAF5), Color(0xFFF5F0FA)],
          );
  }

  /// Burn card shimmer — purple radial in top-right corner.
  static RadialGradient burnCardShimmer(bool isDark) {
    return isDark
        ? RadialGradient(
            center: Alignment.topRight,
            radius: 0.8,
            colors: [const Color(0xFF9B7FE6).withValues(alpha: 0.08), Colors.transparent],
          )
        : RadialGradient(
            center: Alignment.topRight,
            radius: 0.8,
            colors: [const Color(0xFF7B5FC4).withValues(alpha: 0.05), Colors.transparent],
          );
  }

  /// Ambient top glow — radial gradient behind header.
  static BoxDecoration ambientTopGlow(bool isDark, Color accent) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topCenter,
        radius: 0.8,
        colors: [
          accent.withValues(alpha: isDark ? 0.06 : 0.04),
          Colors.transparent,
        ],
      ),
    );
  }

  /// Category bar segment glow — dark only for non-accent segments.
  static List<BoxShadow>? categoryBarGlow(bool isDark, Color segmentColor, {bool isAccent = false}) {
    if (isDark) {
      return [BoxShadow(color: segmentColor.withValues(alpha: 0.3), blurRadius: 8)];
    }
    if (isAccent) {
      return [BoxShadow(color: segmentColor.withValues(alpha: 0.2), blurRadius: 4)];
    }
    return null;
  }

  /// Burn card border — accent at 15% opacity.
  static Border burnCardBorder(bool isDark) {
    return isDark
        ? Border.all(color: const Color(0xFF4ECCA3).withValues(alpha: 0.15))
        : Border.all(color: const Color(0xFF1B8F6A).withValues(alpha: 0.15));
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CATEGORY COLOURS & ICONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Category brand colours (aligned with Supabase service_category enum).
class CategoryColors {
  CategoryColors._();

  static const Map<String, Color> map = {
    'streaming': Color(0xFFE50914),      // Netflix red
    'music': Color(0xFF1DB954),          // Spotify green
    'ai': Color(0xFF8B5CF6),             // Violet
    'productivity': Color(0xFF00A4EF),   // Light blue
    'storage': Color(0xFF4285F4),        // Google blue
    'fitness': Color(0xFFFC6719),        // Orange
    'gaming': Color(0xFF107C10),         // Xbox green
    'reading': Color(0xFFE8B341),        // Amber
    'communication': Color(0xFFA259FF),  // Purple
    'news': Color(0xFF1DA1F2),           // Twitter blue
    'finance': Color(0xFF00C853),        // Money green
    'education': Color(0xFFFF6D00),      // Deep orange
    'vpn': Color(0xFF2962FF),            // Bold blue
    'developer': Color(0xFF78909C),      // Blue grey
    'bundle': Color(0xFF6D4C41),         // Brown
  };

  static Color forCategory(String category) {
    return map[category] ?? ChompdColors.textDim;
  }
}

/// Category icons (aligned with Supabase service_category enum).
class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> map = {
    'streaming': Icons.movie_outlined,
    'music': Icons.music_note_outlined,
    'ai': Icons.auto_awesome_outlined,
    'productivity': Icons.work_outline,
    'storage': Icons.cloud_outlined,
    'fitness': Icons.fitness_center_outlined,
    'gaming': Icons.sports_esports_outlined,
    'reading': Icons.auto_stories_outlined,
    'communication': Icons.chat_outlined,
    'news': Icons.newspaper_outlined,
    'finance': Icons.account_balance_outlined,
    'education': Icons.school_outlined,
    'vpn': Icons.vpn_key_outlined,
    'developer': Icons.code_outlined,
    'bundle': Icons.inventory_2_outlined,
  };

  static IconData? forCategory(String category) => map[category];
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TYPOGRAPHY
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Typography scale: 10 / 12 / 14 / 16 / 20 / 28
class ChompdTypography {
  ChompdTypography._();

  // Space Mono via Google Fonts — for prices, dates, counters, labels
  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // Section header labels (e.g. "ACTIVE SUBSCRIPTIONS")
  // NOTE: Hardcoded colour — callers should override with context.colors
  static TextStyle sectionLabel = GoogleFonts.spaceMono(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: ChompdColors.textDim,
    letterSpacing: 1.5,
  );

  // Price display (large)
  // NOTE: Hardcoded colour — callers should override with context.colors
  static TextStyle priceHero = GoogleFonts.spaceMono(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: ChompdColors.text,
    letterSpacing: -0.5,
  );

  // Price in cards
  // NOTE: Hardcoded colour — callers should override with context.colors
  static TextStyle priceCard = GoogleFonts.spaceMono(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: ChompdColors.text,
  );

  // Cycle label (/mo, /yr)
  // NOTE: Hardcoded colour — callers should override with context.colors
  static TextStyle cycleLabel = const TextStyle(
    fontSize: 9.5,
    color: ChompdColors.textDim,
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// THEME DATA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// The complete themes for Chompd.
class ChompdTheme {
  ChompdTheme._();

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: ChompdColorsLight.bg,
      colorScheme: const ColorScheme.light(
        surface: ChompdColorsLight.bg,
        primary: ChompdColorsLight.mint,
        secondary: ChompdColorsLight.mint,
        error: ChompdColorsLight.red,
        onSurface: ChompdColorsLight.text,
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ChompdColorsLight.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ChompdColorsLight.text,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: ChompdColorsLight.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: ChompdColorsLight.cardBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ChompdColorsLight.divider,
        thickness: 1,
        space: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: ChompdColorsLight.text,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ChompdColorsLight.text,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ChompdColorsLight.text,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ChompdColorsLight.text,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ChompdColorsLight.text,
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: ChompdColorsLight.textMid,
        ),
        bodySmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: ChompdColorsLight.textDim,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: ChompdColorsLight.textDim,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ChompdColorsLight.mint,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ChompdColorsLight.textMid,
          side: const BorderSide(color: ChompdColorsLight.cardBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: ChompdColorsLight.textMid,
        size: 20,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ChompdColors.bg,
      colorScheme: const ColorScheme.dark(
        surface: ChompdColors.bg,
        primary: ChompdColors.mint,
        secondary: ChompdColors.mint,
        error: ChompdColors.red,
        onSurface: ChompdColors.text,
        onPrimary: ChompdColors.bg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ChompdColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ChompdColors.text,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: ChompdColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: ChompdColors.cardBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ChompdColors.divider,
        thickness: 1,
        space: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: ChompdColors.text,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ChompdColors.text,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ChompdColors.text,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ChompdColors.text,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ChompdColors.text,
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: ChompdColors.textMid,
        ),
        bodySmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: ChompdColors.textDim,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: ChompdColors.textDim,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ChompdColors.mint,
          foregroundColor: ChompdColors.bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ChompdColors.textMid,
          side: const BorderSide(color: ChompdColors.cardBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: ChompdColors.textMid,
        size: 20,
      ),
    );
  }
}
