/// Chompd app-wide constants.
class AppConstants {
  AppConstants._();

  // ─── Free Tier Limits ───
  static const int freeMaxSubscriptions = 3;
  static const int freeMaxScans = 3;

  // ─── AI Configuration ───
  static const String aiModel = 'claude-haiku-4-5-20251001';
  static const String aiModelFallback = 'claude-sonnet-4-5-20250929';
  static const double scanCostEstimate = 0.0015; // USD per scan

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

  // ─── Reminder Schedule (Pro) ───
  static const List<int> proReminderDays = [7, 3, 1, 0]; // 0 = morning-of
  static const List<int> freeReminderDays = [0]; // morning-of only

  // ─── Categories ───
  static const List<String> categories = [
    'Entertainment',
    'Music',
    'Design',
    'Fitness',
    'Productivity',
    'Storage',
    'News',
    'Gaming',
    'Finance',
    'Education',
    'Health',
    'Other',
  ];

  // ─── Billing Cycles ───
  static const Map<String, int> cycleDays = {
    'weekly': 7,
    'monthly': 30,
    'quarterly': 90,
    'yearly': 365,
  };
}
