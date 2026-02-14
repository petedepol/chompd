// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Chompd';

  @override
  String get tagline => 'Scan. Track. Bite back.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get done => 'Done';

  @override
  String get keep => 'Keep';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get share => 'Share';

  @override
  String get confirm => 'Confirm';

  @override
  String get other => 'Other';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get pro => 'Pro';

  @override
  String get free => 'Free';

  @override
  String get onboardingTitle1 => 'Bite Back at Subscriptions';

  @override
  String get onboardingSubtitle1 =>
      'Chompd tracks every subscription, catches hidden traps, and helps you cancel what you don’t need.';

  @override
  String onboardingStatWaste(String amount) {
    return 'The average person wastes $amount/year on forgotten subscriptions';
  }

  @override
  String get onboardingStep1Title => 'Snap a screenshot';

  @override
  String get onboardingStep1Subtitle => 'Receipt, email, or bank statement';

  @override
  String get onboardingStep2Title => 'AI reads it instantly';

  @override
  String get onboardingStep2Subtitle => 'Price, renewal date, and hidden traps';

  @override
  String get onboardingStep3Title => 'Done. Tracked forever.';

  @override
  String get onboardingStep3Subtitle => 'Get reminders before you’re charged';

  @override
  String get onboardingTitle3 => 'Stay Ahead of Renewals';

  @override
  String get onboardingSubtitle3 =>
      'We’ll remind you before you’re charged — no surprises.';

  @override
  String get onboardingNotifMorning => 'Morning of renewal';

  @override
  String get onboardingNotif7days => '7 days before';

  @override
  String get onboardingNotifTrial => 'Trial expiry alerts';

  @override
  String get allowNotifications => 'Allow Notifications';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get onboardingTitle4 => 'Add Your First Subscription';

  @override
  String get onboardingSubtitle4 =>
      'Most people find forgotten subscriptions in their first scan. Let’s see what you’re paying for.';

  @override
  String get scanAScreenshot => 'Scan a Screenshot';

  @override
  String get addManually => 'Add Manually';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String homeStatusLine(int active, int cancelled) {
    return '$active active · $cancelled cancelled';
  }

  @override
  String get overBudgetMood => 'Ouch. That’s a lot of chomping.';

  @override
  String get underBudgetMood => 'Looking good! Well under budget.';

  @override
  String get sectionActiveSubscriptions => 'ACTIVE SUBSCRIPTIONS';

  @override
  String get sectionCancelledSaved => 'CANCELLED — MONEY SAVED';

  @override
  String get sectionMilestones => 'MILESTONES';

  @override
  String get sectionYearlyBurn => 'YEARLY BURN';

  @override
  String get sectionSavedWithChompd => 'SAVED WITH CHOMPD';

  @override
  String perYearAcrossSubs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
    );
    return 'per year across $_temp0';
  }

  @override
  String get monthlyAvg => 'monthly avg';

  @override
  String get dailyCost => 'daily cost';

  @override
  String fromCancelled(int count) {
    return 'from $count cancelled';
  }

  @override
  String get deleteSubscriptionTitle => 'Delete Subscription?';

  @override
  String deleteSubscriptionMessage(String name) {
    return 'Remove $name permanently?';
  }

  @override
  String cancelledMonthsAgo(int months) {
    return 'Cancelled ${months}mo ago';
  }

  @override
  String get justCancelled => 'Just cancelled';

  @override
  String get subsLeft => 'Subs left';

  @override
  String get scansLeft => 'Scans left';

  @override
  String get aiScanScreenshot => 'AI Scan Screenshot';

  @override
  String get aiScanUpgradeToPro => 'AI Scan (Upgrade to Pro)';

  @override
  String get quickAddManual => 'Quick Add / Manual';

  @override
  String get addSubUpgradeToPro => 'Add Sub (Upgrade to Pro)';

  @override
  String trialsExpiringSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trials expiring soon',
      one: '1 trial expiring soon',
    );
    return '$_temp0';
  }

  @override
  String trialDaysLeft(String names, int days) {
    return '$names — $days days left';
  }

  @override
  String get proInfinity => 'PRO ∞';

  @override
  String scansLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scans left',
      one: '1 scan left',
    );
    return '$_temp0';
  }

  @override
  String get scanTitle => 'AI Scan';

  @override
  String get scanAnalysing => 'Analysing your screenshot...';

  @override
  String get scanIdleTitle => 'Scan a Screenshot';

  @override
  String get scanIdleSubtitle =>
      'Share a screenshot of a confirmation email,\nbank statement, or app store receipt.';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get cameraPermError => 'Could not access camera. Check permissions.';

  @override
  String get galleryPermError =>
      'Could not access photo library. Check permissions.';

  @override
  String get smartMove => 'Smart move!';

  @override
  String youSkipped(String service) {
    return 'You skipped $service';
  }

  @override
  String get saved => 'SAVED';

  @override
  String get addedToUnchompd => 'Added to your Unchompd total';

  @override
  String get analysing => 'Analysing...';

  @override
  String get confidence => 'confidence';

  @override
  String get typeYourAnswer => 'Type your answer...';

  @override
  String get addToChompd => 'Add to Chompd';

  @override
  String get monthlyTotal => 'Monthly total';

  @override
  String addAllToChompd(int count) {
    return 'Add all $count to Chompd';
  }

  @override
  String get autoTier => 'AUTO';

  @override
  String yesIts(String option) {
    return 'Yes, it’s $option';
  }

  @override
  String get otherAmount => 'Other amount';

  @override
  String get trapDetected => 'TRAP DETECTED';

  @override
  String trapOfferActually(String name) {
    return 'This \"$name\" offer is actually:';
  }

  @override
  String skipItSave(String amount) {
    return 'SKIP IT — SAVE $amount';
  }

  @override
  String get trackTrialAnyway => 'Track Trial Anyway';

  @override
  String get trapReminder => 'We’ll remind you before it charges';

  @override
  String get editSubscription => 'Edit Subscription';

  @override
  String get addSubscription => 'Add Subscription';

  @override
  String get fieldServiceName => 'SERVICE NAME';

  @override
  String get hintServiceName => 'e.g. Netflix, Spotify';

  @override
  String get errorNameRequired => 'Name required';

  @override
  String get fieldPrice => 'PRICE';

  @override
  String get hintPrice => '9.99';

  @override
  String get errorPriceRequired => 'Price required';

  @override
  String get errorInvalidPrice => 'Invalid price';

  @override
  String get fieldCurrency => 'CURRENCY';

  @override
  String get fieldBillingCycle => 'BILLING CYCLE';

  @override
  String get fieldCategory => 'CATEGORY';

  @override
  String get fieldNextRenewal => 'NEXT RENEWAL';

  @override
  String get selectDate => 'Select date';

  @override
  String get freeTrialToggle => 'This is a free trial';

  @override
  String get trialDurationLabel => 'Trial length';

  @override
  String get trialDays7 => '7 days';

  @override
  String get trialDays14 => '14 days';

  @override
  String get trialDays30 => '30 days';

  @override
  String trialCustomDays(int days) {
    return '${days}d';
  }

  @override
  String get fieldTrialEnds => 'TRIAL ENDS';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get subscriptionDetail => 'Subscription Detail';

  @override
  String thatsPerYear(String amount) {
    return 'That’s $amount per year';
  }

  @override
  String overThreeYears(String amount) {
    return '$amount over 3 years';
  }

  @override
  String trialDaysRemaining(int days) {
    return '⚠️ Trial — $days days remaining';
  }

  @override
  String get trialExpired => '⚠️ Trial expired';

  @override
  String get nextRenewal => 'NEXT RENEWAL';

  @override
  String chargesToday(String price) {
    return '$price charges today';
  }

  @override
  String chargesTomorrow(String price) {
    return '$price charges tomorrow';
  }

  @override
  String chargesSoon(int days, String price) {
    return '$days days — $price soon';
  }

  @override
  String daysCount(int days) {
    return '$days days';
  }

  @override
  String get sectionReminders => 'REMINDERS';

  @override
  String remindersScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reminders scheduled',
      one: '1 reminder scheduled',
    );
    return '$_temp0';
  }

  @override
  String get reminderDaysBefore7 => '7 days before';

  @override
  String get reminderDaysBefore3 => '3 days before';

  @override
  String get reminderDaysBefore1 => '1 day before';

  @override
  String get reminderMorningOf => 'Morning of';

  @override
  String get upgradeForReminders => 'Upgrade to Pro for advance reminders';

  @override
  String get sectionPaymentHistory => 'PAYMENT HISTORY';

  @override
  String get totalPaid => 'Total paid';

  @override
  String noPaymentsYet(String date) {
    return 'No payments yet — started $date';
  }

  @override
  String get sectionDetails => 'DETAILS';

  @override
  String get detailCategory => 'Category';

  @override
  String get detailCurrency => 'Currency';

  @override
  String get detailBillingCycle => 'Billing cycle';

  @override
  String get detailAdded => 'Added';

  @override
  String addedVia(String date, String source) {
    return '$date via $source';
  }

  @override
  String get sourceAiScan => 'AI Scan';

  @override
  String get sourceQuickAdd => 'Quick Add';

  @override
  String get sourceManual => 'Manual';

  @override
  String get cancelSubscription => 'Cancel Subscription';

  @override
  String get requestRefund => 'Request Refund';

  @override
  String deleteNameTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteNameMessage =>
      'This will permanently remove this subscription. This cannot be undone.';

  @override
  String noGuideYet(String name) {
    return 'No specific guide for $name yet. Try searching \"$name cancel subscription\" online.';
  }

  @override
  String realAnnualCost(String amount) {
    return 'Real annual cost: $amount/yr';
  }

  @override
  String trialExpires(String date) {
    return 'Trial expires $date';
  }

  @override
  String get chompdPro => 'Chompd Pro';

  @override
  String get paywallTagline =>
      'A subscription tracker that isn’t a subscription.';

  @override
  String paywallLimitSubs(int count) {
    return 'You’ve hit the free limit of $count subscriptions.';
  }

  @override
  String paywallLimitScans(int count) {
    return 'You’ve used all $count free AI scans.';
  }

  @override
  String get paywallLimitReminders => 'Advance reminders are a Pro feature.';

  @override
  String get paywallGeneric => 'Unlock the full Chompd experience.';

  @override
  String get paywallFeature1 => 'Save £100–£500/year on hidden waste';

  @override
  String get paywallFeature2 => 'Never miss a trial expiry again';

  @override
  String get paywallFeature3 => 'Unlimited AI trap scanning';

  @override
  String get paywallFeature4 => 'Track every subscription you have';

  @override
  String get paywallFeature5 => 'Early warnings: 7d, 3d, 1d before charges';

  @override
  String get paywallFeature6 => 'Shareable savings cards';

  @override
  String get paywallContext =>
      'Pays for itself after cancelling just one forgotten subscription.';

  @override
  String get oneTimePayment => 'One-time payment. Forever.';

  @override
  String get lifetime => 'LIFETIME';

  @override
  String get unlockChompdPro => 'Unlock Chompd Pro';

  @override
  String get restoring => 'Restoring...';

  @override
  String get restorePurchase => 'Restore Purchase';

  @override
  String get purchaseError => 'Purchase could not be completed. Try again.';

  @override
  String get noPreviousPurchase => 'No previous purchase found.';

  @override
  String get renewalCalendar => 'Renewal Calendar';

  @override
  String get today => 'TODAY';

  @override
  String get noRenewalsThisDay => 'No renewals this day';

  @override
  String get thisMonth => 'THIS MONTH';

  @override
  String get renewals => 'Renewals';

  @override
  String get total => 'Total';

  @override
  String renewalsOnDay(int count, String date, String price) {
    return '$count renewals on $date totalling $price';
  }

  @override
  String biggestDay(String date, String price) {
    return 'Biggest day: $date — $price';
  }

  @override
  String get tapDayToSee => 'Tap a day to see what renews';

  @override
  String cancelGuideTitle(String name) {
    return 'Cancel $name';
  }

  @override
  String get whyCancelling => 'Why are you cancelling?';

  @override
  String get whyCancellingHint => 'Quick tap — helps us improve Chompd.';

  @override
  String get reasonTooExpensive => 'Too expensive';

  @override
  String get reasonDontUse => 'Don’t use it enough';

  @override
  String get reasonBreak => 'Taking a break';

  @override
  String get reasonSwitching => 'Switching to something else';

  @override
  String get difficultyLevel => 'Difficulty Level';

  @override
  String get cancellationSteps => 'Cancellation Steps';

  @override
  String stepNumber(int number) {
    return 'STEP $number';
  }

  @override
  String get openCancelPage => 'Open Cancel Page';

  @override
  String get iveCancelled => 'I’ve Cancelled';

  @override
  String get couldntCancelRefund => 'Couldn’t cancel? Get Refund Help →';

  @override
  String get refundTipTitle => 'Tip: Why request a refund?';

  @override
  String get refundTipBody =>
      'If you were charged unexpectedly, signed up by accident, or the service didn’t work as promised — you may be entitled to a refund. The earlier you request, the better your chances.';

  @override
  String get refundRescue => 'Refund Rescue';

  @override
  String get refundIntro =>
      'Don’t worry — most people get their money back. Let’s sort this.';

  @override
  String chargedYou(String name, String price) {
    return '$name charged you $price';
  }

  @override
  String get howCharged => 'HOW WERE YOU CHARGED?';

  @override
  String successRate(String rate) {
    return 'Success: $rate';
  }

  @override
  String get copyDisputeEmail => 'Copy Dispute Email';

  @override
  String get openRefundPage => 'Open Refund Page';

  @override
  String get iveSubmittedRequest => 'I’ve Submitted My Request';

  @override
  String get requestSubmitted => 'Request Submitted!';

  @override
  String get requestSubmittedMessage =>
      'We’ve recorded your refund request. Keep an eye on your email for updates.';

  @override
  String get emailCopied => 'Email copied to clipboard';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeTitle => 'THEME';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get sectionNotifications => 'NOTIFICATIONS';

  @override
  String remindersScheduledSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reminders scheduled',
      one: '1 reminder scheduled',
    );
    return '$_temp0';
  }

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle =>
      'Get reminded about renewals and trials';

  @override
  String get morningDigest => 'Morning Digest';

  @override
  String morningDigestSubtitle(String time) {
    return 'Daily summary at $time';
  }

  @override
  String get renewalReminders => 'Renewal Reminders';

  @override
  String get trialExpiryAlerts => 'Trial Expiry Alerts';

  @override
  String get trialExpirySubtitle => 'Warns at 3 days, 1 day, and day-of';

  @override
  String get sectionReminderSchedule => 'REMINDER SCHEDULE';

  @override
  String get sectionUpcoming => 'UPCOMING';

  @override
  String get noUpcomingNotifications => 'No upcoming notifications';

  @override
  String get sectionChompdPro => 'CHOMPD PRO';

  @override
  String get sectionCurrency => 'CURRENCY';

  @override
  String get displayCurrency => 'Display currency';

  @override
  String get sectionMonthlyBudget => 'MONTHLY BUDGET';

  @override
  String get monthlySpendingTarget => 'Monthly Spending Target';

  @override
  String get budgetHint => 'Used for the spending ring on your dashboard';

  @override
  String get sectionHapticFeedback => 'HAPTIC FEEDBACK';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticSubtitle => 'Vibrations on taps, toggles, and celebrations';

  @override
  String get sectionDataExport => 'DATA EXPORT';

  @override
  String get exportToCsv => 'Export to CSV';

  @override
  String get exportHint => 'Download all your subscriptions as a spreadsheet';

  @override
  String exportSuccess(int count) {
    return 'Exported $count subscriptions to CSV';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get sectionAbout => 'ABOUT';

  @override
  String get version => 'Version';

  @override
  String get tier => 'Tier';

  @override
  String get aiModel => 'AI Model';

  @override
  String get aiModelValue => 'Claude Haiku 4.5';

  @override
  String get setBudgetTitle => 'Set Monthly Budget';

  @override
  String get setBudgetSubtitle =>
      'Enter your target monthly subscription spend.';

  @override
  String get reminderSubtitleMorningOnly =>
      'Morning-of only (upgrade for more)';

  @override
  String reminderSubtitleDays(String schedule) {
    return '$schedule before renewal';
  }

  @override
  String get dayOf => 'day-of';

  @override
  String get oneDay => '1 day';

  @override
  String nDays(int days) {
    return '$days days';
  }

  @override
  String get timelineLabel7d => '7d';

  @override
  String get timelineLabel3d => '3d';

  @override
  String get timelineLabel1d => '1d';

  @override
  String get timelineLabelDayOf => 'Day of';

  @override
  String get upgradeProReminders =>
      'Upgrade to Pro for 7d, 3d, and 1d reminders';

  @override
  String proPrice(String price) {
    return '£$price';
  }

  @override
  String oneTimePaymentShort(String price) {
    return '$price • One-time payment';
  }

  @override
  String get sectionLanguage => 'LANGUAGE';

  @override
  String get severityHigh => 'HIGH RISK';

  @override
  String get severityCaution => 'CAUTION';

  @override
  String get severityInfo => 'INFO';

  @override
  String get trapTypeTrialBait => 'Trial Bait';

  @override
  String get trapTypePriceFraming => 'Price Framing';

  @override
  String get trapTypeHiddenRenewal => 'Hidden Renewal';

  @override
  String get trapTypeCancelFriction => 'Cancel Friction';

  @override
  String get trapTypeGeneric => 'Subscription Trap';

  @override
  String get severityExplainHigh => 'Extreme price jump or deceptive framing';

  @override
  String get severityExplainMedium =>
      'Introductory price increases significantly';

  @override
  String get severityExplainLow => 'Standard trial with auto-renewal';

  @override
  String trialBadge(int days) {
    return '${days}d trial';
  }

  @override
  String get emptyNoSubscriptions => 'No subscriptions yet';

  @override
  String get emptyNoSubscriptionsHint =>
      'Scan a screenshot or tap + to get started.';

  @override
  String get emptyNoTrials => 'No active trials';

  @override
  String get emptyNoTrialsHint =>
      'When you add trial subscriptions,\nthey’ll appear here with countdown alerts.';

  @override
  String get emptyNoSavings => 'No savings yet';

  @override
  String get emptyNoSavingsHint =>
      'Cancel subscriptions you don’t use\nand watch your savings grow here.';

  @override
  String get nudgeReview => 'Review';

  @override
  String get nudgeKeepIt => 'Keep it';

  @override
  String get trialLabel => 'TRIAL';

  @override
  String get priceToday => 'TODAY';

  @override
  String get priceThen => 'THEN';

  @override
  String dayTrial(String days) {
    return '$days-day trial';
  }

  @override
  String realCostFirstYear(String amount) {
    return 'Real cost first year: $amount';
  }

  @override
  String get milestoneCoffeeFund => 'Coffee Fund';

  @override
  String get milestoneGamePass => 'Game Pass';

  @override
  String get milestoneWeekendAway => 'Weekend Away';

  @override
  String get milestoneNewGadget => 'New Gadget';

  @override
  String get milestoneDreamHoliday => 'Dream Holiday';

  @override
  String get milestoneFirstBiteBack => 'First Bite Back';

  @override
  String get milestoneChompSpotter => 'Chomp Spotter';

  @override
  String get milestoneDarkPatternDestroyer => 'Dark Pattern Destroyer';

  @override
  String get milestoneSubscriptionSentinel => 'Subscription Sentinel';

  @override
  String get milestoneUnchompable => 'Unchompable';

  @override
  String get milestoneReached => '✓ Reached!';

  @override
  String milestoneToGo(String amount) {
    return '$amount to go';
  }

  @override
  String get celebrationTitle => 'Nice one! 🎉';

  @override
  String celebrationSavePerYear(String amount) {
    return 'You’ll save $amount/year';
  }

  @override
  String celebrationByDropping(String name) {
    return 'by dropping $name';
  }

  @override
  String get tapAnywhereToContinue => 'tap anywhere to continue';

  @override
  String get trapBadge => 'TRAP';

  @override
  String trapDays(int days) {
    return '${days}d trap';
  }

  @override
  String get unchompd => 'Unchompd';

  @override
  String get fromSubscriptionTraps => 'from subscription traps';

  @override
  String trapsDodged(int count) {
    return '$count dodged';
  }

  @override
  String trialsCancelled(int count) {
    return '$count cancelled';
  }

  @override
  String refundsRecovered(int count) {
    return '$count refunded';
  }

  @override
  String get ringYearly => 'YEARLY';

  @override
  String get ringMonthly => 'MONTHLY';

  @override
  String overBudget(String amount) {
    return '$amount over budget';
  }

  @override
  String ofBudget(String amount) {
    return 'of $amount budget';
  }

  @override
  String get tapForMonthly => 'tap for monthly';

  @override
  String get tapForYearly => 'tap for yearly';

  @override
  String budgetRange(String min, String max) {
    return 'Budget: $min – $max';
  }

  @override
  String get addSubscriptionSheet => 'Add Subscription';

  @override
  String get orChooseService => 'or choose a service';

  @override
  String get searchServices => 'Search services...';

  @override
  String get priceField => 'Price';

  @override
  String addServiceName(String name) {
    return 'Add $name';
  }

  @override
  String get tapForMore => 'tap for more';

  @override
  String shareYearlyBurn(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
    );
    return 'I spend $symbol$amount/year on $_temp0 😳';
  }

  @override
  String shareMonthlyDaily(String symbol, String monthly, String daily) {
    return 'That’s $symbol$monthly/month or $symbol$daily/day';
  }

  @override
  String shareSavedBy(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
    );
    return '✓ Saved $symbol$amount by cancelling $_temp0';
  }

  @override
  String get shareFooter => 'Tracked with Chompd — Scan. Track. Bite back.';

  @override
  String shareSavings(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
    );
    return 'I saved $symbol$amount by cancelling $_temp0 🎉\n\nBite back at subscriptions — getchompd.com';
  }

  @override
  String get insightBigSpenderHeadline => 'Big spender';

  @override
  String insightBigSpenderMessage(String name, String amount) {
    return '$name costs you **$amount/year**. That’s your most expensive subscription.';
  }

  @override
  String get insightAnnualSavingsHeadline => 'Annual savings';

  @override
  String insightAnnualSavingsMessage(int count, String amount) {
    return 'Switching **$count subscriptions** to annual billing could save ~**$amount/year**.';
  }

  @override
  String get insightRealityCheckHeadline => 'Reality check';

  @override
  String insightRealityCheckMessage(int count) {
    return 'You have **$count active subscriptions**. The average person has 12 — are you using them all?';
  }

  @override
  String get insightMoneySavedHeadline => 'Money saved';

  @override
  String insightMoneySavedMessage(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
    );
    return 'You’ve saved **$amount** since cancelling **$_temp0**. Nice one!';
  }

  @override
  String get insightTrialEndingHeadline => 'Trial ending';

  @override
  String insightTrialEndingMessage(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'trials',
      one: 'trial',
    );
    return '**$names** $_temp0 ending soon. Cancel now or you’ll be charged.';
  }

  @override
  String get insightDailyCostHeadline => 'Daily cost';

  @override
  String insightDailyCostMessage(String amount) {
    return 'Your subscriptions cost **$amount/day** — that’s a fancy coffee, every single day.';
  }

  @override
  String notifRenewsToday(String name) {
    return '$name renews today';
  }

  @override
  String notifRenewsTomorrow(String name) {
    return '$name renews tomorrow';
  }

  @override
  String notifRenewsInDays(String name, int days) {
    return '$name renews in $days days';
  }

  @override
  String notifChargesToday(String price) {
    return 'You’ll be charged $price today. Tap to review or cancel.';
  }

  @override
  String notifChargesTomorrow(String price) {
    return '$price will be charged tomorrow. Still want to keep it?';
  }

  @override
  String notifCharges3Days(String price) {
    return '$price renewal coming up in 3 days.';
  }

  @override
  String notifChargesInDays(String price, int days) {
    return '$price renewal in $days days. Time to review?';
  }

  @override
  String notifTrialEndsToday(String name) {
    return '⚠ $name trial ends today!';
  }

  @override
  String notifTrialEndsTomorrow(String name) {
    return '$name trial ends tomorrow';
  }

  @override
  String notifTrialEndsInDays(String name, int days) {
    return '$name trial ends in $days days';
  }

  @override
  String notifTrialBodyToday(String price) {
    return 'Your free trial ends today! You’ll be charged $price. Cancel now if you don’t want to continue.';
  }

  @override
  String notifTrialBodyTomorrow(String price) {
    return 'One day left on your trial. After that it’s $price. Cancel now to avoid charges.';
  }

  @override
  String notifTrialBodyDays(int days, String price) {
    return '$days days left on your free trial. Full price is $price after that.';
  }

  @override
  String notifTrapTrialTitle3d(String name) {
    return '$name trial ends in 3 days';
  }

  @override
  String notifTrapTrialBody3d(String price) {
    return 'It’ll auto-charge $price. Cancel now if you don’t want it.';
  }

  @override
  String notifTrapTrialTitleTomorrow(String name, String price) {
    return '⚠️ TOMORROW: $name will charge $price';
  }

  @override
  String get notifTrapTrialBodyTomorrow =>
      'Cancel now if you don’t want to keep it.';

  @override
  String notifTrapTrialTitle2h(String name, String price) {
    return '🚨 $name charges $price in 2 HOURS';
  }

  @override
  String get notifTrapTrialBody2h => 'This is your last chance to cancel.';

  @override
  String notifTrapPostCharge(String name) {
    return 'Did you mean to keep $name?';
  }

  @override
  String notifTrapPostChargeBody(String price) {
    return 'You were charged $price. Tap if you need help getting a refund.';
  }

  @override
  String notifDigestBoth(int renewalCount, int trialCount) {
    return '$renewalCount renewal(s) + $trialCount trial(s) today';
  }

  @override
  String notifDigestRenewals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions renewing today',
      one: '1 subscription renewing today',
    );
    return '$_temp0';
  }

  @override
  String notifDigestTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trials expiring today',
      one: '1 trial expiring today',
    );
    return '$_temp0';
  }

  @override
  String notifDigestRenewalBody(String names, String total) {
    return '$names — $total total';
  }

  @override
  String notifDigestTrialBody(String names) {
    return '$names — cancel now to avoid charges';
  }

  @override
  String get cycleWeekly => 'Weekly';

  @override
  String get cycleMonthly => 'Monthly';

  @override
  String get cycleQuarterly => 'Quarterly';

  @override
  String get cycleYearly => 'Yearly';

  @override
  String get cycleWeeklyShort => 'wk';

  @override
  String get cycleMonthlyShort => 'mo';

  @override
  String get cycleQuarterlyShort => 'qtr';

  @override
  String get cycleYearlyShort => 'yr';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryDesign => 'Design';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryProductivity => 'Productivity';

  @override
  String get categoryStorage => 'Storage';

  @override
  String get categoryNews => 'News';

  @override
  String get categoryGaming => 'Gaming';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOther => 'Other';

  @override
  String get renewsToday => 'Renews today';

  @override
  String get renewsTomorrow => 'Renews tomorrow';

  @override
  String renewsInDays(int days) {
    return 'Renews in $days days';
  }

  @override
  String renewsOnDate(String date) {
    return 'Renews $date';
  }

  @override
  String get renewedYesterday => 'Renewed yesterday';

  @override
  String renewedDaysAgo(int days) {
    return 'Renewed $days days ago';
  }

  @override
  String get discoveryTipsTitle => 'Where to find subscriptions';

  @override
  String get discoveryTipBank => 'Bank statement';

  @override
  String get discoveryTipBankDesc =>
      'Screenshot your recent transactions — we’ll find them all at once';

  @override
  String get discoveryTipEmail => 'Email search';

  @override
  String get discoveryTipEmailDesc =>
      'Search “subscription”, “receipt” or “renewal” in your inbox';

  @override
  String get discoveryTipAppStore => 'App Store / Play Store';

  @override
  String get discoveryTipAppStoreDesc =>
      'Settings → Subscriptions shows all active app subscriptions';

  @override
  String get discoveryTipPaypal => 'PayPal & payment apps';

  @override
  String get discoveryTipPaypalDesc =>
      'Check automatic payments in PayPal, Revolut or your payment app';
}
