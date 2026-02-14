import '../models/cancel_guide_v2.dart';

/// Generic cancel guides for unmatched services.
///
/// When a subscription isn't in our Supabase service database, these
/// platform-based guides provide helpful general cancellation steps.
/// Same format as service-specific guides so the UI renders identically.

const List<CancelGuideData> genericCancelGuides = [
  // ─── iOS (App Store subscriptions) ───
  CancelGuideData(
    platform: 'ios',
    steps: [
      CancelGuideStep(
        step: 1,
        title: 'Open Settings',
        detail: 'Open the Settings app on your iPhone or iPad.',
      ),
      CancelGuideStep(
        step: 2,
        title: 'Tap your name',
        detail: 'Tap your name (Apple ID) at the very top of Settings.',
      ),
      CancelGuideStep(
        step: 3,
        title: 'Tap "Subscriptions"',
        detail: 'You\'ll see a list of all your active and expired subscriptions.',
      ),
      CancelGuideStep(
        step: 4,
        title: 'Find the subscription',
        detail: 'Scroll through the list and tap the subscription you want to cancel.',
      ),
      CancelGuideStep(
        step: 5,
        title: 'Tap "Cancel Subscription"',
        detail: 'Scroll down and tap the cancel option. It may say "Cancel Subscription" or "Cancel Free Trial".',
      ),
      CancelGuideStep(
        step: 6,
        title: 'Confirm cancellation',
        detail: 'Tap "Confirm" to finalise. You\'ll keep access until the end of your current billing period.',
      ),
    ],
    cancelDeeplink: 'itms-apps://apps.apple.com/account/subscriptions',
    proTip: 'You keep access until the end of your current billing period. Cancelling early won\'t give you a partial refund.',
  ),

  // ─── Android (Google Play subscriptions) ───
  CancelGuideData(
    platform: 'android',
    steps: [
      CancelGuideStep(
        step: 1,
        title: 'Open Google Play Store',
        detail: 'Open the Play Store app on your Android device.',
      ),
      CancelGuideStep(
        step: 2,
        title: 'Tap your profile icon',
        detail: 'Tap your profile picture or initial in the top right corner.',
      ),
      CancelGuideStep(
        step: 3,
        title: 'Tap "Payments & subscriptions"',
        detail: 'Select "Payments & subscriptions" from the menu.',
      ),
      CancelGuideStep(
        step: 4,
        title: 'Tap "Subscriptions"',
        detail: 'You\'ll see all your active Google Play subscriptions.',
      ),
      CancelGuideStep(
        step: 5,
        title: 'Find the subscription',
        detail: 'Tap the subscription you want to cancel.',
      ),
      CancelGuideStep(
        step: 6,
        title: 'Tap "Cancel subscription"',
        detail: 'Tap the cancel button at the bottom.',
      ),
      CancelGuideStep(
        step: 7,
        title: 'Follow the prompts',
        detail: 'Google may offer a discount to keep you. Decide if it\'s worth it, then confirm cancellation.',
      ),
    ],
    cancelDeeplink: 'https://play.google.com/store/account/subscriptions',
    proTip: 'Google may offer a discounted rate to keep you \u2014 check if it\'s worth it before confirming.',
  ),

  // ─── Web (billed directly by the service) ───
  CancelGuideData(
    platform: 'web',
    steps: [
      CancelGuideStep(
        step: 1,
        title: 'Log in to the service\'s website',
        detail: 'Go to the service\'s website and sign in to your account.',
      ),
      CancelGuideStep(
        step: 2,
        title: 'Go to Account Settings or Billing',
        detail: 'Look for "Account", "Settings", "Billing", or "Subscription" in the menu.',
      ),
      CancelGuideStep(
        step: 3,
        title: 'Find the subscription or plan section',
        detail: 'Look for "Subscription", "Membership", "Plan", or "Billing".',
      ),
      CancelGuideStep(
        step: 4,
        title: 'Find the cancel option',
        detail: 'It might be labelled "Cancel", "Downgrade", "End subscription", or similar.',
      ),
      CancelGuideStep(
        step: 5,
        title: 'Follow the cancellation steps',
        detail: 'Some services show retention offers or surveys. Complete them to finish cancelling.',
      ),
      CancelGuideStep(
        step: 6,
        title: 'Save your confirmation',
        detail: 'Screenshot or save the cancellation confirmation page and check your email for a confirmation.',
      ),
    ],
    warningText: 'Some services bury the cancel option. Try searching their help centre for "cancel" if you can\'t find it.',
    proTip: 'Check your email for a cancellation confirmation. If you don\'t get one within 24 hours, contact support directly.',
  ),

  // ─── Bank/Card (last resort) ───
  CancelGuideData(
    platform: 'bank',
    steps: [
      CancelGuideStep(
        step: 1,
        title: 'Check your bank statement',
        detail: 'Identify the exact merchant name from your bank or card statement.',
      ),
      CancelGuideStep(
        step: 2,
        title: 'Search for cancellation instructions',
        detail: 'Search "[merchant name] cancel subscription" in your browser.',
      ),
      CancelGuideStep(
        step: 3,
        title: 'Log in and find billing settings',
        detail: 'Log in to the service and look for account or billing settings.',
      ),
      CancelGuideStep(
        step: 4,
        title: 'Contact support if needed',
        detail: 'If you can\'t find a cancel option, email their support team requesting cancellation.',
      ),
      CancelGuideStep(
        step: 5,
        title: 'Block charges as a last resort',
        detail: 'If all else fails, contact your bank to block future charges from this merchant.',
      ),
    ],
    warningText: 'Blocking charges through your bank should be a last resort \u2014 some services may send your account to collections.',
  ),
];

/// Find the appropriate generic cancel guide for the current platform.
CancelGuideData? findGenericCancelGuide({bool isIOS = true}) {
  final platform = isIOS ? 'ios' : 'android';
  return genericCancelGuides
      .where((g) => g.platform == platform)
      .firstOrNull;
}

/// Get all generic cancel guides (for showing platform tabs).
List<CancelGuideData> get allGenericCancelGuides => genericCancelGuides;
