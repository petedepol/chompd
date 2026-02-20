// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SDe extends S {
  SDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Chompd';

  @override
  String get tagline => 'Scannen. Tracken. Zurückbeißen.';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get done => 'Fertig';

  @override
  String get keep => 'Behalten';

  @override
  String get skip => 'Überspringen';

  @override
  String get next => 'Weiter';

  @override
  String get share => 'Teilen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get other => 'Sonstiges';

  @override
  String get close => 'Schließen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get pro => 'Pro';

  @override
  String get free => 'Kostenlos';

  @override
  String get tierTrial => 'Testphase';

  @override
  String get onboardingTitle1 => 'Beiß bei Abos zurück';

  @override
  String get onboardingSubtitle1 =>
      'Chompd trackt jedes Abo, entdeckt versteckte Fallen und hilft dir, Unnötiges zu kündigen.';

  @override
  String onboardingStatWaste(String amount) {
    return 'Durchschnittlich werden $amount/Jahr für vergessene Abos verschwendet';
  }

  @override
  String get onboardingEaseTag => 'Kein Tippen. Einfach knipsen und tracken.';

  @override
  String get onboardingTitle2 => 'So funktioniert\'s';

  @override
  String get onboardingStep1Title => 'Mach einen Screenshot';

  @override
  String get onboardingStep1Subtitle => 'Quittung, E-Mail oder Kontoauszug';

  @override
  String get onboardingStep2Title => 'KI liest ihn sofort';

  @override
  String get onboardingStep2Subtitle =>
      'Preis, Verlängerungsdatum und versteckte Fallen';

  @override
  String get onboardingStep3Title => 'Fertig. Für immer getrackt.';

  @override
  String get onboardingStep3Subtitle =>
      'Wir erinnern dich, bevor du belastet wirst';

  @override
  String get onboardingTitle3 => 'Verlängerungen voraus';

  @override
  String get onboardingSubtitle3 =>
      'Wir erinnern dich, bevor du belastet wirst — keine Überraschungen.';

  @override
  String get onboardingNotifMorning => 'Am Morgen der Verlängerung';

  @override
  String get onboardingNotif7days => '7 Tage vorher';

  @override
  String get onboardingNotifTrial => 'Testabo-Ablaufbenachrichtigung';

  @override
  String get allowNotifications => 'Benachrichtigungen erlauben';

  @override
  String get maybeLater => 'Vielleicht später';

  @override
  String get onboardingTitle4 => 'Füge dein erstes Abo hinzu';

  @override
  String get onboardingSubtitle4 =>
      'Die meisten finden vergessene Abos beim ersten Scan. Lass uns sehen, was dein Geld frisst.';

  @override
  String get scanAScreenshot => 'Screenshot scannen';

  @override
  String get scanHintTooltip => 'Tippe mich zum Scannen!';

  @override
  String get addManually => 'Manuell hinzufügen';

  @override
  String get skipForNow => 'Erst mal überspringen';

  @override
  String homeStatusLine(int active, int cancelled) {
    return '$active aktiv · $cancelled gekündigt';
  }

  @override
  String get overBudgetMood => 'Autsch. Das ist ganz schön viel.';

  @override
  String get underBudgetMood => 'Sieht gut aus! Deutlich unter Budget.';

  @override
  String get sectionActiveSubscriptions => 'AKTIVE ABOS';

  @override
  String get sectionCancelledSaved => 'GEKÜNDIGT — GESPART';

  @override
  String get sectionMilestones => 'MEILENSTEINE';

  @override
  String get sectionYearlyBurn => 'JÄHRLICHE KOSTEN';

  @override
  String get sectionMonthlyBurn => 'MONATLICHE KOSTEN';

  @override
  String get sectionSavedWithChompd => 'MIT CHOMPD GESPART';

  @override
  String perYearAcrossSubs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos',
      one: '1 Abo',
    );
    return 'pro Jahr für $_temp0';
  }

  @override
  String perMonthAcrossSubs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos',
      one: '1 Abo',
    );
    return 'pro Monat für $_temp0';
  }

  @override
  String get monthlyAvg => 'mtl. Durchschnitt';

  @override
  String get yearlyTotal => 'jährlich gesamt';

  @override
  String get dailyCost => 'Tageskosten';

  @override
  String fromCancelled(int count) {
    return 'aus $count gekündigten';
  }

  @override
  String get deleteSubscriptionTitle => 'Abo löschen?';

  @override
  String deleteSubscriptionMessage(String name) {
    return '$name endgültig entfernen?';
  }

  @override
  String cancelledMonthsAgo(int months) {
    return 'Vor $months Mon. gekündigt';
  }

  @override
  String get justCancelled => 'Gerade gekündigt';

  @override
  String get subsLeft => 'Abos übrig';

  @override
  String get scansLeft => 'Scans übrig';

  @override
  String get aiScanScreenshot => 'KI-Scan Screenshot';

  @override
  String get aiScanUpgradeToPro => 'KI-Scan (Upgrade auf Pro)';

  @override
  String get quickAddManual => 'Schnell hinzufügen / Manuell';

  @override
  String get addSubUpgradeToPro => 'Abo hinzufügen (Upgrade auf Pro)';

  @override
  String trialsExpiringSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Testabos laufen bald ab',
      one: '1 Testabo läuft bald ab',
    );
    return '$_temp0';
  }

  @override
  String trialDaysLeft(String names, int days) {
    return '$names — noch $days Tage';
  }

  @override
  String get proInfinity => 'PRO ∞';

  @override
  String scansLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Scans übrig',
      one: '1 Scan übrig',
    );
    return '$_temp0';
  }

  @override
  String get scanTitle => 'KI-Scan';

  @override
  String get scanAnalysing => 'Nom nom... kaue deinen Screenshot durch 🐟';

  @override
  String get scanIdleTitle => 'Screenshot scannen';

  @override
  String get scanIdleSubtitle =>
      'Teile einen Screenshot einer Bestätigungs-E-Mail,\neines Kontoauszugs oder einer App-Store-Quittung.';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromGallery => 'Aus Galerie wählen';

  @override
  String get cameraPermError => 'Kein Kamerazugriff. Prüfe die Berechtigungen.';

  @override
  String get galleryPermError =>
      'Kein Zugriff auf Fotos. Prüfe die Berechtigungen.';

  @override
  String get pasteEmailText => 'E-Mail-Text einfügen';

  @override
  String get pasteTextHint =>
      'Füge deinen Abo-E-Mail- oder Bestätigungstext hier ein...';

  @override
  String get scanText => 'Text scannen';

  @override
  String get textReceived => 'Nom nom... kaue deinen Text durch 🐟';

  @override
  String get smartMove => 'Cleverer Zug!';

  @override
  String youSkipped(String service) {
    return 'Du hast $service übersprungen';
  }

  @override
  String get saved => 'GESPART';

  @override
  String get addedToUnchompd => 'Zu deinem Unchompd-Konto hinzugefügt';

  @override
  String get analysing => 'Fast fertig... noch ein letzter Biss';

  @override
  String get scanSniffing => 'Spüre versteckte Kosten auf...';

  @override
  String get scanFoundFeast =>
      'Ein Festmahl gefunden! Fresse mich durch alles...';

  @override
  String get scanEscalation => 'Rufe einen größeren Fisch zur Hilfe... 🦈';

  @override
  String get scanAlmostDone => 'Fast fertig... noch ein letzter Biss';

  @override
  String scanFoundCount(int count) {
    return '$count Abonnements gefunden';
  }

  @override
  String get scanTapToExpand => 'Tippe zum Aufklappen und Bearbeiten';

  @override
  String get scanCancelledHint =>
      'Einige Abonnements wurden bereits gekündigt und laufen bald aus — wir haben sie für dich abgewählt.';

  @override
  String get scanAlreadyCancelled => 'Bereits gekündigt';

  @override
  String get scanExpires => 'Läuft aus';

  @override
  String get scanSkipAll => 'Alle überspringen';

  @override
  String scanAddSelected(int count) {
    return '+ $count ausgewählte hinzufügen';
  }

  @override
  String get confidence => 'Sicherheit';

  @override
  String get typeYourAnswer => 'Antwort eingeben...';

  @override
  String get addToChompd => 'Zu Chompd hinzufügen';

  @override
  String get monthlyTotal => 'Monatlich gesamt';

  @override
  String addAllToChompd(int count) {
    return 'Alle $count zu Chompd hinzufügen';
  }

  @override
  String get autoTier => 'AUTO';

  @override
  String yesIts(String option) {
    return 'Ja, es ist $option';
  }

  @override
  String get otherAmount => 'Anderer Betrag';

  @override
  String get trapDetected => 'FALLE ERKANNT';

  @override
  String trapOfferActually(String name) {
    return 'Dieses „$name“-Angebot ist tatsächlich:';
  }

  @override
  String skipItSave(String amount) {
    return 'ÜBERSPRINGEN — $amount SPAREN';
  }

  @override
  String get trackTrialAnyway => 'Testabo trotzdem tracken';

  @override
  String get trapReminder => 'Wir erinnern dich, bevor du belastet wirst';

  @override
  String get editSubscription => 'Abo bearbeiten';

  @override
  String get addSubscription => 'Abo hinzufügen';

  @override
  String get fieldServiceName => 'DIENSTNAME';

  @override
  String get hintServiceName => 'z.B. Netflix, Spotify';

  @override
  String get errorNameRequired => 'Name erforderlich';

  @override
  String get fieldPrice => 'PREIS';

  @override
  String get hintPrice => '9,99';

  @override
  String get errorPriceRequired => 'Preis erforderlich';

  @override
  String get errorInvalidPrice => 'Ungültiger Preis';

  @override
  String get fieldCurrency => 'WÄHRUNG';

  @override
  String get fieldBillingCycle => 'ABRECHNUNGSZYKLUS';

  @override
  String get fieldCategory => 'KATEGORIE';

  @override
  String get fieldNextRenewal => 'NÄCHSTE VERLÄNGERUNG';

  @override
  String get selectDate => 'Datum wählen';

  @override
  String get freeTrialToggle => 'Das ist ein kostenloses Testabo';

  @override
  String get trialDurationLabel => 'Testdauer';

  @override
  String get trialDays7 => '7 Tage';

  @override
  String get trialDays14 => '14 Tage';

  @override
  String get trialDays30 => '30 Tage';

  @override
  String trialCustomDays(int days) {
    return '${days}T';
  }

  @override
  String get fieldTrialEnds => 'TESTABO ENDET';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get subscriptionDetail => 'Abo-Details';

  @override
  String thatsPerYear(String amount) {
    return 'Das sind $amount pro Jahr';
  }

  @override
  String overThreeYears(String amount) {
    return '$amount über 3 Jahre';
  }

  @override
  String trialDaysRemaining(int days) {
    return '⚠️ Testabo — noch $days Tage';
  }

  @override
  String get trialExpired => '⚠️ Testabo abgelaufen';

  @override
  String get nextRenewal => 'NÄCHSTE VERLÄNGERUNG';

  @override
  String chargesToday(String price) {
    return '$price wird heute belastet';
  }

  @override
  String chargesTomorrow(String price) {
    return '$price wird morgen belastet';
  }

  @override
  String chargesSoon(int days, String price) {
    return '$days Tage — $price bald fällig';
  }

  @override
  String daysCount(int days) {
    return '$days Tage';
  }

  @override
  String get sectionReminders => 'ERINNERUNGEN';

  @override
  String remindersScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Erinnerungen geplant',
      one: '1 Erinnerung geplant',
    );
    return '$_temp0';
  }

  @override
  String get reminderDaysBefore7 => '7 Tage vorher';

  @override
  String get reminderDaysBefore3 => '3 Tage vorher';

  @override
  String get reminderDaysBefore1 => '1 Tag vorher';

  @override
  String get reminderMorningOf => 'Am Morgen';

  @override
  String get upgradeForReminders => 'Upgrade auf Pro für frühere Erinnerungen';

  @override
  String get sectionPaymentHistory => 'ZAHLUNGSVERLAUF';

  @override
  String get totalPaid => 'Insgesamt bezahlt';

  @override
  String noPaymentsYet(String date) {
    return 'Noch keine Zahlungen — hinzugefügt am $date';
  }

  @override
  String get upcoming => 'Bevorstehend';

  @override
  String get sectionDetails => 'DETAILS';

  @override
  String get detailCategory => 'Kategorie';

  @override
  String get detailCurrency => 'Währung';

  @override
  String get detailBillingCycle => 'Abrechnungszyklus';

  @override
  String get detailAdded => 'Hinzugefügt';

  @override
  String addedVia(String date, String source) {
    return '$date via $source';
  }

  @override
  String get sourceAiScan => 'KI-Scan';

  @override
  String get sourceQuickAdd => 'Schnell hinzufügen';

  @override
  String get sourceManual => 'Manuell';

  @override
  String get cancelSubscription => 'Abo kündigen';

  @override
  String cancelSubscriptionConfirm(String name) {
    return '$name kündigen?';
  }

  @override
  String cancelPlatformPickerTitle(String name) {
    return 'Wie bezahlst du für $name?';
  }

  @override
  String get cancelPlatformIos => 'Apple App Store';

  @override
  String get cancelPlatformAndroid => 'Google Play';

  @override
  String get cancelPlatformWeb => 'Webseite / Direkt';

  @override
  String get cancelPlatformNotSure => 'Nicht sicher';

  @override
  String get difficultyEasy => 'Einfach — unkompliziert';

  @override
  String get difficultyModerate => 'Moderat — ein paar Schritte nötig';

  @override
  String get difficultyMedium => 'Mittel — dauert ein paar Minuten';

  @override
  String get difficultyHard => 'Schwer — absichtlich erschwert';

  @override
  String get difficultyVeryHard => 'Sehr schwer — viele Bindungsschritte';

  @override
  String get requestRefund => 'Rückerstattung anfordern';

  @override
  String deleteNameTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get deleteNameMessage =>
      'Dieses Abo wird dauerhaft gelöscht. Das kann nicht rückgängig gemacht werden.';

  @override
  String noGuideYet(String name) {
    return 'Noch keine Anleitung für $name. Suche nach \"$name Abo kündigen\" im Internet.';
  }

  @override
  String realAnnualCost(String amount) {
    return 'Echte Jahreskosten: $amount/Jahr';
  }

  @override
  String trialExpires(String date) {
    return 'Testabo endet $date';
  }

  @override
  String get chompdPro => 'Chompd Pro';

  @override
  String get paywallTagline => 'Ein Abo-Tracker, der kein Abo ist.';

  @override
  String paywallLimitSubs(int count) {
    return 'Du hast das Gratis-Limit von $count Abos erreicht.';
  }

  @override
  String paywallLimitScans(int count) {
    return 'Du hast alle $count kostenlosen KI-Scans verbraucht.';
  }

  @override
  String get paywallLimitReminders =>
      'Vorab-Erinnerungen sind ein Pro-Feature.';

  @override
  String get paywallGeneric => 'Schalte das volle Chompd-Erlebnis frei.';

  @override
  String get paywallFeature1 =>
      '100–500/Jahr an versteckter Verschwendung sparen';

  @override
  String get paywallFeature2 => 'Nie wieder ein Testabo verpassen';

  @override
  String get paywallFeature3 => 'Unbegrenztes KI-Fallen-Scanning';

  @override
  String get paywallFeature4 => 'Jedes Abo tracken';

  @override
  String get paywallFeature5 => 'Frühwarnung: 7, 3, 1 Tag vor Belastung';

  @override
  String get paywallFeature6 => 'Teilbare Spar-Karten';

  @override
  String get paywallContext =>
      'Zahlt sich nach dem Kündigen eines vergessenen Abos aus.';

  @override
  String get oneTimePayment => 'Einmalzahlung. Für immer.';

  @override
  String get lifetime => 'LEBENSLANG';

  @override
  String get unlockChompdPro => 'Chompd Pro freischalten';

  @override
  String get restoring => 'Wird wiederhergestellt...';

  @override
  String get restorePurchase => 'Kauf wiederherstellen';

  @override
  String get purchaseError => 'Kauf fehlgeschlagen. Versuche es erneut.';

  @override
  String get noPreviousPurchase => 'Kein früherer Kauf gefunden.';

  @override
  String get renewalCalendar => 'Verlängerungskalender';

  @override
  String get today => 'HEUTE';

  @override
  String get noRenewalsThisDay => 'Keine Verlängerungen an diesem Tag';

  @override
  String get thisMonth => 'DIESER MONAT';

  @override
  String get renewals => 'Verlängerungen';

  @override
  String get total => 'Gesamt';

  @override
  String renewalsOnDay(int count, String date, String price) {
    return '$count Verlängerungen am $date insgesamt $price';
  }

  @override
  String biggestDay(String date, String price) {
    return 'Teuerster Tag: $date — $price';
  }

  @override
  String get tapDayToSee => 'Tippe auf einen Tag, um Verlängerungen zu sehen';

  @override
  String cancelGuideTitle(String name) {
    return '$name kündigen';
  }

  @override
  String get whyCancelling => 'Warum kündigst du?';

  @override
  String get whyCancellingHint =>
      'Kurz tippen — hilft uns, Chompd zu verbessern.';

  @override
  String get reasonTooExpensive => 'Zu teuer';

  @override
  String get reasonDontUse => 'Nutze ich nicht genug';

  @override
  String get reasonBreak => 'Mache eine Pause';

  @override
  String get reasonSwitching => 'Wechsle zu etwas anderem';

  @override
  String get difficultyLevel => 'Schwierigkeitsgrad';

  @override
  String get cancellationSteps => 'Kündigungsschritte';

  @override
  String stepNumber(int number) {
    return 'SCHRITT $number';
  }

  @override
  String get openCancelPage => 'Kündigungsseite öffnen';

  @override
  String get iveCancelled => 'Ich habe gekündigt';

  @override
  String get couldntCancelRefund =>
      'Kündigung nicht möglich? Hilfe bei Rückerstattung →';

  @override
  String get refundTipTitle => 'Tipp: Warum eine Rückerstattung beantragen?';

  @override
  String get refundTipBody =>
      'Wenn du unerwartet belastet wurdest, dich versehentlich angemeldet hast oder der Dienst nicht wie versprochen funktioniert hat — hast du möglicherweise Anspruch auf eine Rückerstattung. Je früher du anfragst, desto besser.';

  @override
  String get refundRescue => 'Rückerstattungshilfe';

  @override
  String get refundIntro =>
      'Keine Sorge — die meisten bekommen ihr Geld zurück. Lass uns das regeln.';

  @override
  String chargedYou(String name, String price) {
    return '$name hat dir $price belastet';
  }

  @override
  String get howCharged => 'WIE WURDEST DU BELASTET?';

  @override
  String successRate(String rate) {
    return 'Erfolgsquote: $rate';
  }

  @override
  String get copyDisputeEmail => 'Widerspruchs-E-Mail kopieren';

  @override
  String get openRefundPage => 'Rückerstattungsseite öffnen';

  @override
  String get iveSubmittedRequest => 'Antrag eingereicht';

  @override
  String get requestSubmitted => 'Antrag eingereicht!';

  @override
  String get requestSubmittedMessage =>
      'Wir haben deinen Rückerstattungsantrag gespeichert. Prüfe dein Postfach.';

  @override
  String get emailCopied => 'E-Mail in Zwischenablage kopiert';

  @override
  String refundWindowDays(String days) {
    return '$days-Tage-Erstattungsfenster';
  }

  @override
  String avgRefundDays(String days) {
    return '~$days Tage Ø';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get themeTitle => 'DESIGN';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get sectionNotifications => 'BENACHRICHTIGUNGEN';

  @override
  String remindersScheduledSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Erinnerungen geplant',
      one: '1 Erinnerung geplant',
    );
    return '$_temp0';
  }

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get pushNotificationsSubtitle =>
      'Erinnerungen an Verlängerungen und Testabos';

  @override
  String get morningDigest => 'Morgenzusammenfassung';

  @override
  String morningDigestSubtitle(String time) {
    return 'Tägliche Zusammenfassung um $time';
  }

  @override
  String get renewalReminders => 'Verlängerungserinnerungen';

  @override
  String get trialExpiryAlerts => 'Testabo-Ablaufbenachrichtigungen';

  @override
  String get trialExpirySubtitle =>
      'Warnt 3 Tage, 1 Tag und am Tag des Ablaufs';

  @override
  String get sectionReminderSchedule => 'ERINNERUNGSPLAN';

  @override
  String get sectionUpcoming => 'BEVORSTEHEND';

  @override
  String get noUpcomingNotifications =>
      'Keine bevorstehenden Benachrichtigungen';

  @override
  String get sectionChompdPro => 'CHOMPD PRO';

  @override
  String get sectionCurrency => 'WÄHRUNG';

  @override
  String get displayCurrency => 'Anzeigewährung';

  @override
  String get sectionMonthlyBudget => 'MONATSBUDGET';

  @override
  String get monthlySpendingTarget => 'Monatliches Ausgabenziel';

  @override
  String get budgetHint => 'Wird für den Ausgabenring im Dashboard verwendet';

  @override
  String get sectionHapticFeedback => 'HAPTISCHES FEEDBACK';

  @override
  String get hapticFeedback => 'Haptisches Feedback';

  @override
  String get hapticSubtitle =>
      'Vibrationen bei Tippen, Umschalten und Erfolgen';

  @override
  String get sectionDataExport => 'DATENEXPORT';

  @override
  String get exportToCsv => 'Als CSV exportieren';

  @override
  String get exportHint => 'Alle Abos als Tabelle herunterladen';

  @override
  String exportSuccess(int count) {
    return '$count Abos als CSV exportiert';
  }

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get sectionAbout => 'ÜBER';

  @override
  String get version => 'Version';

  @override
  String get tier => 'Tarif';

  @override
  String get aiModel => 'KI-Modell';

  @override
  String get aiModelValue => 'Claude Haiku 4.5';

  @override
  String get setBudgetTitle => 'Monatsbudget festlegen';

  @override
  String get setBudgetSubtitle => 'Gib dein monatliches Abo-Ausgabenziel ein.';

  @override
  String get reminderSubtitleMorningOnly =>
      'Nur am Morgen des Tages (Upgrade für mehr)';

  @override
  String reminderSubtitleDays(String schedule) {
    return '$schedule vor Verlängerung';
  }

  @override
  String get dayOf => 'Am Tag';

  @override
  String get oneDay => '1 Tag';

  @override
  String nDays(int days) {
    return '$days Tage';
  }

  @override
  String get timelineLabel7d => '7T';

  @override
  String get timelineLabel3d => '3T';

  @override
  String get timelineLabel1d => '1T';

  @override
  String get timelineLabelDayOf => 'Am Tag';

  @override
  String get upgradeProReminders =>
      'Upgrade auf Pro für 7T, 3T und 1T Erinnerungen';

  @override
  String proPrice(String price) {
    return '£$price';
  }

  @override
  String oneTimePaymentShort(String price) {
    return '$price • Einmalzahlung';
  }

  @override
  String get sectionLanguage => 'SPRACHE';

  @override
  String get severityHigh => 'HOHES RISIKO';

  @override
  String get severityCaution => 'VORSICHT';

  @override
  String get severityInfo => 'INFO';

  @override
  String get trapTypeTrialBait => 'Testabo-Köder';

  @override
  String get trapTypePriceFraming => 'Preistäuschung';

  @override
  String get trapTypeHiddenRenewal => 'Versteckte Verlängerung';

  @override
  String get trapTypeCancelFriction => 'Kündigungshürde';

  @override
  String get trapTypeGeneric => 'Abo-Falle';

  @override
  String get severityExplainHigh =>
      'Extremer Preisanstieg oder täuschende Darstellung';

  @override
  String get severityExplainMedium => 'Einführungspreis steigt deutlich';

  @override
  String get severityExplainLow => 'Standard-Testabo mit Auto-Verlängerung';

  @override
  String trialBadge(int days) {
    return '${days}T Test';
  }

  @override
  String introBadge(int days) {
    return '${days}T Aktion';
  }

  @override
  String get emptyNoSubscriptions => 'Noch keine Abos';

  @override
  String get emptyNoSubscriptionsHint =>
      'Scanne einen Screenshot oder tippe + zum Starten.';

  @override
  String get emptyNoTrials => 'Keine aktiven Testabos';

  @override
  String get emptyNoTrialsHint =>
      'Wenn du Testabos hinzufügst,\nerscheinen sie hier mit Countdown-Alerts.';

  @override
  String get emptyNoSavings => 'Noch keine Ersparnisse';

  @override
  String get emptyNoSavingsHint =>
      'Kündige ungenutzte Abos und\nsieh zu, wie deine Ersparnisse wachsen.';

  @override
  String get nudgeReview => 'Prüfen';

  @override
  String get nudgeKeepIt => 'Behalten';

  @override
  String get trialLabel => 'TEST';

  @override
  String get priceToday => 'HEUTE';

  @override
  String get priceNow => 'JETZT';

  @override
  String get priceThen => 'DANACH';

  @override
  String get priceRenewsAt => 'VERLÄNGERT SICH ZU';

  @override
  String dayTrial(String days) {
    return '$days-Tage-Test';
  }

  @override
  String monthIntro(String months) {
    return '$months-Monats-Angebot';
  }

  @override
  String realCostFirstYear(String amount) {
    return 'Echte Kosten im 1. Jahr: $amount';
  }

  @override
  String get milestoneCoffeeFund => 'Kaffeekasse';

  @override
  String get milestoneGamePass => 'Game Pass';

  @override
  String get milestoneWeekendAway => 'Wochenendtrip';

  @override
  String get milestoneNewGadget => 'Neues Gadget';

  @override
  String get milestoneDreamHoliday => 'Traumurlaub';

  @override
  String get milestoneFirstBiteBack => 'Erster Gegenbiss';

  @override
  String get milestoneChompSpotter => 'Chomp-Entdecker';

  @override
  String get milestoneDarkPatternDestroyer => 'Dark-Pattern-Zerstörer';

  @override
  String get milestoneSubscriptionSentinel => 'Abo-Wächter';

  @override
  String get milestoneUnchompable => 'Unchompable';

  @override
  String get milestoneReached => '✓ Erreicht!';

  @override
  String milestoneToGo(String amount) {
    return 'noch $amount';
  }

  @override
  String get celebrationTitle => 'Super! 🎉';

  @override
  String celebrationSavePerYear(String amount) {
    return 'Du sparst $amount/Jahr';
  }

  @override
  String celebrationByDropping(String name) {
    return 'durch Kündigung von $name';
  }

  @override
  String get tapAnywhereToContinue => 'Tippe irgendwo um fortzufahren';

  @override
  String get trapBadge => 'FALLE';

  @override
  String trapDays(int days) {
    return '${days}T Falle';
  }

  @override
  String get unchompd => 'Unchompd';

  @override
  String get fromSubscriptionTraps => 'aus Abo-Fallen';

  @override
  String trapsDodged(int count) {
    return '$count vermieden';
  }

  @override
  String trialsCancelled(int count) {
    return '$count gekündigt';
  }

  @override
  String refundsRecovered(int count) {
    return '$count erstattet';
  }

  @override
  String get ringYearly => 'JÄHRLICH';

  @override
  String get ringMonthly => 'MONATLICH';

  @override
  String overBudget(String amount) {
    return '$amount über Budget';
  }

  @override
  String ofBudget(String amount) {
    return 'von $amount Budget';
  }

  @override
  String get tapForMonthly => 'Tippe für monatlich';

  @override
  String get tapForYearly => 'Tippe für jährlich';

  @override
  String budgetRange(String min, String max) {
    return 'Budget: $min – $max';
  }

  @override
  String get addSubscriptionSheet => 'Abo hinzufügen';

  @override
  String get orChooseService => 'oder wähle einen Dienst';

  @override
  String get searchServices => 'Dienste suchen...';

  @override
  String get priceField => 'Preis';

  @override
  String addServiceName(String name) {
    return '$name hinzufügen';
  }

  @override
  String get tapForMore => 'Tippe für mehr';

  @override
  String shareYearlyBurn(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos',
      one: '1 Abo',
    );
    return 'Ich gebe $symbol$amount/Jahr für $_temp0 aus 😳';
  }

  @override
  String shareMonthlyDaily(String symbol, String monthly, String daily) {
    return 'Das sind $symbol$monthly/Monat oder $symbol$daily/Tag';
  }

  @override
  String shareSavedBy(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos',
      one: '1 Abo',
    );
    return '✓ $symbol$amount gespart durch Kündigung von $_temp0';
  }

  @override
  String get shareFooter =>
      'Getrackt mit Chompd — Scannen. Tracken. Zurückbeißen.';

  @override
  String shareSavings(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos',
      one: '1 Abo',
    );
    return 'Ich habe $symbol$amount gespart durch Kündigung von $_temp0 🎉\n\nBeiß bei Abos zurück — getchompd.com';
  }

  @override
  String get insightBigSpenderHeadline => 'Großer Posten';

  @override
  String insightBigSpenderMessage(String name, String amount) {
    return '$name kostet dich **$amount/Jahr**. Das ist dein teuerstes Abo.';
  }

  @override
  String get insightAnnualSavingsHeadline => 'Jährliche Ersparnisse';

  @override
  String insightAnnualSavingsMessage(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos',
      one: '1 Abo',
    );
    return 'Der Wechsel von **$_temp0** auf Jahresabrechnung könnte ~**$amount/Jahr** sparen.';
  }

  @override
  String get insightRealityCheckHeadline => 'Realitätscheck';

  @override
  String insightRealityCheckMessage(int count) {
    return 'Du hast **$count aktive Abos**. Der Durchschnitt liegt bei 12 — nutzt du sie alle?';
  }

  @override
  String get insightMoneySavedHeadline => 'Geld gespart';

  @override
  String insightMoneySavedMessage(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos',
      one: '1 Abo',
    );
    return 'Du hast **$amount** gespart seit der Kündigung von **$_temp0**. Gut gemacht!';
  }

  @override
  String get insightTrialEndingHeadline => 'Testabo endet';

  @override
  String insightTrialEndingMessage(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Testabos enden',
      one: 'Testabo endet',
    );
    return '**$names** — $_temp0 bald. Jetzt kündigen oder du wirst belastet.';
  }

  @override
  String get insightDailyCostHeadline => 'Tageskosten';

  @override
  String insightDailyCostMessage(String amount) {
    return 'Deine Abos kosten **$amount/Tag** — das ist ein edler Kaffee, jeden Tag.';
  }

  @override
  String notifRenewsToday(String name) {
    return '$name verlängert sich heute';
  }

  @override
  String notifRenewsTomorrow(String name) {
    return '$name verlängert sich morgen';
  }

  @override
  String notifRenewsInDays(String name, int days) {
    return '$name verlängert sich in $days Tagen';
  }

  @override
  String notifChargesToday(String price) {
    return 'Dir werden heute $price belastet. Tippe zum Prüfen oder Kündigen.';
  }

  @override
  String notifChargesTomorrow(String price) {
    return '$price wird morgen belastet. Willst du es behalten?';
  }

  @override
  String notifCharges3Days(String price) {
    return 'Verlängerung von $price in 3 Tagen.';
  }

  @override
  String notifChargesInDays(String price, int days) {
    return 'Verlängerung von $price in $days Tagen. Zeit zum Prüfen?';
  }

  @override
  String notifTrialEndsToday(String name) {
    return '⚠ $name-Testabo endet heute!';
  }

  @override
  String notifTrialEndsTomorrow(String name) {
    return '$name-Testabo endet morgen';
  }

  @override
  String notifTrialEndsInDays(String name, int days) {
    return '$name-Testabo endet in $days Tagen';
  }

  @override
  String notifTrialBodyToday(String price) {
    return 'Dein kostenloses Testabo endet heute! Dir werden $price belastet. Kündige jetzt, wenn du nicht weitermachen willst.';
  }

  @override
  String notifTrialBodyTomorrow(String price) {
    return 'Noch ein Tag Testabo. Danach kostet es $price. Jetzt kündigen, um Kosten zu vermeiden.';
  }

  @override
  String notifTrialBodyDays(int days, String price) {
    return 'Noch $days Tage Testabo. Danach kostet es $price.';
  }

  @override
  String notifTrapTrialTitle3d(String name) {
    return '$name-Testabo endet in 3 Tagen';
  }

  @override
  String notifTrapTrialBody3d(String price) {
    return 'Es werden automatisch $price belastet. Jetzt kündigen, wenn du es nicht willst.';
  }

  @override
  String notifTrapTrialTitleTomorrow(String name, String price) {
    return '⚠️ MORGEN: $name belastet $price';
  }

  @override
  String get notifTrapTrialBodyTomorrow =>
      'Jetzt kündigen, wenn du es nicht behalten willst.';

  @override
  String notifTrapTrialTitle2h(String name, String price) {
    return '🚨 $name belastet $price in 2 STUNDEN';
  }

  @override
  String get notifTrapTrialBody2h => 'Das ist deine letzte Chance zu kündigen.';

  @override
  String notifTrapPostCharge(String name) {
    return 'Wolltest du $name behalten?';
  }

  @override
  String notifTrapPostChargeBody(String price) {
    return 'Dir wurden $price belastet. Tippe, wenn du Hilfe bei der Rückerstattung brauchst.';
  }

  @override
  String notifDigestBoth(int renewalCount, int trialCount) {
    return '$renewalCount Verlängerung(en) + $trialCount Testabo(s) heute';
  }

  @override
  String notifDigestRenewals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos verlängern sich heute',
      one: '1 Abo verlängert sich heute',
    );
    return '$_temp0';
  }

  @override
  String notifDigestTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Testabos laufen heute ab',
      one: '1 Testabo läuft heute ab',
    );
    return '$_temp0';
  }

  @override
  String notifDigestRenewalBody(String names, String total) {
    return '$names — insgesamt $total';
  }

  @override
  String notifDigestTrialBody(String names) {
    return '$names — jetzt kündigen, um Kosten zu vermeiden';
  }

  @override
  String get cycleWeekly => 'Wöchentlich';

  @override
  String get cycleMonthly => 'Monatlich';

  @override
  String get cycleQuarterly => 'Vierteljährlich';

  @override
  String get cycleYearly => 'Jährlich';

  @override
  String get cycleWeeklyShort => 'Wo.';

  @override
  String get cycleMonthlyShort => 'Mo.';

  @override
  String get cycleQuarterlyShort => 'Vj.';

  @override
  String get cycleYearlyShort => 'Jr.';

  @override
  String scanFound(String details) {
    return 'Gefunden: $details';
  }

  @override
  String scanRenewsDate(String date) {
    return 'erneuert sich am $date';
  }

  @override
  String scanChargeFound(String price, String cycle) {
    return 'Zahlung gefunden: $price/$cycle.';
  }

  @override
  String scanWhichService(String name, String price, String cycle) {
    return 'Zahlung für $name gefunden: $price/$cycle. Welcher Dienst ist das?';
  }

  @override
  String scanBilledQuestion(String name) {
    return 'Wird $name monatlich oder jährlich abgerechnet?';
  }

  @override
  String scanMissingPrice(String name) {
    return 'Ich konnte den Preis nicht finden. Wie viel kostet $name?';
  }

  @override
  String get categoryStreaming => 'Streaming';

  @override
  String get categoryMusic => 'Musik';

  @override
  String get categoryAi => 'KI';

  @override
  String get categoryProductivity => 'Produktivität';

  @override
  String get categoryStorage => 'Speicher';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryGaming => 'Gaming';

  @override
  String get categoryReading => 'Lesen';

  @override
  String get categoryCommunication => 'Kommunikation';

  @override
  String get categoryNews => 'Nachrichten';

  @override
  String get categoryFinance => 'Finanzen';

  @override
  String get categoryEducation => 'Bildung';

  @override
  String get categoryVpn => 'VPN';

  @override
  String get categoryDeveloper => 'Entwickler';

  @override
  String get categoryBundle => 'Bundle';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get paymentsTrackedHint =>
      'Zahlungen werden nach jeder Verlängerung erfasst';

  @override
  String get renewsToday => 'Verlängert sich heute';

  @override
  String get renewsTomorrow => 'Verlängert sich morgen';

  @override
  String renewsInDays(int days) {
    return 'Verlängert sich in $days Tagen';
  }

  @override
  String renewsOnDate(String date) {
    return 'Verlängert sich am $date';
  }

  @override
  String get renewedYesterday => 'Gestern verlängert';

  @override
  String renewedDaysAgo(int days) {
    return 'Vor $days Tagen verlängert';
  }

  @override
  String get discoveryTipsTitle => 'Wo du Abos findest';

  @override
  String get discoveryTipBank => 'Kontoauszug';

  @override
  String get discoveryTipBankDesc =>
      'Mache einen Screenshot deiner Transaktionen — wir finden sie alle auf einmal';

  @override
  String get discoveryTipEmail => 'E-Mail-Suche';

  @override
  String get discoveryTipEmailDesc =>
      'Suche nach „Abonnement“, „Quittung“ oder „Verlängerung“ in deinem Postfach';

  @override
  String get discoveryTipAppStore => 'App Store / Play Store';

  @override
  String get discoveryTipAppStoreDesc =>
      'Einstellungen → Abonnements zeigt alle aktiven App-Abos';

  @override
  String get discoveryTipPaypal => 'PayPal & Zahlungs-Apps';

  @override
  String get discoveryTipPaypalDesc =>
      'Prüfe automatische Zahlungen in PayPal, Revolut oder deiner Zahlungs-App';

  @override
  String get sectionAccount => 'KONTO';

  @override
  String get accountAnonymous => 'Anonym';

  @override
  String get accountBackupPrompt => 'Sichere deine Daten';

  @override
  String get accountBackedUp => 'Gesichert';

  @override
  String accountSignedInAs(String email) {
    return 'Angemeldet als $email';
  }

  @override
  String get syncStatusSyncing => 'Synchronisiert...';

  @override
  String get syncStatusSynced => 'Synchronisiert';

  @override
  String syncStatusLastSync(String time) {
    return 'Letzte Sync: $time';
  }

  @override
  String get syncStatusOffline => 'Offline';

  @override
  String get syncStatusNeverSynced => 'Noch nicht synchronisiert';

  @override
  String get signInToBackUp => 'Melde dich an, um deine Daten zu sichern';

  @override
  String get signInWithApple => 'Mit Apple anmelden';

  @override
  String get signInWithGoogle => 'Mit Google anmelden';

  @override
  String get signInWithEmail => 'Mit E-Mail anmelden';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signOutConfirm =>
      'Möchtest du dich wirklich abmelden? Deine Daten bleiben auf diesem Gerät.';

  @override
  String get annualSavingsTitle => 'AUF JÄHRLICH WECHSELN';

  @override
  String get annualSavingsSubtitle => 'mögliche Ersparnisse durch Jahrespläne';

  @override
  String annualSavingsCoverage(int matched, int total) {
    return 'Basierend auf $matched von $total Abos';
  }

  @override
  String annualSavingsHint(String name) {
    return 'Schau in deinen $name-Kontoeinstellungen nach Jahresabo-Optionen';
  }

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get allSavingsTitle => 'Jährliche Ersparnisse';

  @override
  String get allSavingsSubtitle =>
      'Wechsle diese Monatspläne zu Jahresplänen und spare';

  @override
  String get annualPlanLabel => 'JAHRESPLAN';

  @override
  String annualPlanAvailable(String amount) {
    return 'Jahresplan verfügbar — spare $amount/Jahr';
  }

  @override
  String get noAnnualPlan => 'Kein Jahresplan für diesen Dienst verfügbar';

  @override
  String monthlyVsAnnual(String monthly, String annual) {
    return '$monthly/Mo. → $annual/Jahr';
  }

  @override
  String get perYear => '/Jahr';

  @override
  String get insightDidYouKnow => 'WUSSTEST DU?';

  @override
  String get insightSaveMoney => 'GELD SPAREN';

  @override
  String get insightLearnMore => 'Mehr erfahren';

  @override
  String get insightProLabel => 'PRO-EINBLICK';

  @override
  String get insightUnlockPro => 'Mit Pro freischalten';

  @override
  String get insightProTeaser =>
      'Upgrade auf Pro für personalisierte Spartipps.';

  @override
  String get insightProTeaserTitle => 'Personalisierte Spartipps';

  @override
  String trialBannerDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage übrig',
      one: '1 Tag übrig',
    );
    return 'Pro-Test · $_temp0';
  }

  @override
  String get trialBannerExpired => 'Pro-Test abgelaufen';

  @override
  String get trialBannerUpgrade => 'Upgrade';

  @override
  String get trialPromptTitle => '7 Tage alles kostenlos testen';

  @override
  String get trialPromptSubtitle =>
      'Voller Pro-Zugang — unverbindlich, ohne Zahlung.';

  @override
  String get trialPromptFeature1 => 'Unbegrenzte Abos';

  @override
  String get trialPromptFeature2 => 'KI-Fallenscanner — unbegrenzte Scans';

  @override
  String get trialPromptFeature3 => 'Vorab-Erinnerungen (7T, 3T, 1T)';

  @override
  String get trialPromptFeature4 => 'Ausgaben-Dashboard & Einblicke';

  @override
  String get trialPromptFeature5 =>
      'Kündigungsanleitungen & Rückerstattungstipps';

  @override
  String get trialPromptFeature6 => 'Smarte Hinweise & Spar-Karten';

  @override
  String get trialPromptLegal =>
      'Nach 7 Tagen: bis zu 3 Abos gratis tracken, oder alles für £4.99 freischalten — einmalig, für immer.';

  @override
  String get trialPromptCta => 'Gratis-Test starten';

  @override
  String get trialPromptDismiss => 'Erst mal überspringen';

  @override
  String get trialExpiredTitle => 'Dein 7-Tage-Test ist abgelaufen';

  @override
  String trialExpiredSubtitle(int count, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos',
      one: '1 Abo',
    );
    return 'Du hast $_temp0 im Wert von $price/Monat getrackt.';
  }

  @override
  String trialExpiredFrozen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos sind jetzt eingefroren',
      one: '1 Abo ist jetzt eingefroren',
    );
    return '$_temp0';
  }

  @override
  String get trialExpiredCta => 'Chompd Pro freischalten — £4.99';

  @override
  String get trialExpiredDismiss => 'Mit Gratis-Version fortfahren';

  @override
  String get frozenSectionHeader => 'EINGEFROREN — UPGRADE ZUM ENTSPERREN';

  @override
  String get frozenBadge => 'EINGEFROREN';

  @override
  String get frozenTapToUpgrade => 'Tippe zum Upgraden';

  @override
  String cancelledStatusExpires(String date) {
    return 'Gekündigt — läuft ab am $date';
  }

  @override
  String cancelledStatusExpired(String date) {
    return 'Gekündigt — abgelaufen am $date';
  }

  @override
  String get reactivateSubscription => 'Abo reaktivieren';

  @override
  String get scanErrorGeneric =>
      'Dieses Bild konnte nicht gelesen werden. Versuche einen anderen Screenshot.';

  @override
  String get scanErrorEmpty =>
      'Bilddatei scheint leer zu sein. Versuche es erneut.';

  @override
  String scanServiceFound(String name) {
    return '$name gefunden!';
  }

  @override
  String get scanNoSubscriptionsFound =>
      'Keine Abonnements in diesem Bild gefunden. Versuche einen Beleg, eine Bestätigungs-E-Mail oder einen App-Store-Screenshot.';

  @override
  String scanRecurringCharge(String name) {
    return 'Wiederkehrende Gebühr gefunden, die wie $name aussieht.';
  }

  @override
  String scanConfirmQuestion(String pct, String name) {
    return '$pct% der Nutzer mit dieser Gebühr sagen, es ist $name. Stimmt das?';
  }

  @override
  String scanPersonalOrTeam(String name) {
    return 'Das sieht nach $name aus. Persönliches Abo oder Team-/Business-Plan?';
  }

  @override
  String get scanPersonal => 'Persönlich';

  @override
  String get scanTeamBusiness => 'Team / Business';

  @override
  String get scanNotSure => 'Nicht sicher';

  @override
  String scanAllDoneAdded(String added, String total) {
    return 'Fertig! $added von $total Abonnements hinzugefügt.';
  }

  @override
  String scanSubsConfirmed(String count) {
    return '$count Abonnements bestätigt!';
  }

  @override
  String scanConfirmed(String name) {
    return '$name bestätigt!';
  }

  @override
  String scanLimitReached(String limit) {
    return 'Du hast alle $limit kostenlosen Scans verbraucht. Upgrade auf Pro für unbegrenztes Scannen!';
  }

  @override
  String get scanUnableToProcess =>
      'Bild konnte nicht verarbeitet werden. Versuche es erneut.';

  @override
  String scanTrapDetectedIn(String name) {
    return '⚠️ Falle erkannt bei $name!';
  }

  @override
  String scanTrackingTrial(String name) {
    return '$name-Testphase wird überwacht. Wir erinnern dich vor der Abbuchung!';
  }

  @override
  String scanAddedWithAlerts(String name) {
    return '$name mit Testphasen-Alerts hinzugefügt.';
  }

  @override
  String get scanNoConnection =>
      'Keine Internetverbindung. Überprüfe WLAN oder mobile Daten und versuche es erneut.';

  @override
  String get scanTooManyRequests =>
      'Zu viele Anfragen — bitte warte einen Moment und versuche es erneut.';

  @override
  String get scanServiceDown =>
      'Unser Scan-Dienst ist vorübergehend nicht verfügbar. Versuche es in einigen Minuten erneut.';

  @override
  String get scanSomethingWrong =>
      'Etwas ist schiefgelaufen. Versuche es erneut.';

  @override
  String get scanConvertToGbp => 'In £ GBP umrechnen';

  @override
  String scanKeepInCurrency(String currency) {
    return 'In $currency belassen';
  }

  @override
  String scanPriceCurrency(String currency, String price) {
    return 'Der Preis ist in $currency ($price). Wie möchtest du ihn verfolgen?';
  }

  @override
  String get introPrice => 'Aktionspreis';

  @override
  String introPriceExpires(String date) {
    return 'Aktionspreis endet am $date';
  }

  @override
  String introPriceDaysRemaining(int days) {
    return '⚠️ Aktionspreis — noch $days Tage';
  }
}
