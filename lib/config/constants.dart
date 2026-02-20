import '../l10n/generated/app_localizations.dart';

/// Chompd app-wide constants.
class AppConstants {
  AppConstants._();

  // ─── Free Tier Limits ───
  static const int freeMaxSubscriptions = 3;
  static const int freeMaxScans = 1;

  // ─── AI Configuration ───
  static const String aiModel = 'claude-haiku-4-5-20251001';
  static const String aiModelFallback = 'claude-sonnet-4-5-20250929';
  static const double scanCostEstimate = 0.006; // USD per scan (Haiku 4.5)

  // ─── Animation Durations ───
  static const Duration scanShimmer = Duration(milliseconds: 1800);
  static const Duration checkmarkDraw = Duration(milliseconds: 400);
  static const Duration toastSlideIn = Duration(milliseconds: 500);
  static const Duration toastSlideOut = Duration(milliseconds: 400);
  static const Duration numberRoll = Duration(milliseconds: 600);
  static const Duration trialPulse = Duration(milliseconds: 1500);
  static const Duration cardEntrance = Duration(milliseconds: 150);

  // ─── Pro Pricing ───
  static const double proPrice = 4.99; // GBP, one-time
  static const String proCurrency = 'GBP';

  // ─── Trial ───
  static const int trialDurationDays = 7;
  static const String trialProductId = '7_day_trial';       // Tier 0 non-consumable
  static const String proProductId = 'chompd_pro_lifetime';  // £4.99 non-consumable

  // ─── Reminder Schedule (Pro) ───
  static const List<int> proReminderDays = [7, 3, 1, 0]; // 0 = morning-of
  static const List<int> freeReminderDays = [0]; // morning-of only

  // ─── Categories (aligned with Supabase service_category enum) ───
  static const List<String> categories = [
    'streaming',
    'music',
    'ai',
    'productivity',
    'storage',
    'fitness',
    'gaming',
    'reading',
    'communication',
    'news',
    'finance',
    'education',
    'vpn',
    'developer',
    'bundle',
    'other',
  ];

  // ─── Billing Cycles ───
  static const Map<String, int> cycleDays = {
    'weekly': 7,
    'monthly': 30,
    'quarterly': 90,
    'yearly': 365,
  };

  /// Returns localised category names in the same order as [categories].
  static List<String> localisedCategories(S l) => [
    l.categoryStreaming,
    l.categoryMusic,
    l.categoryAi,
    l.categoryProductivity,
    l.categoryStorage,
    l.categoryFitness,
    l.categoryGaming,
    l.categoryReading,
    l.categoryCommunication,
    l.categoryNews,
    l.categoryFinance,
    l.categoryEducation,
    l.categoryVpn,
    l.categoryDeveloper,
    l.categoryBundle,
    l.categoryOther,
  ];

  /// Maps category enum key to localised label.
  static String localisedCategory(String key, S l) {
    switch (key) {
      case 'streaming': return l.categoryStreaming;
      case 'music': return l.categoryMusic;
      case 'ai': return l.categoryAi;
      case 'productivity': return l.categoryProductivity;
      case 'storage': return l.categoryStorage;
      case 'fitness': return l.categoryFitness;
      case 'gaming': return l.categoryGaming;
      case 'reading': return l.categoryReading;
      case 'communication': return l.categoryCommunication;
      case 'news': return l.categoryNews;
      case 'finance': return l.categoryFinance;
      case 'education': return l.categoryEducation;
      case 'vpn': return l.categoryVpn;
      case 'developer': return l.categoryDeveloper;
      case 'bundle': return l.categoryBundle;
      default: return l.categoryOther;
    }
  }

  /// Migrate legacy category names to Supabase enum values.
  static String migrateCategory(String old) {
    const map = {
      'Entertainment': 'streaming',
      'Design': 'productivity',
      'Health': 'fitness',
    };
    // Known legacy mappings first, then lowercase for anything that
    // already matches (e.g. 'Music' → 'music', 'News' → 'news').
    if (map.containsKey(old)) return map[old]!;
    final lower = old.toLowerCase();
    if (categories.contains(lower)) return lower;
    return 'other';
  }
}
