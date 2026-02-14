import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Chompd Design System — Dark & Light Themes
///
/// Colour tokens from the visual design prototype.
/// Typography: System default for UI, Space Mono for data/prices.
class ChompdColors {
  ChompdColors._();

  // ─── Backgrounds (warm olive-black) ───
  static const bg = Color(0xFF080808);
  static const bgCard = Color(0xFF141412);
  static const bgElevated = Color(0xFF1C1C19);
  static const bgGlass = Color(0xD91C1C19); // 85% opacity

  // ─── Borders ───
  static const border = Color(0xFF262622);
  static const borderLight = Color(0xFF333330);
  static const borderHighlight = Color(0xFF2E2E2A); // Top-edge highlight

  // ─── Text ───
  static const text = Color(0xFFF0F0EC);
  static const textMid = Color(0xFFA0A098);
  static const textDim = Color(0xFF6A6A64);

  // ─── Accent: Mint (primary) ───
  static const mint = Color(0xFF6EE7B7);
  static const mintDark = Color(0xFF34D399);
  static const mintGlow = Color(0x266EE7B7); // 15% opacity

  // ─── Semantic Colours ───
  static const amber = Color(0xFFFBBF24);
  static const amberGlow = Color(0x1FFBBF24); // 12% opacity
  static const red = Color(0xFFF87171);
  static const redGlow = Color(0x1FF87171); // 12% opacity
  static const purple = Color(0xFFA78BFA);
  static const blue = Color(0xFF60A5FA);
  static const pink = Color(0xFFF472B6);
}

/// Light theme colour tokens.
class ChompdColorsLight {
  ChompdColorsLight._();

  // ─── Backgrounds ───
  static const bg = Color(0xFFF5F5F7);
  static const bgCard = Color(0xFFFFFFFF);
  static const bgElevated = Color(0xFFEFEFF1);
  static const bgGlass = Color(0xD9EFEFF1);

  // ─── Borders ───
  static const border = Color(0xFFDCDCE2);
  static const borderLight = Color(0xFFD0D0D8);
  static const borderHighlight = Color(0xFFE8E8EE);

  // ─── Text ───
  static const text = Color(0xFF1A1A24);
  static const textMid = Color(0xFF5A5A6E);
  static const textDim = Color(0xFF9090A4);

  // ─── Accent: Mint (slightly darker for light bg contrast) ───
  static const mint = Color(0xFF10B981);
  static const mintDark = Color(0xFF059669);
  static const mintGlow = Color(0x2610B981);

  // ─── Semantic Colours (slightly darker for light bg) ───
  static const amber = Color(0xFFD97706);
  static const amberGlow = Color(0x1FD97706);
  static const red = Color(0xFFDC2626);
  static const redGlow = Color(0x1FDC2626);
  static const purple = Color(0xFF7C3AED);
  static const blue = Color(0xFF2563EB);
  static const pink = Color(0xFFEC4899);
}

/// Extension to get the correct colour tokens based on brightness.
///
/// Usage: `context.colors.bg`, `context.colors.text`, etc.
extension ChompdColorScheme on BuildContext {
  _ChompdColorSet get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? _ChompdColorSet.dark : _ChompdColorSet.light;
  }
}

class _ChompdColorSet {
  final Color bg;
  final Color bgCard;
  final Color bgElevated;
  final Color bgGlass;
  final Color border;
  final Color borderLight;
  final Color borderHighlight;
  final Color text;
  final Color textMid;
  final Color textDim;
  final Color mint;
  final Color mintDark;
  final Color mintGlow;
  final Color amber;
  final Color amberGlow;
  final Color red;
  final Color redGlow;
  final Color purple;
  final Color blue;
  final Color pink;

  const _ChompdColorSet({
    required this.bg,
    required this.bgCard,
    required this.bgElevated,
    required this.bgGlass,
    required this.border,
    required this.borderLight,
    required this.borderHighlight,
    required this.text,
    required this.textMid,
    required this.textDim,
    required this.mint,
    required this.mintDark,
    required this.mintGlow,
    required this.amber,
    required this.amberGlow,
    required this.red,
    required this.redGlow,
    required this.purple,
    required this.blue,
    required this.pink,
  });

