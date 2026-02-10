import '../models/cancel_guide.dart';

/// Pre-loaded cancel guides for the most common services.
///
/// Shipped with the app — updatable via app updates later.
/// ~30 guides covering App Store, Google Play, and major services.
final List<CancelGuide> cancelGuidesData = [
  // === App Store Subscriptions (iOS) ===
  CancelGuide(
    id: 1,
    serviceName: 'app_store_generic',
    platform: 'ios',
    steps: [
      'Open the Settings app on your iPhone',
      'Tap your name at the top',
      'Tap "Subscriptions"',
      'Find the subscription you want to cancel',
      'Tap "Cancel Subscription"',
      'Confirm cancellation',
    ],
    deepLink: 'https://apps.apple.com/account/subscriptions',
    notes:
        'You keep access until the end of your current billing period.',
    difficultyRating: 1,
  ),

  // === Google Play Subscriptions (Android) ===
  CancelGuide(
    id: 2,
    serviceName: 'google_play_generic',
    platform: 'android',
    steps: [
      'Open the Google Play Store app',
      'Tap your profile icon (top right)',
      'Tap "Payments & subscriptions"',
      'Tap "Subscriptions"',
      'Select the subscription to cancel',
      'Tap "Cancel subscription"',
      'Follow the prompts to confirm',
    ],
    cancellationUrl:
        'https://play.google.com/store/account/subscriptions',
    notes: 'Access continues until end of current billing period.',
    difficultyRating: 1,
  ),

  // === Major Services ===
  CancelGuide(
    id: 3,
    serviceName: 'netflix',
    platform: 'all',
    steps: [
      'Go to netflix.com and sign in',
      'Click your profile icon \u2192 "Account"',
      'Click "Cancel Membership"',
      'Confirm cancellation',
    ],
    cancellationUrl: 'https://www.netflix.com/cancelplan',
    notes:
        'You can watch until the end of your billing period. Netflix saves your profile for 10 months.',
    difficultyRating: 1,
  ),

  CancelGuide(
    id: 4,
    serviceName: 'spotify',
    platform: 'all',
    steps: [
      'Go to spotify.com/account',
      'Click "Your plan"',
      'Click "Cancel Premium" (or "Cancel plan")',
      'Confirm \u2014 you\'ll keep Premium until end of billing period',
    ],
    cancellationUrl:
        'https://www.spotify.com/account/subscription/',
    notes:
        'Cannot cancel via the app \u2014 must use website. You revert to Free tier with ads.',
    difficultyRating: 2,
  ),

  CancelGuide(
    id: 5,
    serviceName: 'amazon_prime',
    platform: 'all',
    steps: [
      'Go to amazon.co.uk/prime',
      'Click "Manage Membership"',
      'Click "Update, cancel and more"',
      'Click "End membership"',
      'Confirm through several "are you sure" screens',
    ],
    cancellationUrl:
        'https://www.amazon.co.uk/mc/pipelines/cancel',
    notes:
        'Amazon shows several retention offers \u2014 keep clicking through to actually cancel. Can get partial refund if unused.',
    difficultyRating: 4,
  ),

  CancelGuide(
    id: 6,
    serviceName: 'adobe_creative_cloud',
    platform: 'all',
    steps: [
      'Go to account.adobe.com/plans',
      'Click "Manage plan" next to your subscription',
      'Click "Cancel plan"',
      'Choose a reason',
      'Review early termination fee (if on annual plan)',
      'Confirm cancellation',
    ],
    cancellationUrl: 'https://account.adobe.com/plans',
    notes:
        'Annual plans charged monthly have an early termination fee (50% of remaining months). Switch to month-to-month first if possible.',
    difficultyRating: 5,
  ),

  CancelGuide(
    id: 7,
    serviceName: 'apple_one',
    platform: 'ios',
    steps: [
      'Open Settings on your iPhone',
      'Tap your name \u2192 "Subscriptions"',
      'Tap "Apple One"',
      'Tap "Cancel All Services" or "Cancel Individual Services"',
      'Confirm',
    ],
    deepLink: 'https://apps.apple.com/account/subscriptions',
    difficultyRating: 1,
  ),

  CancelGuide(
    id: 8,
    serviceName: 'youtube_premium',
    platform: 'all',
    steps: [
      'Go to youtube.com/paid_memberships',
      'Click "Manage membership"',
      'Click "Deactivate"',
      'Confirm cancellation',
    ],
    cancellationUrl:
        'https://www.youtube.com/paid_memberships',
    notes:
        'If subscribed through iOS, cancel via Settings \u2192 Subscriptions instead.',
    difficultyRating: 2,
  ),

  CancelGuide(
    id: 9,
    serviceName: 'disney_plus',
    platform: 'all',
    steps: [
      'Open Disney+ app or go to disneyplus.com',
      'Go to your Profile \u2192 Account',
      'Select your subscription',
      'Click "Cancel Subscription"',
      'Confirm',
    ],
    cancellationUrl: 'https://www.disneyplus.com/account',
    difficultyRating: 2,
  ),

  CancelGuide(
    id: 10,
    serviceName: 'chatgpt_plus',
    platform: 'all',
    steps: [
      'Go to chat.openai.com',
      'Click your profile (bottom left)',
      'Click "My Plan"',
      'Click "Manage my subscription"',
      'Click "Cancel plan"',
    ],
    notes:
        'If subscribed through iOS App Store, cancel via Settings \u2192 Subscriptions.',
    difficultyRating: 2,
  ),

  CancelGuide(
    id: 11,
    serviceName: 'xbox_game_pass',
    platform: 'all',
    steps: [
      'Go to account.microsoft.com/services',
      'Find your Game Pass subscription',
      'Click "Manage"',
      'Click "Cancel subscription"',
      'Follow the prompts (Microsoft shows several retention screens)',
    ],
    cancellationUrl:
        'https://account.microsoft.com/services',
    notes:
        'Microsoft makes you click through 3\u20134 retention screens. Keep going.',
    difficultyRating: 4,
  ),

  CancelGuide(
    id: 12,
    serviceName: 'gym',
    platform: 'all',
    steps: [
      'Check your contract for the cancellation policy and notice period',
      'Most UK gyms require written notice (email or letter)',
      'Send cancellation email to the gym\'s membership team',
      'Request written confirmation of cancellation',
      'Note: many gyms require 30 days notice \u2014 you may owe one more payment',
    ],
    notes:
        'Gym cancellation policies vary wildly. Check your contract for notice period and any cancellation fees.',
    difficultyRating: 4,
  ),

  CancelGuide(
    id: 13,
    serviceName: 'apple_music',
    platform: 'ios',
    steps: [
      'Open Settings on your iPhone',
      'Tap your name \u2192 "Subscriptions"',
      'Tap "Apple Music"',
      'Tap "Cancel Subscription"',
      'Confirm',
    ],
    deepLink: 'https://apps.apple.com/account/subscriptions',
    difficultyRating: 1,
  ),

  CancelGuide(
    id: 14,
    serviceName: 'amazon_music',
    platform: 'all',
    steps: [
      'Go to amazon.co.uk/music/settings',
      'Find "Amazon Music Unlimited"',
      'Click "Cancel subscription"',
      'Confirm through the retention screens',
    ],
    cancellationUrl: 'https://www.amazon.co.uk/music/settings',
    difficultyRating: 3,
  ),

  CancelGuide(
    id: 15,
    serviceName: 'icloud',
    platform: 'ios',
    steps: [
      'Open Settings on your iPhone',
      'Tap your name \u2192 "iCloud"',
      'Tap "Manage Account Storage" or "Manage Storage"',
      'Tap "Change Storage Plan"',
      'Tap "Downgrade Options"',
      'Select "Free 5GB" and confirm',
    ],
    deepLink: 'https://apps.apple.com/account/subscriptions',
    notes:
        'You\'ll need to reduce your iCloud usage below 5GB or your data may be deleted after 30 days.',
    difficultyRating: 2,
  ),

  CancelGuide(
    id: 16,
    serviceName: 'now_tv',
    platform: 'all',
    steps: [
      'Go to account.nowtv.com',
      'Click "Passes & Vouchers"',
      'Select the pass you want to cancel',
      'Click "Cancel Pass"',
      'Confirm',
    ],
    cancellationUrl: 'https://account.nowtv.com',
    difficultyRating: 2,
  ),

  CancelGuide(
    id: 17,
    serviceName: 'audible',
    platform: 'all',
    steps: [
      'Go to audible.co.uk/account',
      'Click "Cancel membership" (at the bottom)',
      'Select a reason',
      'Review any retention offers',
      'Confirm cancellation',
    ],
    cancellationUrl: 'https://www.audible.co.uk/account',
    notes:
        'Audible may offer a discounted rate or free month to retain you. You keep unused credits.',
    difficultyRating: 3,
  ),

  CancelGuide(
    id: 18,
    serviceName: 'linkedin_premium',
    platform: 'all',
    steps: [
      'Go to linkedin.com/mypreferences/d/manage-premium',
      'Click "Cancel subscription"',
      'Follow the prompts',
      'Confirm cancellation',
    ],
    cancellationUrl:
        'https://www.linkedin.com/mypreferences/d/manage-premium',
    notes: 'Premium features remain until end of billing period.',
    difficultyRating: 2,
  ),

  CancelGuide(
    id: 19,
    serviceName: 'paramount_plus',
    platform: 'all',
    steps: [
      'Go to paramountplus.com/account',
      'Click "Cancel subscription"',
      'Confirm cancellation',
    ],
    cancellationUrl: 'https://www.paramountplus.com/account/',
    difficultyRating: 1,
  ),

  CancelGuide(
    id: 20,
    serviceName: 'crunchyroll',
    platform: 'all',
    steps: [
      'Go to crunchyroll.com/account',
      'Click "Subscription & Billing"',
      'Click "Cancel subscription"',
      'Confirm',
    ],
    cancellationUrl: 'https://www.crunchyroll.com/account',
    difficultyRating: 2,
  ),
];

/// Finds the best cancel guide for a given subscription name.
///
/// Tries direct match, partial match, then falls back to generic
/// platform guide.
CancelGuide? findGuideForSubscription(String name, {bool isIOS = true}) {
  final normalised = name.toLowerCase().trim();

  // Direct match
  final direct = cancelGuidesData.where(
    (g) => g.serviceName == normalised.replaceAll(' ', '_'),
  );
  if (direct.isNotEmpty) return direct.first;

  // Partial match
  final partial = cancelGuidesData.where(
    (g) =>
        normalised.contains(g.serviceName.replaceAll('_', ' ')) ||
        g.serviceName.replaceAll('_', ' ').contains(normalised),
  );
  if (partial.isNotEmpty) return partial.first;

  // Platform fallback
  if (isIOS) {
    return cancelGuidesData.firstWhere(
      (g) => g.serviceName == 'app_store_generic',
    );
  }
  return cancelGuidesData.firstWhere(
    (g) => g.serviceName == 'google_play_generic',
  );
}
