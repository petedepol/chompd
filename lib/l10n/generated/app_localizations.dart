import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Chompd'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Scan. Track. Bite back.'**
  String get tagline;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pro;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Bite Back at Subscriptions'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Chompd tracks every subscription, catches hidden traps, and helps you cancel what you don’t need.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingStatWaste.
  ///
  /// In en, this message translates to:
  /// **'The average person wastes {amount}/year on forgotten subscriptions'**
  String onboardingStatWaste(String amount);

  /// No description provided for @onboardingEaseTag.
  ///
  /// In en, this message translates to:
  /// **'No typing. Just snap and track.'**
  String get onboardingEaseTag;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get onboardingTitle2;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Snap a screenshot'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt, email, or bank statement'**
  String get onboardingStep1Subtitle;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'AI reads it instantly'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Price, renewal date, and hidden traps'**
  String get onboardingStep2Subtitle;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Done. Tracked forever.'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminders before you’re charged'**
  String get onboardingStep3Subtitle;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay Ahead of Renewals'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'We’ll remind you before you’re charged — no surprises.'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingNotifMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning of renewal'**
  String get onboardingNotifMorning;

  /// No description provided for @onboardingNotif7days.
  ///
  /// In en, this message translates to:
  /// **'7 days before'**
  String get onboardingNotif7days;

  /// No description provided for @onboardingNotifTrial.
  ///
  /// In en, this message translates to:
  /// **'Trial expiry alerts'**
  String get onboardingNotifTrial;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get allowNotifications;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Subscription'**
  String get onboardingTitle4;

  /// No description provided for @onboardingSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Most people find forgotten subscriptions in their first scan. Let’s see what’s eating your money.'**
  String get onboardingSubtitle4;

  /// No description provided for @scanAScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Scan a Screenshot'**
  String get scanAScreenshot;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get addManually;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @homeStatusLine.
  ///
  /// In en, this message translates to:
  /// **'{active} active · {cancelled} cancelled'**
  String homeStatusLine(int active, int cancelled);

  /// No description provided for @overBudgetMood.
  ///
  /// In en, this message translates to:
  /// **'Ouch. That’s a lot of chomping.'**
  String get overBudgetMood;

  /// No description provided for @underBudgetMood.
  ///
  /// In en, this message translates to:
  /// **'Looking good! Well under budget.'**
  String get underBudgetMood;

  /// No description provided for @sectionActiveSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE SUBSCRIPTIONS'**
  String get sectionActiveSubscriptions;

  /// No description provided for @sectionCancelledSaved.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED — MONEY SAVED'**
  String get sectionCancelledSaved;

  /// No description provided for @sectionMilestones.
  ///
  /// In en, this message translates to:
  /// **'MILESTONES'**
  String get sectionMilestones;

  /// No description provided for @sectionYearlyBurn.
  ///
  /// In en, this message translates to:
  /// **'YEARLY BURN'**
  String get sectionYearlyBurn;

  /// No description provided for @sectionMonthlyBurn.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY BURN'**
  String get sectionMonthlyBurn;

  /// No description provided for @sectionSavedWithChompd.
  ///
  /// In en, this message translates to:
  /// **'SAVED WITH CHOMPD'**
  String get sectionSavedWithChompd;

  /// No description provided for @perYearAcrossSubs.
  ///
  /// In en, this message translates to:
  /// **'per year across {count, plural, =1{1 subscription} other{{count} subscriptions}}'**
  String perYearAcrossSubs(int count);

  /// No description provided for @perMonthAcrossSubs.
  ///
  /// In en, this message translates to:
  /// **'per month across {count, plural, =1{1 subscription} other{{count} subscriptions}}'**
  String perMonthAcrossSubs(int count);

  /// No description provided for @monthlyAvg.
  ///
  /// In en, this message translates to:
  /// **'monthly avg'**
  String get monthlyAvg;

  /// No description provided for @yearlyTotal.
  ///
  /// In en, this message translates to:
  /// **'yearly total'**
  String get yearlyTotal;

  /// No description provided for @dailyCost.
  ///
  /// In en, this message translates to:
  /// **'daily cost'**
  String get dailyCost;

  /// No description provided for @fromCancelled.
  ///
  /// In en, this message translates to:
  /// **'from {count} cancelled'**
  String fromCancelled(int count);

  /// No description provided for @deleteSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Subscription?'**
  String get deleteSubscriptionTitle;

  /// No description provided for @deleteSubscriptionMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} permanently?'**
  String deleteSubscriptionMessage(String name);

  /// No description provided for @cancelledMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'Cancelled {months}mo ago'**
  String cancelledMonthsAgo(int months);

  /// No description provided for @justCancelled.
  ///
  /// In en, this message translates to:
  /// **'Just cancelled'**
  String get justCancelled;

  /// No description provided for @subsLeft.
  ///
  /// In en, this message translates to:
  /// **'Subs left'**
  String get subsLeft;

  /// No description provided for @scansLeft.
  ///
  /// In en, this message translates to:
  /// **'Scans left'**
  String get scansLeft;

  /// No description provided for @aiScanScreenshot.
  ///
  /// In en, this message translates to:
  /// **'AI Scan Screenshot'**
  String get aiScanScreenshot;

  /// No description provided for @aiScanUpgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'AI Scan (Upgrade to Pro)'**
  String get aiScanUpgradeToPro;

  /// No description provided for @quickAddManual.
  ///
  /// In en, this message translates to:
  /// **'Quick Add / Manual'**
  String get quickAddManual;

  /// No description provided for @addSubUpgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Add Sub (Upgrade to Pro)'**
  String get addSubUpgradeToPro;

  /// No description provided for @trialsExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 trial expiring soon} other{{count} trials expiring soon}}'**
  String trialsExpiringSoon(int count);

  /// No description provided for @trialDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{names} — {days} days left'**
  String trialDaysLeft(String names, int days);

  /// No description provided for @proInfinity.
  ///
  /// In en, this message translates to:
  /// **'PRO ∞'**
  String get proInfinity;

  /// No description provided for @scansLeftCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 scan left} other{{count} scans left}}'**
  String scansLeftCount(int count);

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Scan'**
  String get scanTitle;

  /// No description provided for @scanAnalysing.
  ///
  /// In en, this message translates to:
  /// **'Analysing your screenshot...'**
  String get scanAnalysing;

  /// No description provided for @scanIdleTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a Screenshot'**
  String get scanIdleTitle;

  /// No description provided for @scanIdleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share a screenshot of a confirmation email,\nbank statement, or app store receipt.'**
  String get scanIdleSubtitle;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @cameraPermError.
  ///
  /// In en, this message translates to:
  /// **'Could not access camera. Check permissions.'**
  String get cameraPermError;

  /// No description provided for @galleryPermError.
  ///
  /// In en, this message translates to:
  /// **'Could not access photo library. Check permissions.'**
  String get galleryPermError;

  /// No description provided for @smartMove.
  ///
  /// In en, this message translates to:
  /// **'Smart move!'**
  String get smartMove;

  /// No description provided for @youSkipped.
  ///
  /// In en, this message translates to:
  /// **'You skipped {service}'**
  String youSkipped(String service);

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get saved;

  /// No description provided for @addedToUnchompd.
  ///
  /// In en, this message translates to:
  /// **'Added to your Unchompd total'**
  String get addedToUnchompd;

  /// No description provided for @analysing.
  ///
  /// In en, this message translates to:
  /// **'Analysing...'**
  String get analysing;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get confidence;

  /// No description provided for @typeYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Type your answer...'**
  String get typeYourAnswer;

  /// No description provided for @addToChompd.
  ///
  /// In en, this message translates to:
  /// **'Add to Chompd'**
  String get addToChompd;

  /// No description provided for @monthlyTotal.
  ///
  /// In en, this message translates to:
  /// **'Monthly total'**
  String get monthlyTotal;

  /// No description provided for @addAllToChompd.
  ///
  /// In en, this message translates to:
  /// **'Add all {count} to Chompd'**
  String addAllToChompd(int count);

  /// No description provided for @autoTier.
  ///
  /// In en, this message translates to:
  /// **'AUTO'**
  String get autoTier;

  /// No description provided for @yesIts.
  ///
  /// In en, this message translates to:
  /// **'Yes, it’s {option}'**
  String yesIts(String option);

  /// No description provided for @otherAmount.
  ///
  /// In en, this message translates to:
  /// **'Other amount'**
  String get otherAmount;

  /// No description provided for @trapDetected.
  ///
  /// In en, this message translates to:
  /// **'TRAP DETECTED'**
  String get trapDetected;

  /// No description provided for @trapOfferActually.
  ///
  /// In en, this message translates to:
  /// **'This \"{name}\" offer is actually:'**
  String trapOfferActually(String name);

  /// No description provided for @skipItSave.
  ///
  /// In en, this message translates to:
  /// **'SKIP IT — SAVE {amount}'**
  String skipItSave(String amount);

  /// No description provided for @trackTrialAnyway.
  ///
  /// In en, this message translates to:
  /// **'Track Trial Anyway'**
  String get trackTrialAnyway;

  /// No description provided for @trapReminder.
  ///
  /// In en, this message translates to:
  /// **'We’ll remind you before it charges'**
  String get trapReminder;

  /// No description provided for @editSubscription.
  ///
  /// In en, this message translates to:
  /// **'Edit Subscription'**
  String get editSubscription;

  /// No description provided for @addSubscription.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get addSubscription;

  /// No description provided for @fieldServiceName.
  ///
  /// In en, this message translates to:
  /// **'SERVICE NAME'**
  String get fieldServiceName;

  /// No description provided for @hintServiceName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Netflix, Spotify'**
  String get hintServiceName;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name required'**
  String get errorNameRequired;

  /// No description provided for @fieldPrice.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get fieldPrice;

  /// No description provided for @hintPrice.
  ///
  /// In en, this message translates to:
  /// **'9.99'**
  String get hintPrice;

  /// No description provided for @errorPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price required'**
  String get errorPriceRequired;

  /// No description provided for @errorInvalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid price'**
  String get errorInvalidPrice;

  /// No description provided for @fieldCurrency.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get fieldCurrency;

  /// No description provided for @fieldBillingCycle.
  ///
  /// In en, this message translates to:
  /// **'BILLING CYCLE'**
  String get fieldBillingCycle;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get fieldCategory;

  /// No description provided for @fieldNextRenewal.
  ///
  /// In en, this message translates to:
  /// **'NEXT RENEWAL'**
  String get fieldNextRenewal;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @freeTrialToggle.
  ///
  /// In en, this message translates to:
  /// **'This is a free trial'**
  String get freeTrialToggle;

  /// No description provided for @trialDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Trial length'**
  String get trialDurationLabel;

  /// No description provided for @trialDays7.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get trialDays7;

  /// No description provided for @trialDays14.
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get trialDays14;

  /// No description provided for @trialDays30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get trialDays30;

  /// No description provided for @trialCustomDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String trialCustomDays(int days);

  /// No description provided for @fieldTrialEnds.
  ///
  /// In en, this message translates to:
  /// **'TRIAL ENDS'**
  String get fieldTrialEnds;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @subscriptionDetail.
  ///
  /// In en, this message translates to:
  /// **'Subscription Detail'**
  String get subscriptionDetail;

  /// No description provided for @thatsPerYear.
  ///
  /// In en, this message translates to:
  /// **'That’s {amount} per year'**
  String thatsPerYear(String amount);

  /// No description provided for @overThreeYears.
  ///
  /// In en, this message translates to:
  /// **'{amount} over 3 years'**
  String overThreeYears(String amount);

  /// No description provided for @trialDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Trial — {days} days remaining'**
  String trialDaysRemaining(int days);

  /// No description provided for @trialExpired.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Trial expired'**
  String get trialExpired;

  /// No description provided for @nextRenewal.
  ///
  /// In en, this message translates to:
  /// **'NEXT RENEWAL'**
  String get nextRenewal;

  /// No description provided for @chargesToday.
  ///
  /// In en, this message translates to:
  /// **'{price} charges today'**
  String chargesToday(String price);

  /// No description provided for @chargesTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{price} charges tomorrow'**
  String chargesTomorrow(String price);

  /// No description provided for @chargesSoon.
  ///
  /// In en, this message translates to:
  /// **'{days} days — {price} soon'**
  String chargesSoon(int days, String price);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysCount(int days);

  /// No description provided for @sectionReminders.
  ///
  /// In en, this message translates to:
  /// **'REMINDERS'**
  String get sectionReminders;

  /// No description provided for @remindersScheduled.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reminder scheduled} other{{count} reminders scheduled}}'**
  String remindersScheduled(int count);

  /// No description provided for @reminderDaysBefore7.
  ///
  /// In en, this message translates to:
  /// **'7 days before'**
  String get reminderDaysBefore7;

  /// No description provided for @reminderDaysBefore3.
  ///
  /// In en, this message translates to:
  /// **'3 days before'**
  String get reminderDaysBefore3;

  /// No description provided for @reminderDaysBefore1.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get reminderDaysBefore1;

  /// No description provided for @reminderMorningOf.
  ///
  /// In en, this message translates to:
  /// **'Morning of'**
  String get reminderMorningOf;

  /// No description provided for @upgradeForReminders.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro for advance reminders'**
  String get upgradeForReminders;

  /// No description provided for @sectionPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT HISTORY'**
  String get sectionPaymentHistory;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get totalPaid;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet — started {date}'**
  String noPaymentsYet(String date);

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @sectionDetails.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get sectionDetails;

  /// No description provided for @detailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get detailCategory;

  /// No description provided for @detailCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get detailCurrency;

  /// No description provided for @detailBillingCycle.
  ///
  /// In en, this message translates to:
  /// **'Billing cycle'**
  String get detailBillingCycle;

  /// No description provided for @detailAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get detailAdded;

  /// No description provided for @addedVia.
  ///
  /// In en, this message translates to:
  /// **'{date} via {source}'**
  String addedVia(String date, String source);

  /// No description provided for @sourceAiScan.
  ///
  /// In en, this message translates to:
  /// **'AI Scan'**
  String get sourceAiScan;

  /// No description provided for @sourceQuickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get sourceQuickAdd;

  /// No description provided for @sourceManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get sourceManual;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// No description provided for @cancelPlatformPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you pay for {name}?'**
  String cancelPlatformPickerTitle(String name);

  /// No description provided for @cancelPlatformIos.
  ///
  /// In en, this message translates to:
  /// **'Apple App Store'**
  String get cancelPlatformIos;

  /// No description provided for @cancelPlatformAndroid.
  ///
  /// In en, this message translates to:
  /// **'Google Play'**
  String get cancelPlatformAndroid;

  /// No description provided for @cancelPlatformWeb.
  ///
  /// In en, this message translates to:
  /// **'Website / Direct'**
  String get cancelPlatformWeb;

  /// No description provided for @cancelPlatformNotSure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get cancelPlatformNotSure;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy — straightforward cancel'**
  String get difficultyEasy;

  /// No description provided for @difficultyModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate — a few steps required'**
  String get difficultyModerate;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium — takes a few minutes'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard — they make this deliberately difficult'**
  String get difficultyHard;

  /// No description provided for @difficultyVeryHard.
  ///
  /// In en, this message translates to:
  /// **'Very hard — multiple retention screens or fees'**
  String get difficultyVeryHard;

  /// No description provided for @requestRefund.
  ///
  /// In en, this message translates to:
  /// **'Request Refund'**
  String get requestRefund;

  /// No description provided for @deleteNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteNameTitle(String name);

  /// No description provided for @deleteNameMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove this subscription. This cannot be undone.'**
  String get deleteNameMessage;

  /// No description provided for @noGuideYet.
  ///
  /// In en, this message translates to:
  /// **'No specific guide for {name} yet. Try searching \"{name} cancel subscription\" online.'**
  String noGuideYet(String name);

  /// No description provided for @realAnnualCost.
  ///
  /// In en, this message translates to:
  /// **'Real annual cost: {amount}/yr'**
  String realAnnualCost(String amount);

  /// No description provided for @trialExpires.
  ///
  /// In en, this message translates to:
  /// **'Trial expires {date}'**
  String trialExpires(String date);

  /// No description provided for @chompdPro.
  ///
  /// In en, this message translates to:
  /// **'Chompd Pro'**
  String get chompdPro;

  /// No description provided for @paywallTagline.
  ///
  /// In en, this message translates to:
  /// **'A subscription tracker that isn’t a subscription.'**
  String get paywallTagline;

  /// No description provided for @paywallLimitSubs.
  ///
  /// In en, this message translates to:
  /// **'You’ve hit the free limit of {count} subscriptions.'**
  String paywallLimitSubs(int count);

  /// No description provided for @paywallLimitScans.
  ///
  /// In en, this message translates to:
  /// **'You’ve used all {count} free AI scans.'**
  String paywallLimitScans(int count);

  /// No description provided for @paywallLimitReminders.
  ///
  /// In en, this message translates to:
  /// **'Advance reminders are a Pro feature.'**
  String get paywallLimitReminders;

  /// No description provided for @paywallGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full Chompd experience.'**
  String get paywallGeneric;

  /// No description provided for @paywallFeature1.
  ///
  /// In en, this message translates to:
  /// **'Save 100–500/year on hidden waste'**
  String get paywallFeature1;

  /// No description provided for @paywallFeature2.
  ///
  /// In en, this message translates to:
  /// **'Never miss a trial expiry again'**
  String get paywallFeature2;

  /// No description provided for @paywallFeature3.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI trap scanning'**
  String get paywallFeature3;

  /// No description provided for @paywallFeature4.
  ///
  /// In en, this message translates to:
  /// **'Track every subscription you have'**
  String get paywallFeature4;

  /// No description provided for @paywallFeature5.
  ///
  /// In en, this message translates to:
  /// **'Early warnings: 7d, 3d, 1d before charges'**
  String get paywallFeature5;

  /// No description provided for @paywallFeature6.
  ///
  /// In en, this message translates to:
  /// **'Shareable savings cards'**
  String get paywallFeature6;

  /// No description provided for @paywallContext.
  ///
  /// In en, this message translates to:
  /// **'Pays for itself after cancelling just one forgotten subscription.'**
  String get paywallContext;

  /// No description provided for @oneTimePayment.
  ///
  /// In en, this message translates to:
  /// **'One-time payment. Forever.'**
  String get oneTimePayment;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'LIFETIME'**
  String get lifetime;

  /// No description provided for @unlockChompdPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock Chompd Pro'**
  String get unlockChompdPro;

  /// No description provided for @restoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring...'**
  String get restoring;

  /// No description provided for @restorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get restorePurchase;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'Purchase could not be completed. Try again.'**
  String get purchaseError;

  /// No description provided for @noPreviousPurchase.
  ///
  /// In en, this message translates to:
  /// **'No previous purchase found.'**
  String get noPreviousPurchase;

  /// No description provided for @renewalCalendar.
  ///
  /// In en, this message translates to:
  /// **'Renewal Calendar'**
  String get renewalCalendar;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @noRenewalsThisDay.
  ///
  /// In en, this message translates to:
  /// **'No renewals this day'**
  String get noRenewalsThisDay;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get thisMonth;

  /// No description provided for @renewals.
  ///
  /// In en, this message translates to:
  /// **'Renewals'**
  String get renewals;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @renewalsOnDay.
  ///
  /// In en, this message translates to:
  /// **'{count} renewals on {date} totalling {price}'**
  String renewalsOnDay(int count, String date, String price);

  /// No description provided for @biggestDay.
  ///
  /// In en, this message translates to:
  /// **'Biggest day: {date} — {price}'**
  String biggestDay(String date, String price);

  /// No description provided for @tapDayToSee.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to see what renews'**
  String get tapDayToSee;

  /// No description provided for @cancelGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel {name}'**
  String cancelGuideTitle(String name);

  /// No description provided for @whyCancelling.
  ///
  /// In en, this message translates to:
  /// **'Why are you cancelling?'**
  String get whyCancelling;

  /// No description provided for @whyCancellingHint.
  ///
  /// In en, this message translates to:
  /// **'Quick tap — helps us improve Chompd.'**
  String get whyCancellingHint;

  /// No description provided for @reasonTooExpensive.
  ///
  /// In en, this message translates to:
  /// **'Too expensive'**
  String get reasonTooExpensive;

  /// No description provided for @reasonDontUse.
  ///
  /// In en, this message translates to:
  /// **'Don’t use it enough'**
  String get reasonDontUse;

  /// No description provided for @reasonBreak.
  ///
  /// In en, this message translates to:
  /// **'Taking a break'**
  String get reasonBreak;

  /// No description provided for @reasonSwitching.
  ///
  /// In en, this message translates to:
  /// **'Switching to something else'**
  String get reasonSwitching;

  /// No description provided for @difficultyLevel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficultyLevel;

  /// No description provided for @cancellationSteps.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Steps'**
  String get cancellationSteps;

  /// No description provided for @stepNumber.
  ///
  /// In en, this message translates to:
  /// **'STEP {number}'**
  String stepNumber(int number);

  /// No description provided for @openCancelPage.
  ///
  /// In en, this message translates to:
  /// **'Open Cancel Page'**
  String get openCancelPage;

  /// No description provided for @iveCancelled.
  ///
  /// In en, this message translates to:
  /// **'I’ve Cancelled'**
  String get iveCancelled;

  /// No description provided for @couldntCancelRefund.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t cancel? Get Refund Help →'**
  String get couldntCancelRefund;

  /// No description provided for @refundTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip: Why request a refund?'**
  String get refundTipTitle;

  /// No description provided for @refundTipBody.
  ///
  /// In en, this message translates to:
  /// **'If you were charged unexpectedly, signed up by accident, or the service didn’t work as promised — you may be entitled to a refund. The earlier you request, the better your chances.'**
  String get refundTipBody;

  /// No description provided for @refundRescue.
  ///
  /// In en, this message translates to:
  /// **'Refund Rescue'**
  String get refundRescue;

  /// No description provided for @refundIntro.
  ///
  /// In en, this message translates to:
  /// **'Don’t worry — most people get their money back. Let’s sort this.'**
  String get refundIntro;

  /// No description provided for @chargedYou.
  ///
  /// In en, this message translates to:
  /// **'{name} charged you {price}'**
  String chargedYou(String name, String price);

  /// No description provided for @howCharged.
  ///
  /// In en, this message translates to:
  /// **'HOW WERE YOU CHARGED?'**
  String get howCharged;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success: {rate}'**
  String successRate(String rate);

  /// No description provided for @copyDisputeEmail.
  ///
  /// In en, this message translates to:
  /// **'Copy Dispute Email'**
  String get copyDisputeEmail;

  /// No description provided for @openRefundPage.
  ///
  /// In en, this message translates to:
  /// **'Open Refund Page'**
  String get openRefundPage;

  /// No description provided for @iveSubmittedRequest.
  ///
  /// In en, this message translates to:
  /// **'I’ve Submitted My Request'**
  String get iveSubmittedRequest;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted!'**
  String get requestSubmitted;

  /// No description provided for @requestSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'We’ve recorded your refund request. Keep an eye on your email for updates.'**
  String get requestSubmittedMessage;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard'**
  String get emailCopied;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'THEME'**
  String get themeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @sectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get sectionNotifications;

  /// No description provided for @remindersScheduledSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reminder scheduled} other{{count} reminders scheduled}}'**
  String remindersScheduledSummary(int count);

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminded about renewals and trials'**
  String get pushNotificationsSubtitle;

  /// No description provided for @morningDigest.
  ///
  /// In en, this message translates to:
  /// **'Morning Digest'**
  String get morningDigest;

  /// No description provided for @morningDigestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily summary at {time}'**
  String morningDigestSubtitle(String time);

  /// No description provided for @renewalReminders.
  ///
  /// In en, this message translates to:
  /// **'Renewal Reminders'**
  String get renewalReminders;

  /// No description provided for @trialExpiryAlerts.
  ///
  /// In en, this message translates to:
  /// **'Trial Expiry Alerts'**
  String get trialExpiryAlerts;

  /// No description provided for @trialExpirySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warns at 3 days, 1 day, and day-of'**
  String get trialExpirySubtitle;

  /// No description provided for @sectionReminderSchedule.
  ///
  /// In en, this message translates to:
  /// **'REMINDER SCHEDULE'**
  String get sectionReminderSchedule;

  /// No description provided for @sectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get sectionUpcoming;

  /// No description provided for @noUpcomingNotifications.
  ///
  /// In en, this message translates to:
  /// **'No upcoming notifications'**
  String get noUpcomingNotifications;

  /// No description provided for @sectionChompdPro.
  ///
  /// In en, this message translates to:
  /// **'CHOMPD PRO'**
  String get sectionChompdPro;

  /// No description provided for @sectionCurrency.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get sectionCurrency;

  /// No description provided for @displayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Display currency'**
  String get displayCurrency;

  /// No description provided for @sectionMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY BUDGET'**
  String get sectionMonthlyBudget;

  /// No description provided for @monthlySpendingTarget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Spending Target'**
  String get monthlySpendingTarget;

  /// No description provided for @budgetHint.
  ///
  /// In en, this message translates to:
  /// **'Used for the spending ring on your dashboard'**
  String get budgetHint;

  /// No description provided for @sectionHapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'HAPTIC FEEDBACK'**
  String get sectionHapticFeedback;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrations on taps, toggles, and celebrations'**
  String get hapticSubtitle;

  /// No description provided for @sectionDataExport.
  ///
  /// In en, this message translates to:
  /// **'DATA EXPORT'**
  String get sectionDataExport;

  /// No description provided for @exportToCsv.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportToCsv;

  /// No description provided for @exportHint.
  ///
  /// In en, this message translates to:
  /// **'Download all your subscriptions as a spreadsheet'**
  String get exportHint;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Exported {count} subscriptions to CSV'**
  String exportSuccess(int count);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get sectionAbout;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @tier.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get tier;

  /// No description provided for @aiModel.
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get aiModel;

  /// No description provided for @aiModelValue.
  ///
  /// In en, this message translates to:
  /// **'Claude Haiku 4.5'**
  String get aiModelValue;

  /// No description provided for @setBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Monthly Budget'**
  String get setBudgetTitle;

  /// No description provided for @setBudgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your target monthly subscription spend.'**
  String get setBudgetSubtitle;

  /// No description provided for @reminderSubtitleMorningOnly.
  ///
  /// In en, this message translates to:
  /// **'Morning-of only (upgrade for more)'**
  String get reminderSubtitleMorningOnly;

  /// No description provided for @reminderSubtitleDays.
  ///
  /// In en, this message translates to:
  /// **'{schedule} before renewal'**
  String reminderSubtitleDays(String schedule);

  /// No description provided for @dayOf.
  ///
  /// In en, this message translates to:
  /// **'day-of'**
  String get dayOf;

  /// No description provided for @oneDay.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get oneDay;

  /// No description provided for @nDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String nDays(int days);

  /// No description provided for @timelineLabel7d.
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get timelineLabel7d;

  /// No description provided for @timelineLabel3d.
  ///
  /// In en, this message translates to:
  /// **'3d'**
  String get timelineLabel3d;

  /// No description provided for @timelineLabel1d.
  ///
  /// In en, this message translates to:
  /// **'1d'**
  String get timelineLabel1d;

  /// No description provided for @timelineLabelDayOf.
  ///
  /// In en, this message translates to:
  /// **'Day of'**
  String get timelineLabelDayOf;

  /// No description provided for @upgradeProReminders.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro for 7d, 3d, and 1d reminders'**
  String get upgradeProReminders;

  /// No description provided for @proPrice.
  ///
  /// In en, this message translates to:
  /// **'£{price}'**
  String proPrice(String price);

  /// No description provided for @oneTimePaymentShort.
  ///
  /// In en, this message translates to:
  /// **'{price} • One-time payment'**
  String oneTimePaymentShort(String price);

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get sectionLanguage;

  /// No description provided for @severityHigh.
  ///
  /// In en, this message translates to:
  /// **'HIGH RISK'**
  String get severityHigh;

  /// No description provided for @severityCaution.
  ///
  /// In en, this message translates to:
  /// **'CAUTION'**
  String get severityCaution;

  /// No description provided for @severityInfo.
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get severityInfo;

  /// No description provided for @trapTypeTrialBait.
  ///
  /// In en, this message translates to:
  /// **'Trial Bait'**
  String get trapTypeTrialBait;

  /// No description provided for @trapTypePriceFraming.
  ///
  /// In en, this message translates to:
  /// **'Price Framing'**
  String get trapTypePriceFraming;

  /// No description provided for @trapTypeHiddenRenewal.
  ///
  /// In en, this message translates to:
  /// **'Hidden Renewal'**
  String get trapTypeHiddenRenewal;

  /// No description provided for @trapTypeCancelFriction.
  ///
  /// In en, this message translates to:
  /// **'Cancel Friction'**
  String get trapTypeCancelFriction;

  /// No description provided for @trapTypeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Subscription Trap'**
  String get trapTypeGeneric;

  /// No description provided for @severityExplainHigh.
  ///
  /// In en, this message translates to:
  /// **'Extreme price jump or deceptive framing'**
  String get severityExplainHigh;

  /// No description provided for @severityExplainMedium.
  ///
  /// In en, this message translates to:
  /// **'Introductory price increases significantly'**
  String get severityExplainMedium;

  /// No description provided for @severityExplainLow.
  ///
  /// In en, this message translates to:
  /// **'Standard trial with auto-renewal'**
  String get severityExplainLow;

  /// No description provided for @trialBadge.
  ///
  /// In en, this message translates to:
  /// **'{days}d trial'**
  String trialBadge(int days);

  /// No description provided for @emptyNoSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet'**
  String get emptyNoSubscriptions;

  /// No description provided for @emptyNoSubscriptionsHint.
  ///
  /// In en, this message translates to:
  /// **'Scan a screenshot or tap + to get started.'**
  String get emptyNoSubscriptionsHint;

  /// No description provided for @emptyNoTrials.
  ///
  /// In en, this message translates to:
  /// **'No active trials'**
  String get emptyNoTrials;

  /// No description provided for @emptyNoTrialsHint.
  ///
  /// In en, this message translates to:
  /// **'When you add trial subscriptions,\nthey’ll appear here with countdown alerts.'**
  String get emptyNoTrialsHint;

  /// No description provided for @emptyNoSavings.
  ///
  /// In en, this message translates to:
  /// **'No savings yet'**
  String get emptyNoSavings;

  /// No description provided for @emptyNoSavingsHint.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscriptions you don’t use\nand watch your savings grow here.'**
  String get emptyNoSavingsHint;

  /// No description provided for @nudgeReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get nudgeReview;

  /// No description provided for @nudgeKeepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get nudgeKeepIt;

  /// No description provided for @trialLabel.
  ///
  /// In en, this message translates to:
  /// **'TRIAL'**
  String get trialLabel;

  /// No description provided for @priceToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get priceToday;

  /// No description provided for @priceThen.
  ///
  /// In en, this message translates to:
  /// **'THEN'**
  String get priceThen;

  /// No description provided for @dayTrial.
  ///
  /// In en, this message translates to:
  /// **'{days}-day trial'**
  String dayTrial(String days);

  /// No description provided for @realCostFirstYear.
  ///
  /// In en, this message translates to:
  /// **'Real cost first year: {amount}'**
  String realCostFirstYear(String amount);

  /// No description provided for @milestoneCoffeeFund.
  ///
  /// In en, this message translates to:
  /// **'Coffee Fund'**
  String get milestoneCoffeeFund;

  /// No description provided for @milestoneGamePass.
  ///
  /// In en, this message translates to:
  /// **'Game Pass'**
  String get milestoneGamePass;

  /// No description provided for @milestoneWeekendAway.
  ///
  /// In en, this message translates to:
  /// **'Weekend Away'**
  String get milestoneWeekendAway;

  /// No description provided for @milestoneNewGadget.
  ///
  /// In en, this message translates to:
  /// **'New Gadget'**
  String get milestoneNewGadget;

  /// No description provided for @milestoneDreamHoliday.
  ///
  /// In en, this message translates to:
  /// **'Dream Holiday'**
  String get milestoneDreamHoliday;

  /// No description provided for @milestoneFirstBiteBack.
  ///
  /// In en, this message translates to:
  /// **'First Bite Back'**
  String get milestoneFirstBiteBack;

  /// No description provided for @milestoneChompSpotter.
  ///
  /// In en, this message translates to:
  /// **'Chomp Spotter'**
  String get milestoneChompSpotter;

  /// No description provided for @milestoneDarkPatternDestroyer.
  ///
  /// In en, this message translates to:
  /// **'Dark Pattern Destroyer'**
  String get milestoneDarkPatternDestroyer;

  /// No description provided for @milestoneSubscriptionSentinel.
  ///
  /// In en, this message translates to:
  /// **'Subscription Sentinel'**
  String get milestoneSubscriptionSentinel;

  /// No description provided for @milestoneUnchompable.
  ///
  /// In en, this message translates to:
  /// **'Unchompable'**
  String get milestoneUnchompable;

  /// No description provided for @milestoneReached.
  ///
  /// In en, this message translates to:
  /// **'✓ Reached!'**
  String get milestoneReached;

  /// No description provided for @milestoneToGo.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String milestoneToGo(String amount);

  /// No description provided for @celebrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Nice one! 🎉'**
  String get celebrationTitle;

  /// No description provided for @celebrationSavePerYear.
  ///
  /// In en, this message translates to:
  /// **'You’ll save {amount}/year'**
  String celebrationSavePerYear(String amount);

  /// No description provided for @celebrationByDropping.
  ///
  /// In en, this message translates to:
  /// **'by dropping {name}'**
  String celebrationByDropping(String name);

  /// No description provided for @tapAnywhereToContinue.
  ///
  /// In en, this message translates to:
  /// **'tap anywhere to continue'**
  String get tapAnywhereToContinue;

  /// No description provided for @trapBadge.
  ///
  /// In en, this message translates to:
  /// **'TRAP'**
  String get trapBadge;

  /// No description provided for @trapDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d trap'**
  String trapDays(int days);

  /// No description provided for @unchompd.
  ///
  /// In en, this message translates to:
  /// **'Unchompd'**
  String get unchompd;

  /// No description provided for @fromSubscriptionTraps.
  ///
  /// In en, this message translates to:
  /// **'from subscription traps'**
  String get fromSubscriptionTraps;

  /// No description provided for @trapsDodged.
  ///
  /// In en, this message translates to:
  /// **'{count} dodged'**
  String trapsDodged(int count);

  /// No description provided for @trialsCancelled.
  ///
  /// In en, this message translates to:
  /// **'{count} cancelled'**
  String trialsCancelled(int count);

  /// No description provided for @refundsRecovered.
  ///
  /// In en, this message translates to:
  /// **'{count} refunded'**
  String refundsRecovered(int count);

  /// No description provided for @ringYearly.
  ///
  /// In en, this message translates to:
  /// **'YEARLY'**
  String get ringYearly;

  /// No description provided for @ringMonthly.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY'**
  String get ringMonthly;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'{amount} over budget'**
  String overBudget(String amount);

  /// No description provided for @ofBudget.
  ///
  /// In en, this message translates to:
  /// **'of {amount} budget'**
  String ofBudget(String amount);

  /// No description provided for @tapForMonthly.
  ///
  /// In en, this message translates to:
  /// **'tap for monthly'**
  String get tapForMonthly;

  /// No description provided for @tapForYearly.
  ///
  /// In en, this message translates to:
  /// **'tap for yearly'**
  String get tapForYearly;

  /// No description provided for @budgetRange.
  ///
  /// In en, this message translates to:
  /// **'Budget: {min} – {max}'**
  String budgetRange(String min, String max);

  /// No description provided for @addSubscriptionSheet.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get addSubscriptionSheet;

  /// No description provided for @orChooseService.
  ///
  /// In en, this message translates to:
  /// **'or choose a service'**
  String get orChooseService;

  /// No description provided for @searchServices.
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get searchServices;

  /// No description provided for @priceField.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceField;

  /// No description provided for @addServiceName.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String addServiceName(String name);

  /// No description provided for @tapForMore.
  ///
  /// In en, this message translates to:
  /// **'tap for more'**
  String get tapForMore;

  /// No description provided for @shareYearlyBurn.
  ///
  /// In en, this message translates to:
  /// **'I spend {symbol}{amount}/year on {count, plural, =1{1 subscription} other{{count} subscriptions}} 😳'**
  String shareYearlyBurn(String symbol, String amount, int count);

  /// No description provided for @shareMonthlyDaily.
  ///
  /// In en, this message translates to:
  /// **'That’s {symbol}{monthly}/month or {symbol}{daily}/day'**
  String shareMonthlyDaily(String symbol, String monthly, String daily);

  /// No description provided for @shareSavedBy.
  ///
  /// In en, this message translates to:
  /// **'✓ Saved {symbol}{amount} by cancelling {count, plural, =1{1 subscription} other{{count} subscriptions}}'**
  String shareSavedBy(String symbol, String amount, int count);

  /// No description provided for @shareFooter.
  ///
  /// In en, this message translates to:
  /// **'Tracked with Chompd — Scan. Track. Bite back.'**
  String get shareFooter;

  /// No description provided for @shareSavings.
  ///
  /// In en, this message translates to:
  /// **'I saved {symbol}{amount} by cancelling {count, plural, =1{1 subscription} other{{count} subscriptions}} 🎉\n\nBite back at subscriptions — getchompd.com'**
  String shareSavings(String symbol, String amount, int count);

  /// No description provided for @insightBigSpenderHeadline.
  ///
  /// In en, this message translates to:
  /// **'Big spender'**
  String get insightBigSpenderHeadline;

  /// No description provided for @insightBigSpenderMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} costs you **{amount}/year**. That’s your most expensive subscription.'**
  String insightBigSpenderMessage(String name, String amount);

  /// No description provided for @insightAnnualSavingsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Annual savings'**
  String get insightAnnualSavingsHeadline;

  /// No description provided for @insightAnnualSavingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Switching **{count} subscriptions** to annual billing could save ~**{amount}/year**.'**
  String insightAnnualSavingsMessage(int count, String amount);

  /// No description provided for @insightRealityCheckHeadline.
  ///
  /// In en, this message translates to:
  /// **'Reality check'**
  String get insightRealityCheckHeadline;

  /// No description provided for @insightRealityCheckMessage.
  ///
  /// In en, this message translates to:
  /// **'You have **{count} active subscriptions**. The average person has 12 — are you using them all?'**
  String insightRealityCheckMessage(int count);

  /// No description provided for @insightMoneySavedHeadline.
  ///
  /// In en, this message translates to:
  /// **'Money saved'**
  String get insightMoneySavedHeadline;

  /// No description provided for @insightMoneySavedMessage.
  ///
  /// In en, this message translates to:
  /// **'You’ve saved **{amount}** since cancelling **{count, plural, =1{1 subscription} other{{count} subscriptions}}**. Nice one!'**
  String insightMoneySavedMessage(String amount, int count);

  /// No description provided for @insightTrialEndingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Trial ending'**
  String get insightTrialEndingHeadline;

  /// No description provided for @insightTrialEndingMessage.
  ///
  /// In en, this message translates to:
  /// **'**{names}** {count, plural, =1{trial} other{trials}} ending soon. Cancel now or you’ll be charged.'**
  String insightTrialEndingMessage(String names, int count);

  /// No description provided for @insightDailyCostHeadline.
  ///
  /// In en, this message translates to:
  /// **'Daily cost'**
  String get insightDailyCostHeadline;

  /// No description provided for @insightDailyCostMessage.
  ///
  /// In en, this message translates to:
  /// **'Your subscriptions cost **{amount}/day** — that’s a fancy coffee, every single day.'**
  String insightDailyCostMessage(String amount);

  /// No description provided for @notifRenewsToday.
  ///
  /// In en, this message translates to:
  /// **'{name} renews today'**
  String notifRenewsToday(String name);

  /// No description provided for @notifRenewsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{name} renews tomorrow'**
  String notifRenewsTomorrow(String name);

  /// No description provided for @notifRenewsInDays.
  ///
  /// In en, this message translates to:
  /// **'{name} renews in {days} days'**
  String notifRenewsInDays(String name, int days);

  /// No description provided for @notifChargesToday.
  ///
  /// In en, this message translates to:
  /// **'You’ll be charged {price} today. Tap to review or cancel.'**
  String notifChargesToday(String price);

  /// No description provided for @notifChargesTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{price} will be charged tomorrow. Still want to keep it?'**
  String notifChargesTomorrow(String price);

  /// No description provided for @notifCharges3Days.
  ///
  /// In en, this message translates to:
  /// **'{price} renewal coming up in 3 days.'**
  String notifCharges3Days(String price);

  /// No description provided for @notifChargesInDays.
  ///
  /// In en, this message translates to:
  /// **'{price} renewal in {days} days. Time to review?'**
  String notifChargesInDays(String price, int days);

  /// No description provided for @notifTrialEndsToday.
  ///
  /// In en, this message translates to:
  /// **'⚠ {name} trial ends today!'**
  String notifTrialEndsToday(String name);

  /// No description provided for @notifTrialEndsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{name} trial ends tomorrow'**
  String notifTrialEndsTomorrow(String name);

  /// No description provided for @notifTrialEndsInDays.
  ///
  /// In en, this message translates to:
  /// **'{name} trial ends in {days} days'**
  String notifTrialEndsInDays(String name, int days);

  /// No description provided for @notifTrialBodyToday.
  ///
  /// In en, this message translates to:
  /// **'Your free trial ends today! You’ll be charged {price}. Cancel now if you don’t want to continue.'**
  String notifTrialBodyToday(String price);

  /// No description provided for @notifTrialBodyTomorrow.
  ///
  /// In en, this message translates to:
  /// **'One day left on your trial. After that it’s {price}. Cancel now to avoid charges.'**
  String notifTrialBodyTomorrow(String price);

  /// No description provided for @notifTrialBodyDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days left on your free trial. Full price is {price} after that.'**
  String notifTrialBodyDays(int days, String price);

  /// No description provided for @notifTrapTrialTitle3d.
  ///
  /// In en, this message translates to:
  /// **'{name} trial ends in 3 days'**
  String notifTrapTrialTitle3d(String name);

  /// No description provided for @notifTrapTrialBody3d.
  ///
  /// In en, this message translates to:
  /// **'It’ll auto-charge {price}. Cancel now if you don’t want it.'**
  String notifTrapTrialBody3d(String price);

  /// No description provided for @notifTrapTrialTitleTomorrow.
  ///
  /// In en, this message translates to:
  /// **'⚠️ TOMORROW: {name} will charge {price}'**
  String notifTrapTrialTitleTomorrow(String name, String price);

  /// No description provided for @notifTrapTrialBodyTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Cancel now if you don’t want to keep it.'**
  String get notifTrapTrialBodyTomorrow;

  /// No description provided for @notifTrapTrialTitle2h.
  ///
  /// In en, this message translates to:
  /// **'🚨 {name} charges {price} in 2 HOURS'**
  String notifTrapTrialTitle2h(String name, String price);

  /// No description provided for @notifTrapTrialBody2h.
  ///
  /// In en, this message translates to:
  /// **'This is your last chance to cancel.'**
  String get notifTrapTrialBody2h;

  /// No description provided for @notifTrapPostCharge.
  ///
  /// In en, this message translates to:
  /// **'Did you mean to keep {name}?'**
  String notifTrapPostCharge(String name);

  /// No description provided for @notifTrapPostChargeBody.
  ///
  /// In en, this message translates to:
  /// **'You were charged {price}. Tap if you need help getting a refund.'**
  String notifTrapPostChargeBody(String price);

  /// No description provided for @notifDigestBoth.
  ///
  /// In en, this message translates to:
  /// **'{renewalCount} renewal(s) + {trialCount} trial(s) today'**
  String notifDigestBoth(int renewalCount, int trialCount);

  /// No description provided for @notifDigestRenewals.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 subscription renewing today} other{{count} subscriptions renewing today}}'**
  String notifDigestRenewals(int count);

  /// No description provided for @notifDigestTrials.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 trial expiring today} other{{count} trials expiring today}}'**
  String notifDigestTrials(int count);

  /// No description provided for @notifDigestRenewalBody.
  ///
  /// In en, this message translates to:
  /// **'{names} — {total} total'**
  String notifDigestRenewalBody(String names, String total);

  /// No description provided for @notifDigestTrialBody.
  ///
  /// In en, this message translates to:
  /// **'{names} — cancel now to avoid charges'**
  String notifDigestTrialBody(String names);

  /// No description provided for @cycleWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get cycleWeekly;

  /// No description provided for @cycleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get cycleMonthly;

  /// No description provided for @cycleQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get cycleQuarterly;

  /// No description provided for @cycleYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get cycleYearly;

  /// No description provided for @cycleWeeklyShort.
  ///
  /// In en, this message translates to:
  /// **'wk'**
  String get cycleWeeklyShort;

  /// No description provided for @cycleMonthlyShort.
  ///
  /// In en, this message translates to:
  /// **'mo'**
  String get cycleMonthlyShort;

  /// No description provided for @cycleQuarterlyShort.
  ///
  /// In en, this message translates to:
  /// **'qtr'**
  String get cycleQuarterlyShort;

  /// No description provided for @cycleYearlyShort.
  ///
  /// In en, this message translates to:
  /// **'yr'**
  String get cycleYearlyShort;

  /// No description provided for @categoryStreaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get categoryStreaming;

  /// No description provided for @categoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get categoryMusic;

  /// No description provided for @categoryAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get categoryAi;

  /// No description provided for @categoryProductivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get categoryProductivity;

  /// No description provided for @categoryStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get categoryStorage;

  /// No description provided for @categoryFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get categoryFitness;

  /// No description provided for @categoryGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get categoryGaming;

  /// No description provided for @categoryReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get categoryReading;

  /// No description provided for @categoryCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get categoryCommunication;

  /// No description provided for @categoryNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get categoryNews;

  /// No description provided for @categoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get categoryFinance;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryVpn.
  ///
  /// In en, this message translates to:
  /// **'VPN'**
  String get categoryVpn;

  /// No description provided for @categoryDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get categoryDeveloper;

  /// No description provided for @categoryBundle.
  ///
  /// In en, this message translates to:
  /// **'Bundle'**
  String get categoryBundle;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @paymentsTrackedHint.
  ///
  /// In en, this message translates to:
  /// **'Payments will be tracked after each renewal'**
  String get paymentsTrackedHint;

  /// No description provided for @renewsToday.
  ///
  /// In en, this message translates to:
  /// **'Renews today'**
  String get renewsToday;

  /// No description provided for @renewsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Renews tomorrow'**
  String get renewsTomorrow;

  /// No description provided for @renewsInDays.
  ///
  /// In en, this message translates to:
  /// **'Renews in {days} days'**
  String renewsInDays(int days);

  /// No description provided for @renewsOnDate.
  ///
  /// In en, this message translates to:
  /// **'Renews {date}'**
  String renewsOnDate(String date);

  /// No description provided for @renewedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Renewed yesterday'**
  String get renewedYesterday;

  /// No description provided for @renewedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Renewed {days} days ago'**
  String renewedDaysAgo(int days);

  /// No description provided for @discoveryTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to find subscriptions'**
  String get discoveryTipsTitle;

  /// No description provided for @discoveryTipBank.
  ///
  /// In en, this message translates to:
  /// **'Bank statement'**
  String get discoveryTipBank;

  /// No description provided for @discoveryTipBankDesc.
  ///
  /// In en, this message translates to:
  /// **'Screenshot your recent transactions — we’ll find them all at once'**
  String get discoveryTipBankDesc;

  /// No description provided for @discoveryTipEmail.
  ///
  /// In en, this message translates to:
  /// **'Email search'**
  String get discoveryTipEmail;

  /// No description provided for @discoveryTipEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'Search “subscription”, “receipt” or “renewal” in your inbox'**
  String get discoveryTipEmailDesc;

  /// No description provided for @discoveryTipAppStore.
  ///
  /// In en, this message translates to:
  /// **'App Store / Play Store'**
  String get discoveryTipAppStore;

  /// No description provided for @discoveryTipAppStoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Settings → Subscriptions shows all active app subscriptions'**
  String get discoveryTipAppStoreDesc;

  /// No description provided for @discoveryTipPaypal.
  ///
  /// In en, this message translates to:
  /// **'PayPal & payment apps'**
  String get discoveryTipPaypal;

  /// No description provided for @discoveryTipPaypalDesc.
  ///
  /// In en, this message translates to:
  /// **'Check automatic payments in PayPal, Revolut or your payment app'**
  String get discoveryTipPaypalDesc;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get sectionAccount;

  /// No description provided for @accountAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get accountAnonymous;

  /// No description provided for @accountBackupPrompt.
  ///
  /// In en, this message translates to:
  /// **'Back up your data'**
  String get accountBackupPrompt;

  /// No description provided for @accountBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Backed up'**
  String get accountBackedUp;

  /// No description provided for @accountSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String accountSignedInAs(String email);

  /// No description provided for @syncStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncStatusSyncing;

  /// No description provided for @syncStatusSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncStatusSynced;

  /// No description provided for @syncStatusLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync: {time}'**
  String syncStatusLastSync(String time);

  /// No description provided for @syncStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get syncStatusOffline;

  /// No description provided for @syncStatusNeverSynced.
  ///
  /// In en, this message translates to:
  /// **'Not yet synced'**
  String get syncStatusNeverSynced;

  /// No description provided for @signInToBackUp.
  ///
  /// In en, this message translates to:
  /// **'Sign in to back up your data'**
  String get signInToBackUp;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get signInWithEmail;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out? Your data will stay on this device.'**
  String get signOutConfirm;

  /// No description provided for @annualSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SWITCH TO ANNUAL'**
  String get annualSavingsTitle;

  /// No description provided for @annualSavingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'potential savings by switching to yearly plans'**
  String get annualSavingsSubtitle;

  /// No description provided for @annualSavingsCoverage.
  ///
  /// In en, this message translates to:
  /// **'Based on {matched} of {total} subscriptions'**
  String annualSavingsCoverage(int matched, int total);

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @allSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Annual Savings'**
  String get allSavingsTitle;

  /// No description provided for @allSavingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch these monthly plans to yearly to save'**
  String get allSavingsSubtitle;

  /// No description provided for @annualPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'ANNUAL PLAN'**
  String get annualPlanLabel;

  /// No description provided for @annualPlanAvailable.
  ///
  /// In en, this message translates to:
  /// **'Annual plan available — save {amount}/yr'**
  String annualPlanAvailable(String amount);

  /// No description provided for @noAnnualPlan.
  ///
  /// In en, this message translates to:
  /// **'No annual plan available for this service'**
  String get noAnnualPlan;

  /// No description provided for @monthlyVsAnnual.
  ///
  /// In en, this message translates to:
  /// **'{monthly}/mo → {annual}/yr'**
  String monthlyVsAnnual(String monthly, String annual);

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/yr'**
  String get perYear;

  /// No description provided for @insightDidYouKnow.
  ///
  /// In en, this message translates to:
  /// **'DID YOU KNOW?'**
  String get insightDidYouKnow;

  /// No description provided for @insightSaveMoney.
  ///
  /// In en, this message translates to:
  /// **'SAVE MONEY'**
  String get insightSaveMoney;

  /// No description provided for @insightLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get insightLearnMore;

  /// No description provided for @insightUnlockPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Pro'**
  String get insightUnlockPro;

  /// No description provided for @insightProTeaser.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro to get personalised savings tips.'**
  String get insightProTeaser;

  /// No description provided for @insightProTeaserTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalised savings tips'**
  String get insightProTeaserTitle;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'pl':
      return SPl();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
