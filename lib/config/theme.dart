import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Chompd Design System — Dark Theme (v1 ships dark-only)
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

/// The complete dark theme for Chompd.
class ChompdTheme {
  ChompdTheme._();

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