  static const dark = _ChompdColorSet(
    bg: ChompdColors.bg,
    bgCard: ChompdColors.bgCard,
    bgElevated: ChompdColors.bgElevated,
    bgGlass: ChompdColors.bgGlass,
    border: ChompdColors.border,
    borderLight: ChompdColors.borderLight,
    borderHighlight: ChompdColors.borderHighlight,
    text: ChompdColors.text,
    textMid: ChompdColors.textMid,
    textDim: ChompdColors.textDim,
    mint: ChompdColors.mint,
    mintDark: ChompdColors.mintDark,
    mintGlow: ChompdColors.mintGlow,
    amber: ChompdColors.amber,
    amberGlow: ChompdColors.amberGlow,
    red: ChompdColors.red,
    redGlow: ChompdColors.redGlow,
    purple: ChompdColors.purple,
    blue: ChompdColors.blue,
    pink: ChompdColors.pink,
  );

  static const light = _ChompdColorSet(
    bg: ChompdColorsLight.bg,
    bgCard: ChompdColorsLight.bgCard,
    bgElevated: ChompdColorsLight.bgElevated,
    bgGlass: ChompdColorsLight.bgGlass,
    border: ChompdColorsLight.border,
    borderLight: ChompdColorsLight.borderLight,
    borderHighlight: ChompdColorsLight.borderHighlight,
    text: ChompdColorsLight.text,
    textMid: ChompdColorsLight.textMid,
    textDim: ChompdColorsLight.textDim,
    mint: ChompdColorsLight.mint,
    mintDark: ChompdColorsLight.mintDark,
    mintGlow: ChompdColorsLight.mintGlow,
    amber: ChompdColorsLight.amber,
    amberGlow: ChompdColorsLight.amberGlow,
    red: ChompdColorsLight.red,
    redGlow: ChompdColorsLight.redGlow,
    purple: ChompdColorsLight.purple,
    blue: ChompdColorsLight.blue,
    pink: ChompdColorsLight.pink,
  );
}

/// Category brand colours for the spending breakdown bar.
class CategoryColors {
  CategoryColors._();

  static const Map<String, Color> map = {
    'Entertainment': Color(0xFFE50914),
    'Music': Color(0xFF1DB954),
    'Design': Color(0xFFA259FF),
    'Fitness': Color(0xFFFC6719),
    'Productivity': Color(0xFF00A4EF),
    'Storage': Color(0xFF4285F4),
    'News': Color(0xFF1DA1F2),
    'Gaming': Color(0xFF107C10),
  };

  static Color forCategory(String category) {
    return map[category] ?? ChompdColors.textDim;
  }
}

/// Category icons for when AI hasn't set a brand icon.
class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> map = {
    'Entertainment': Icons.movie_outlined,
    'Music': Icons.music_note_outlined,
    'Design': Icons.palette_outlined,
    'Fitness': Icons.fitness_center_outlined,
    'Productivity': Icons.work_outline,
    'Storage': Icons.cloud_outlined,
    'News': Icons.newspaper_outlined,
    'Gaming': Icons.sports_esports_outlined,
    'Finance': Icons.account_balance_outlined,
    'Education': Icons.school_outlined,
    'Health': Icons.favorite_outline,
  };

  static IconData? forCategory(String category) => map[category];
}

/// Typography scale: 10 / 12 / 14 / 16 / 20 / 28
class ChompdTypography {
  ChompdTypography._();

  // Space Mono via Google Fonts — for prices, dates, counters, labels
  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = ChompdColors.text,
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
  static TextStyle sectionLabel = GoogleFonts.spaceMono(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: ChompdColors.textDim,
    letterSpacing: 1.5,
  );

  // Price display (large)
  static TextStyle priceHero = GoogleFonts.spaceMono(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: ChompdColors.text,
    letterSpacing: -0.5,
  );

  // Price in cards
  static TextStyle priceCard = GoogleFonts.spaceMono(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: ChompdColors.text,
  );

  // Cycle label (/mo, /yr)
  static TextStyle cycleLabel = const TextStyle(
    fontSize: 9.5,
    color: ChompdColors.textDim,
  );
}

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
        secondary: ChompdColorsLight.mintDark,
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
        color: ChompdColorsLight.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: ChompdColorsLight.border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ChompdColorsLight.border,
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
          side: const BorderSide(color: ChompdColorsLight.border),
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
        secondary: ChompdColors.mintDark,
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
        color: ChompdColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: ChompdColors.border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ChompdColors.border,
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
          side: const BorderSide(color: ChompdColors.border),
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
