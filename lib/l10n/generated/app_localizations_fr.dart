// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Chompd';

  @override
  String get tagline => 'Scanne. Traque. Contre-attaque.';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get done => 'Terminé';

  @override
  String get keep => 'Garder';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get share => 'Partager';

  @override
  String get confirm => 'Confirmer';

  @override
  String get other => 'Autre';

  @override
  String get close => 'Fermer';

  @override
  String get edit => 'Modifier';

  @override
  String get pro => 'Pro';

  @override
  String get free => 'Gratuit';

  @override
  String get tierTrial => 'Essai';

  @override
  String get onboardingTitle1 => 'Reprends le contrôle de tes abos';

  @override
  String get onboardingSubtitle1 =>
      'Chompd traque chaque abonnement, détecte les pièges cachés et t\'aide à résilier ce que tu n\'utilises pas.';

  @override
  String onboardingStatWaste(String amount) {
    return 'En moyenne, $amount/an sont gaspillés pour des abonnements oubliés';
  }

  @override
  String get onboardingEaseTag => 'Rien à taper. Photo et c\'est tracké.';

  @override
  String get onboardingTitle2 => 'Comment ça marche';

  @override
  String get onboardingStep1Title => 'Fais une capture d\'écran';

  @override
  String get onboardingStep1Subtitle =>
      'Confirmation, e-mail ou relevé bancaire';

  @override
  String get onboardingStep2Title => 'L\'IA le lit instantanément';

  @override
  String get onboardingStep2Subtitle =>
      'Prix, date de renouvellement et pièges cachés';

  @override
  String get onboardingStep3Title => 'C\'est fait. Traqué pour toujours.';

  @override
  String get onboardingStep3Subtitle =>
      'On te prévient avant que tu sois débité';

  @override
  String get onboardingTitle3 => 'Garde une longueur d\'avance';

  @override
  String get onboardingSubtitle3 =>
      'On te rappelle avant chaque renouvellement — pas de mauvaises surprises.';

  @override
  String get onboardingNotifMorning => 'Le matin du renouvellement';

  @override
  String get onboardingNotif7days => '7 jours avant';

  @override
  String get onboardingNotifTrial => 'Alertes de fin d\'essai';

  @override
  String get allowNotifications => 'Autoriser les notifications';

  @override
  String get maybeLater => 'Peut-être plus tard';

  @override
  String get onboardingTitle4 => 'Ajoute ton premier abonnement';

  @override
  String get onboardingSubtitle4 =>
      'La plupart des gens découvrent des abos oubliés dès le premier scan. Voyons ce qui grignote ton argent.';

  @override
  String get scanAScreenshot => 'Scanner une capture';

  @override
  String get scanHintTooltip => 'Appuie sur moi pour scanner !';

  @override
  String get addManually => 'Ajouter manuellement';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String homeStatusLine(int active, int cancelled) {
    return '$active actifs · $cancelled résiliés';
  }

  @override
  String get overBudgetMood => 'Aïe. Ça fait beaucoup.';

  @override
  String get underBudgetMood => 'Super ! Bien en dessous du budget.';

  @override
  String get sectionActiveSubscriptions => 'ABONNEMENTS ACTIFS';

  @override
  String get sectionCancelledSaved => 'RÉSILIÉS — ÉCONOMISÉ';

  @override
  String get sectionMilestones => 'OBJECTIFS';

  @override
  String get sectionYearlyBurn => 'DÉPENSES ANNUELLES';

  @override
  String get sectionMonthlyBurn => 'DÉPENSES MENSUELLES';

  @override
  String get sectionSavedWithChompd => 'ÉCONOMISÉ AVEC CHOMPD';

  @override
  String perYearAcrossSubs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
    );
    return 'par an pour $_temp0';
  }

  @override
  String perMonthAcrossSubs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
    );
    return 'par mois pour $_temp0';
  }

  @override
  String get monthlyAvg => 'moy. mensuelle';

  @override
  String get yearlyTotal => 'total annuel';

  @override
  String get dailyCost => 'coût quotidien';

  @override
  String fromCancelled(int count) {
    return 'de $count résiliés';
  }

  @override
  String get deleteSubscriptionTitle => 'Supprimer l\'abonnement ?';

  @override
  String deleteSubscriptionMessage(String name) {
    return 'Supprimer $name définitivement ?';
  }

  @override
  String cancelledMonthsAgo(int months) {
    return 'Résilié il y a $months mois';
  }

  @override
  String get justCancelled => 'Vient d\'être résilié';

  @override
  String get subsLeft => 'Abos restants';

  @override
  String get scansLeft => 'Scans restants';

  @override
  String get aiScanScreenshot => 'Scan IA d\'une capture';

  @override
  String get aiScanUpgradeToPro => 'Scan IA (Passer en Pro)';

  @override
  String get quickAddManual => 'Ajout rapide / Manuel';

  @override
  String get addSubUpgradeToPro => 'Ajouter un abo (Passer en Pro)';

  @override
  String trialsExpiringSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count essais expirent bientôt',
      one: '1 essai expire bientôt',
    );
    return '$_temp0';
  }

  @override
  String trialDaysLeft(String names, int days) {
    return '$names — $days jours restants';
  }

  @override
  String get proInfinity => 'PRO ∞';

  @override
  String scansLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scans restants',
      one: '1 scan restant',
    );
    return '$_temp0';
  }

  @override
  String get scanTitle => 'Scan IA';

  @override
  String get scanAnalysing => 'Nom nom... je mâche ta capture d\'écran 🐟';

  @override
  String get scanIdleTitle => 'Scanne une capture d\'écran';

  @override
  String get scanIdleSubtitle =>
      'Partage une capture d\'e-mail de confirmation,\nde relevé bancaire ou de reçu App Store.';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get cameraPermError =>
      'Pas d\'accès à la caméra. Vérifie les permissions.';

  @override
  String get galleryPermError =>
      'Pas d\'accès aux photos. Vérifie les permissions.';

  @override
  String get pasteEmailText => 'Coller le texte d\'un e-mail';

  @override
  String get pasteTextHint =>
      'Colle ici le texte de ton e-mail d\'abonnement ou de confirmation...';

  @override
  String get scanText => 'Scanner le texte';

  @override
  String get textReceived => 'Nom nom... je mâche ton texte 🐟';

  @override
  String get smartMove => 'Bien joué !';

  @override
  String youSkipped(String service) {
    return 'Tu as évité $service';
  }

  @override
  String get saved => 'ÉCONOMISÉ';

  @override
  String get addedToUnchompd => 'Ajouté à ton total Unchompd';

  @override
  String get analysing => 'Presque fini... une dernière bouchée';

  @override
  String get scanSniffing => 'Je renifle les frais cachés...';

  @override
  String get scanFoundFeast => 'Un festin trouvé ! Je croque tout...';

  @override
  String get scanEscalation =>
      'J\'appelle un plus gros poisson en renfort... 🦈';

  @override
  String get scanAlmostDone => 'Presque fini... une dernière bouchée';

  @override
  String scanFoundCount(int count) {
    return '$count abonnements trouvés';
  }

  @override
  String get scanTapToExpand => 'Appuie pour développer et modifier';

  @override
  String get scanCancelledHint =>
      'Certains abonnements sont déjà résiliés et expirent bientôt — nous les avons décochés pour toi.';

  @override
  String get scanAlreadyCancelled => 'Déjà résilié';

  @override
  String get scanExpires => 'Expire';

  @override
  String get scanSkipAll => 'Tout ignorer';

  @override
  String scanAddSelected(int count) {
    return '+ Ajouter $count sélectionnés';
  }

  @override
  String get confidence => 'confiance';

  @override
  String get typeYourAnswer => 'Tape ta réponse...';

  @override
  String get addToChompd => 'Ajouter à Chompd';

  @override
  String get monthlyTotal => 'Total mensuel';

  @override
  String addAllToChompd(int count) {
    return 'Ajouter les $count à Chompd';
  }

  @override
  String get autoTier => 'AUTO';

  @override
  String yesIts(String option) {
    return 'Oui, c\'est $option';
  }

  @override
  String get otherAmount => 'Autre montant';

  @override
  String get trapDetected => 'PIÈGE DÉTECTÉ';

  @override
  String trapOfferActually(String name) {
    return 'Cette offre « $name » est en réalité :';
  }

  @override
  String skipItSave(String amount) {
    return 'ÉVITER — ÉCONOMISER $amount';
  }

  @override
  String get trackTrialAnyway => 'Suivre l\'essai quand même';

  @override
  String get trapReminder => 'On te préviendra avant le prélèvement';

  @override
  String get editSubscription => 'Modifier l\'abonnement';

  @override
  String get addSubscription => 'Ajouter un abonnement';

  @override
  String get fieldServiceName => 'NOM DU SERVICE';

  @override
  String get hintServiceName => 'ex. Netflix, Spotify';

  @override
  String get errorNameRequired => 'Nom requis';

  @override
  String get fieldPrice => 'PRIX';

  @override
  String get hintPrice => '9,99';

  @override
  String get errorPriceRequired => 'Prix requis';

  @override
  String get errorInvalidPrice => 'Prix invalide';

  @override
  String get fieldCurrency => 'DEVISE';

  @override
  String get fieldBillingCycle => 'CYCLE DE FACTURATION';

  @override
  String get fieldCategory => 'CATÉGORIE';

  @override
  String get fieldNextRenewal => 'PROCHAIN RENOUVELLEMENT';

  @override
  String get selectDate => 'Choisir une date';

  @override
  String get freeTrialToggle => 'C\'est un essai gratuit';

  @override
  String get trialDurationLabel => 'Durée de l\'essai';

  @override
  String get trialDays7 => '7 jours';

  @override
  String get trialDays14 => '14 jours';

  @override
  String get trialDays30 => '30 jours';

  @override
  String trialCustomDays(int days) {
    return '${days}j';
  }

  @override
  String get fieldTrialEnds => 'FIN DE L\'ESSAI';

  @override
  String get saveChanges => 'Enregistrer';

  @override
  String get subscriptionDetail => 'Détails de l\'abonnement';

  @override
  String thatsPerYear(String amount) {
    return 'Soit $amount par an';
  }

  @override
  String overThreeYears(String amount) {
    return '$amount sur 3 ans';
  }

  @override
  String trialDaysRemaining(int days) {
    return '⚠️ Essai — $days jours restants';
  }

  @override
  String get trialExpired => '⚠️ Essai expiré';

  @override
  String get nextRenewal => 'PROCHAIN RENOUVELLEMENT';

  @override
  String chargesToday(String price) {
    return '$price prélevé aujourd\'hui';
  }

  @override
  String chargesTomorrow(String price) {
    return '$price prélevé demain';
  }

  @override
  String chargesSoon(int days, String price) {
    return '$days jours — $price bientôt';
  }

  @override
  String daysCount(int days) {
    return '$days jours';
  }

  @override
  String get sectionReminders => 'RAPPELS';

  @override
  String remindersScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rappels programmés',
      one: '1 rappel programmé',
    );
    return '$_temp0';
  }

  @override
  String get reminderDaysBefore7 => '7 jours avant';

  @override
  String get reminderDaysBefore3 => '3 jours avant';

  @override
  String get reminderDaysBefore1 => '1 jour avant';

  @override
  String get reminderMorningOf => 'Le matin même';

  @override
  String get upgradeForReminders => 'Passe en Pro pour des rappels anticipés';

  @override
  String get sectionPaymentHistory => 'HISTORIQUE DES PAIEMENTS';

  @override
  String get totalPaid => 'Total payé';

  @override
  String noPaymentsYet(String date) {
    return 'Aucun paiement — ajouté le $date';
  }

  @override
  String get upcoming => 'À venir';

  @override
  String get sectionDetails => 'DÉTAILS';

  @override
  String get detailCategory => 'Catégorie';

  @override
  String get detailCurrency => 'Devise';

  @override
  String get detailBillingCycle => 'Cycle de facturation';

  @override
  String get detailAdded => 'Ajouté';

  @override
  String addedVia(String date, String source) {
    return '$date via $source';
  }

  @override
  String get sourceAiScan => 'Scan IA';

  @override
  String get sourceQuickAdd => 'Ajout rapide';

  @override
  String get sourceManual => 'Manuel';

  @override
  String get cancelSubscription => 'Résilier l\'abonnement';

  @override
  String cancelSubscriptionConfirm(String name) {
    return 'Résilier $name ?';
  }

  @override
  String cancelPlatformPickerTitle(String name) {
    return 'Comment paies-tu $name ?';
  }

  @override
  String get cancelPlatformIos => 'Apple App Store';

  @override
  String get cancelPlatformAndroid => 'Google Play';

  @override
  String get cancelPlatformWeb => 'Site web / Direct';

  @override
  String get cancelPlatformNotSure => 'Pas sûr';

  @override
  String get difficultyEasy => 'Facile — résiliation simple';

  @override
  String get difficultyModerate => 'Modéré — quelques étapes';

  @override
  String get difficultyMedium => 'Moyen — prend quelques minutes';

  @override
  String get difficultyHard => 'Difficile — rendu volontairement compliqué';

  @override
  String get difficultyVeryHard =>
      'Très difficile — multiples écrans de rétention';

  @override
  String get requestRefund => 'Demander un remboursement';

  @override
  String deleteNameTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get deleteNameMessage =>
      'Cet abonnement sera supprimé définitivement. Cette action est irréversible.';

  @override
  String noGuideYet(String name) {
    return 'Pas de guide pour $name pour le moment. Cherche « $name résilier abonnement » en ligne.';
  }

  @override
  String realAnnualCost(String amount) {
    return 'Coût annuel réel : $amount/an';
  }

  @override
  String trialExpires(String date) {
    return 'L\'essai expire le $date';
  }

  @override
  String get chompdPro => 'Chompd Pro';

  @override
  String get paywallTagline =>
      'Un traqueur d\'abonnements qui n\'est pas un abonnement.';

  @override
  String paywallLimitSubs(int count) {
    return 'Tu as atteint la limite gratuite de $count abonnements.';
  }

  @override
  String get paywallLimitScans => 'Tu as utilisé ton scan IA gratuit.';

  @override
  String get paywallLimitReminders =>
      'Les rappels anticipés sont une fonctionnalité Pro.';

  @override
  String get paywallGeneric => 'Débloque l\'expérience Chompd complète.';

  @override
  String get paywallFeature1 => 'Économise 100–500/an sur les dépenses cachées';

  @override
  String get paywallFeature2 => 'Ne rate plus jamais la fin d\'un essai';

  @override
  String get paywallFeature3 => 'Scan de pièges IA illimité';

  @override
  String get paywallFeature4 => 'Traque chaque abonnement';

  @override
  String get paywallFeature5 =>
      'Alertes anticipées : 7j, 3j, 1j avant le prélèvement';

  @override
  String get paywallFeature6 => 'Cartes d\'économies partageables';

  @override
  String get paywallContext =>
      'Rentabilisé dès la résiliation d\'un seul abo oublié.';

  @override
  String get oneTimePayment => 'Paiement unique. Pour toujours.';

  @override
  String get lifetime => 'À VIE';

  @override
  String get unlockChompdPro => 'Débloquer Chompd Pro';

  @override
  String get restoring => 'Restauration...';

  @override
  String get restorePurchase => 'Restaurer l\'achat';

  @override
  String get purchaseError => 'L\'achat n\'a pas pu être finalisé. Réessaie.';

  @override
  String get noPreviousPurchase => 'Aucun achat précédent trouvé.';

  @override
  String get renewalCalendar => 'Calendrier des renouvellements';

  @override
  String get today => 'AUJOURD\'HUI';

  @override
  String get noRenewalsThisDay => 'Aucun renouvellement ce jour';

  @override
  String get thisMonth => 'CE MOIS';

  @override
  String get renewals => 'Renouvellements';

  @override
  String get total => 'Total';

  @override
  String renewalsOnDay(int count, String date, String price) {
    return '$count renouvellements le $date pour un total de $price';
  }

  @override
  String biggestDay(String date, String price) {
    return 'Jour le plus cher : $date — $price';
  }

  @override
  String get tapDayToSee => 'Touche un jour pour voir les renouvellements';

  @override
  String cancelGuideTitle(String name) {
    return 'Résilier $name';
  }

  @override
  String get whyCancelling => 'Pourquoi résilie-tu ?';

  @override
  String get whyCancellingHint =>
      'Un petit tap — ça nous aide à améliorer Chompd.';

  @override
  String get reasonTooExpensive => 'Trop cher';

  @override
  String get reasonDontUse => 'Je ne l\'utilise pas assez';

  @override
  String get reasonBreak => 'Je fais une pause';

  @override
  String get reasonSwitching => 'Je passe à autre chose';

  @override
  String get difficultyLevel => 'Niveau de difficulté';

  @override
  String get cancellationSteps => 'Étapes de résiliation';

  @override
  String stepNumber(int number) {
    return 'ÉTAPE $number';
  }

  @override
  String get openCancelPage => 'Ouvrir la page de résiliation';

  @override
  String get iveCancelled => 'J\'ai résilié';

  @override
  String get couldntCancelRefund =>
      'Tu n\'arrives pas à résilier ? Aide au remboursement →';

  @override
  String get refundTipTitle => 'Astuce : Pourquoi demander un remboursement ?';

  @override
  String get refundTipBody =>
      'Si tu as été débité de manière inattendue, inscrit par erreur, ou que le service n\'a pas fonctionné comme promis — tu peux avoir droit à un remboursement. Plus tu fais ta demande tôt, meilleures sont tes chances.';

  @override
  String get refundRescue => 'Aide au remboursement';

  @override
  String get refundIntro =>
      'Pas de panique — la plupart des gens récupèrent leur argent. On va régler ça.';

  @override
  String chargedYou(String name, String price) {
    return '$name t\'a prélevé $price';
  }

  @override
  String get howCharged => 'COMMENT AS-TU ÉTÉ DÉBITÉ ?';

  @override
  String successRate(String rate) {
    return 'Taux de succès : $rate';
  }

  @override
  String get copyDisputeEmail => 'Copier l\'e-mail de contestation';

  @override
  String get openRefundPage => 'Ouvrir la page de remboursement';

  @override
  String get iveSubmittedRequest => 'J\'ai envoyé ma demande';

  @override
  String get requestSubmitted => 'Demande envoyée !';

  @override
  String get requestSubmittedMessage =>
      'Ta demande de remboursement a été enregistrée. Surveille ta boîte mail.';

  @override
  String get emailCopied => 'E-mail copié dans le presse-papier';

  @override
  String refundWindowDays(String days) {
    return 'Fenêtre de remboursement de $days jours';
  }

  @override
  String avgRefundDays(String days) {
    return '~${days}j en moy.';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get themeTitle => 'THÈME';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get sectionNotifications => 'NOTIFICATIONS';

  @override
  String remindersScheduledSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rappels programmés',
      one: '1 rappel programmé',
    );
    return '$_temp0';
  }

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get pushNotificationsSubtitle =>
      'Rappels de renouvellements et essais';

  @override
  String get morningDigest => 'Résumé matinal';

  @override
  String morningDigestSubtitle(String time) {
    return 'Résumé quotidien à $time';
  }

  @override
  String get renewalReminders => 'Rappels de renouvellement';

  @override
  String get trialExpiryAlerts => 'Alertes de fin d\'essai';

  @override
  String get trialExpirySubtitle => 'Alerte à 3 jours, 1 jour et le jour même';

  @override
  String get sectionReminderSchedule => 'PLANNING DES RAPPELS';

  @override
  String get sectionUpcoming => 'À VENIR';

  @override
  String get noUpcomingNotifications => 'Aucune notification à venir';

  @override
  String get sectionChompdPro => 'CHOMPD PRO';

  @override
  String get sectionCurrency => 'DEVISE';

  @override
  String get displayCurrency => 'Devise d\'affichage';

  @override
  String get sectionMonthlyBudget => 'BUDGET MENSUEL';

  @override
  String get monthlySpendingTarget => 'Objectif de dépenses mensuel';

  @override
  String get budgetHint =>
      'Utilisé pour l\'anneau de dépenses du tableau de bord';

  @override
  String get sectionHapticFeedback => 'RETOUR HAPTIQUE';

  @override
  String get hapticFeedback => 'Retour haptique';

  @override
  String get hapticSubtitle =>
      'Vibrations sur les touches, bascules et célébrations';

  @override
  String get sectionDataExport => 'EXPORT DE DONNÉES';

  @override
  String get exportToCsv => 'Exporter en CSV';

  @override
  String get exportHint => 'Télécharger tous tes abonnements en tableau';

  @override
  String exportSuccess(int count) {
    return '$count abonnements exportés en CSV';
  }

  @override
  String exportFailed(String error) {
    return 'Export échoué : $error';
  }

  @override
  String get sectionAbout => 'À PROPOS';

  @override
  String get version => 'Version';

  @override
  String get tier => 'Forfait';

  @override
  String get aiModel => 'Modèle IA';

  @override
  String get aiModelValue => 'Claude Haiku 4.5';

  @override
  String get setBudgetTitle => 'Définir le budget mensuel';

  @override
  String get setBudgetSubtitle =>
      'Indique ton objectif de dépenses mensuelles en abonnements.';

  @override
  String get reminderSubtitleMorningOnly =>
      'Le matin uniquement (passe en Pro pour plus)';

  @override
  String reminderSubtitleDays(String schedule) {
    return '$schedule avant le renouvellement';
  }

  @override
  String get dayOf => 'Le jour même';

  @override
  String get oneDay => '1 jour';

  @override
  String nDays(int days) {
    return '$days jours';
  }

  @override
  String get timelineLabel7d => '7j';

  @override
  String get timelineLabel3d => '3j';

  @override
  String get timelineLabel1d => '1j';

  @override
  String get timelineLabelDayOf => 'Jour J';

  @override
  String get upgradeProReminders =>
      'Passe en Pro pour les rappels 7j, 3j et 1j';

  @override
  String proPrice(String price) {
    return '£$price';
  }

  @override
  String oneTimePaymentShort(String price) {
    return '$price • Paiement unique';
  }

  @override
  String get sectionLanguage => 'LANGUE';

  @override
  String get severityHigh => 'RISQUE ÉLEVÉ';

  @override
  String get severityCaution => 'ATTENTION';

  @override
  String get severityInfo => 'INFO';

  @override
  String get trapTypeTrialBait => 'Piège à l\'essai';

  @override
  String get trapTypePriceFraming => 'Tarification trompeuse';

  @override
  String get trapTypeHiddenRenewal => 'Renouvellement caché';

  @override
  String get trapTypeCancelFriction => 'Résiliation compliquée';

  @override
  String get trapTypeGeneric => 'Piège d\'abonnement';

  @override
  String get severityExplainHigh =>
      'Hausse de prix extrême ou présentation trompeuse';

  @override
  String get severityExplainMedium =>
      'Le prix d\'introduction augmente significativement';

  @override
  String get severityExplainLow =>
      'Essai standard avec renouvellement automatique';

  @override
  String trialBadge(int days) {
    return '${days}j essai';
  }

  @override
  String introBadge(int days) {
    return '${days}j promo';
  }

  @override
  String get emptyNoSubscriptions => 'Pas encore d\'abonnements';

  @override
  String get emptyNoSubscriptionsHint =>
      'Scanne une capture ou touche + pour commencer.';

  @override
  String get emptyNoTrials => 'Aucun essai actif';

  @override
  String get emptyNoTrialsHint =>
      'Quand tu ajouteras des abonnements d\'essai,\nils apparaîtront ici avec des alertes de compte à rebours.';

  @override
  String get emptyNoSavings => 'Pas encore d\'économies';

  @override
  String get emptyNoSavingsHint =>
      'Résilie les abonnements inutilisés\net regarde tes économies grandir.';

  @override
  String get nudgeReview => 'Vérifier';

  @override
  String get nudgeKeepIt => 'Garder';

  @override
  String get trialLabel => 'ESSAI';

  @override
  String get priceToday => 'AUJOURD\'HUI';

  @override
  String get priceNow => 'MAINTENANT';

  @override
  String get priceThen => 'ENSUITE';

  @override
  String get priceRenewsAt => 'SE RENOUVELLE À';

  @override
  String dayTrial(String days) {
    return 'Essai de $days jours';
  }

  @override
  String monthIntro(String months) {
    return 'Offre de $months mois';
  }

  @override
  String realCostFirstYear(String amount) {
    return 'Coût réel la 1re année : $amount';
  }

  @override
  String get milestoneCoffeeFund => 'Budget café';

  @override
  String get milestoneGamePass => 'Game Pass';

  @override
  String get milestoneWeekendAway => 'Week-end';

  @override
  String get milestoneNewGadget => 'Nouveau gadget';

  @override
  String get milestoneDreamHoliday => 'Vacances de rêve';

  @override
  String get milestoneFirstBiteBack => 'Première contre-attaque';

  @override
  String get milestoneChompSpotter => 'Détecteur de pièges';

  @override
  String get milestoneDarkPatternDestroyer => 'Destructeur de dark patterns';

  @override
  String get milestoneSubscriptionSentinel => 'Sentinelle des abos';

  @override
  String get milestoneUnchompable => 'Unchompable';

  @override
  String get milestoneReached => '✓ Atteint !';

  @override
  String milestoneToGo(String amount) {
    return 'encore $amount';
  }

  @override
  String get celebrationTitle => 'Bien joué ! 🎉';

  @override
  String celebrationSavePerYear(String amount) {
    return 'Tu économiseras $amount/an';
  }

  @override
  String celebrationByDropping(String name) {
    return 'en résiliant $name';
  }

  @override
  String get tapAnywhereToContinue => 'touche n\'importe où pour continuer';

  @override
  String get trapBadge => 'PIÈGE';

  @override
  String trapDays(int days) {
    return '${days}j piège';
  }

  @override
  String get unchompd => 'Unchompd';

  @override
  String get fromSubscriptionTraps => 'des pièges d\'abonnements';

  @override
  String trapsDodged(int count) {
    return '$count évités';
  }

  @override
  String trialsCancelled(int count) {
    return '$count résiliés';
  }

  @override
  String refundsRecovered(int count) {
    return '$count remboursés';
  }

  @override
  String get ringYearly => 'ANNUEL';

  @override
  String get ringMonthly => 'MENSUEL';

  @override
  String overBudget(String amount) {
    return '$amount au-dessus du budget';
  }

  @override
  String ofBudget(String amount) {
    return 'sur $amount de budget';
  }

  @override
  String get tapForMonthly => 'touche pour mensuel';

  @override
  String get tapForYearly => 'touche pour annuel';

  @override
  String budgetRange(String min, String max) {
    return 'Budget : $min – $max';
  }

  @override
  String get addSubscriptionSheet => 'Ajouter un abonnement';

  @override
  String get orChooseService => 'ou choisis un service';

  @override
  String get searchServices => 'Rechercher un service...';

  @override
  String get priceField => 'Prix';

  @override
  String addServiceName(String name) {
    return 'Ajouter $name';
  }

  @override
  String get tapForMore => 'touche pour plus';

  @override
  String shareYearlyBurn(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
    );
    return 'Je dépense $symbol$amount/an pour $_temp0 😳';
  }

  @override
  String shareMonthlyDaily(String symbol, String monthly, String daily) {
    return 'Soit $symbol$monthly/mois ou $symbol$daily/jour';
  }

  @override
  String shareSavedBy(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
    );
    return '✓ Économisé $symbol$amount en résiliant $_temp0';
  }

  @override
  String get shareFooter =>
      'Suivi avec Chompd — Scanne. Traque. Contre-attaque.';

  @override
  String shareSavings(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
    );
    return 'J\'ai économisé $symbol$amount en résiliant $_temp0 🎉\n\nReprends le contrôle de tes abos — getchompd.com';
  }

  @override
  String get insightBigSpenderHeadline => 'Gros poste';

  @override
  String insightBigSpenderMessage(String name, String amount) {
    return '$name te coûte **$amount/an**. C\'est ton abonnement le plus cher.';
  }

  @override
  String get insightAnnualSavingsHeadline => 'Économies annuelles';

  @override
  String insightAnnualSavingsMessage(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
    );
    return 'Passer **$_temp0** en facturation annuelle pourrait économiser ~**$amount/an**.';
  }

  @override
  String get insightRealityCheckHeadline => 'Vérification';

  @override
  String insightRealityCheckMessage(int count) {
    return 'Tu as **$count abonnements actifs**. La moyenne est de 12 — tu les utilises tous ?';
  }

  @override
  String get insightMoneySavedHeadline => 'Argent économisé';

  @override
  String insightMoneySavedMessage(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
    );
    return 'Tu as économisé **$amount** depuis la résiliation de **$_temp0**. Bien joué !';
  }

  @override
  String get insightTrialEndingHeadline => 'Essai en fin de vie';

  @override
  String insightTrialEndingMessage(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'essais expirent',
      one: 'essai expire',
    );
    return '**$names** — $_temp0 bientôt. Résilie maintenant ou tu seras débité.';
  }

  @override
  String get insightDailyCostHeadline => 'Coût quotidien';

  @override
  String insightDailyCostMessage(String amount) {
    return 'Tes abonnements coûtent **$amount/jour** — c\'est un café premium, chaque jour.';
  }

  @override
  String notifRenewsToday(String name) {
    return '$name se renouvelle aujourd\'hui';
  }

  @override
  String notifRenewsTomorrow(String name) {
    return '$name se renouvelle demain';
  }

  @override
  String notifRenewsInDays(String name, int days) {
    return '$name se renouvelle dans $days jours';
  }

  @override
  String notifChargesToday(String price) {
    return 'Tu seras débité de $price aujourd\'hui. Touche pour vérifier ou résilier.';
  }

  @override
  String notifChargesTomorrow(String price) {
    return '$price sera prélevé demain. Tu veux le garder ?';
  }

  @override
  String notifCharges3Days(String price) {
    return 'Renouvellement de $price dans 3 jours.';
  }

  @override
  String notifChargesInDays(String price, int days) {
    return 'Renouvellement de $price dans $days jours. Envie de vérifier ?';
  }

  @override
  String notifTrialEndsToday(String name) {
    return '⚠ L\'essai $name se termine aujourd\'hui !';
  }

  @override
  String notifTrialEndsTomorrow(String name) {
    return 'L\'essai $name se termine demain';
  }

  @override
  String notifTrialEndsInDays(String name, int days) {
    return 'L\'essai $name se termine dans $days jours';
  }

  @override
  String notifTrialBodyToday(String price) {
    return 'Ton essai gratuit se termine aujourd\'hui ! Tu seras débité de $price. Résilie maintenant si tu ne veux pas continuer.';
  }

  @override
  String notifTrialBodyTomorrow(String price) {
    return 'Plus qu\'un jour d\'essai. Ensuite c\'est $price. Résilie maintenant pour éviter le prélèvement.';
  }

  @override
  String notifTrialBodyDays(int days, String price) {
    return 'Encore $days jours d\'essai gratuit. Le prix complet est $price après.';
  }

  @override
  String notifTrapTrialTitle3d(String name) {
    return 'L\'essai $name se termine dans 3 jours';
  }

  @override
  String notifTrapTrialBody3d(String price) {
    return 'Tu seras débité de $price automatiquement. Résilie maintenant si tu n\'en veux pas.';
  }

  @override
  String notifTrapTrialTitleTomorrow(String name, String price) {
    return '⚠️ DEMAIN : $name prélèvera $price';
  }

  @override
  String get notifTrapTrialBodyTomorrow =>
      'Résilie maintenant si tu ne veux pas le garder.';

  @override
  String notifTrapTrialTitle2h(String name, String price) {
    return '🚨 $name prélèvera $price dans 2 HEURES';
  }

  @override
  String get notifTrapTrialBody2h => 'C\'est ta dernière chance pour résilier.';

  @override
  String notifTrapPostCharge(String name) {
    return 'Tu voulais garder $name ?';
  }

  @override
  String notifTrapPostChargeBody(String price) {
    return 'Tu as été débité de $price. Touche si tu as besoin d\'aide pour un remboursement.';
  }

  @override
  String notifDigestBoth(int renewalCount, int trialCount) {
    return '$renewalCount renouvellement(s) + $trialCount essai(s) aujourd\'hui';
  }

  @override
  String notifDigestRenewals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements se renouvellent aujourd\'hui',
      one: '1 abonnement se renouvelle aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String notifDigestTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count essais expirent aujourd\'hui',
      one: '1 essai expire aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String notifDigestRenewalBody(String names, String total) {
    return '$names — total $total';
  }

  @override
  String notifDigestTrialBody(String names) {
    return '$names — résilie maintenant pour éviter les frais';
  }

  @override
  String get cycleWeekly => 'Hebdomadaire';

  @override
  String get cycleMonthly => 'Mensuel';

  @override
  String get cycleQuarterly => 'Trimestriel';

  @override
  String get cycleYearly => 'Annuel';

  @override
  String get cycleWeeklyShort => 'sem.';

  @override
  String get cycleMonthlyShort => 'mois';

  @override
  String get cycleQuarterlyShort => 'trim.';

  @override
  String get cycleYearlyShort => 'an';

  @override
  String scanFound(String details) {
    return 'Trouvé : $details';
  }

  @override
  String scanRenewsDate(String date) {
    return 'renouvellement le $date';
  }

  @override
  String scanChargeFound(String price, String cycle) {
    return 'Paiement trouvé : $price/$cycle.';
  }

  @override
  String scanWhichService(String name, String price, String cycle) {
    return 'Paiement pour $name trouvé : $price/$cycle. Quel service est-ce ?';
  }

  @override
  String scanBilledQuestion(String name) {
    return 'Le service $name est-il facturé mensuellement ou annuellement ?';
  }

  @override
  String scanMissingPrice(String name) {
    return 'Je n\'ai pas trouvé le prix. Combien coûte $name ?';
  }

  @override
  String get categoryStreaming => 'Streaming';

  @override
  String get categoryMusic => 'Musique';

  @override
  String get categoryAi => 'IA';

  @override
  String get categoryProductivity => 'Productivité';

  @override
  String get categoryStorage => 'Stockage';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryGaming => 'Jeux';

  @override
  String get categoryReading => 'Lecture';

  @override
  String get categoryCommunication => 'Communication';

  @override
  String get categoryNews => 'Actualités';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categoryEducation => 'Éducation';

  @override
  String get categoryVpn => 'VPN';

  @override
  String get categoryDeveloper => 'Développeur';

  @override
  String get categoryBundle => 'Pack';

  @override
  String get categoryOther => 'Autre';

  @override
  String get paymentsTrackedHint =>
      'Les paiements seront suivis après chaque renouvellement';

  @override
  String get renewsToday => 'Se renouvelle aujourd\'hui';

  @override
  String get renewsTomorrow => 'Se renouvelle demain';

  @override
  String renewsInDays(int days) {
    return 'Se renouvelle dans $days jours';
  }

  @override
  String renewsOnDate(String date) {
    return 'Se renouvelle le $date';
  }

  @override
  String get renewedYesterday => 'Renouvelé hier';

  @override
  String renewedDaysAgo(int days) {
    return 'Renouvelé il y a $days jours';
  }

  @override
  String get discoveryTipsTitle => 'Où trouver tes abonnements';

  @override
  String get discoveryTipBank => 'Relevé bancaire';

  @override
  String get discoveryTipBankDesc =>
      'Fais une capture de tes transactions — on les trouvera toutes d\'un coup';

  @override
  String get discoveryTipEmail => 'Recherche par e-mail';

  @override
  String get discoveryTipEmailDesc =>
      'Cherche « abonnement », « reçu » ou « renouvellement » dans ta boîte mail';

  @override
  String get discoveryTipAppStore => 'App Store / Play Store';

  @override
  String get discoveryTipAppStoreDesc =>
      'Réglages → Abonnements affiche tous les abos d\'applications actifs';

  @override
  String get discoveryTipPaypal => 'PayPal et applis de paiement';

  @override
  String get discoveryTipPaypalDesc =>
      'Vérifie les paiements automatiques dans PayPal, Revolut ou ton appli de paiement';

  @override
  String get sectionAccount => 'COMPTE';

  @override
  String get accountAnonymous => 'Anonyme';

  @override
  String get accountBackupPrompt => 'Sauvegarde tes données';

  @override
  String get accountBackedUp => 'Sauvegardé';

  @override
  String accountSignedInAs(String email) {
    return 'Connecté en tant que $email';
  }

  @override
  String get syncStatusSyncing => 'Synchronisation...';

  @override
  String get syncStatusSynced => 'Synchronisé';

  @override
  String syncStatusLastSync(String time) {
    return 'Dernière synchro : $time';
  }

  @override
  String get syncStatusOffline => 'Hors ligne';

  @override
  String get syncStatusNeverSynced => 'Pas encore synchronisé';

  @override
  String get signInToBackUp => 'Connecte-toi pour sauvegarder tes données';

  @override
  String get signInWithApple => 'Se connecter avec Apple';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signInWithEmail => 'Se connecter par e-mail';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutConfirm =>
      'Tu veux vraiment te déconnecter ? Tes données resteront sur cet appareil.';

  @override
  String get annualSavingsTitle => 'PASSER À L\'ANNUEL';

  @override
  String get annualSavingsSubtitle =>
      'économies potentielles en passant aux plans annuels';

  @override
  String annualSavingsCoverage(int matched, int total) {
    return 'Basé sur $matched de $total abonnements';
  }

  @override
  String annualSavingsHint(String name) {
    return 'Vérifie les paramètres de ton compte $name pour les options de facturation annuelle';
  }

  @override
  String get seeAll => 'Tout voir';

  @override
  String get allSavingsTitle => 'Économies annuelles';

  @override
  String get allSavingsSubtitle =>
      'Passe ces plans mensuels en annuels pour économiser';

  @override
  String get annualPlanLabel => 'PLAN ANNUEL';

  @override
  String annualPlanAvailable(String amount) {
    return 'Plan annuel disponible — économise $amount/an';
  }

  @override
  String get noAnnualPlan => 'Aucun plan annuel disponible pour ce service';

  @override
  String monthlyVsAnnual(String monthly, String annual) {
    return '$monthly/mois → $annual/an';
  }

  @override
  String get perYear => '/an';

  @override
  String get insightDidYouKnow => 'LE SAVAIS-TU ?';

  @override
  String get insightSaveMoney => 'ÉCONOMISE';

  @override
  String get insightLearnMore => 'En savoir plus';

  @override
  String get insightProLabel => 'CONSEIL PRO';

  @override
  String get insightUnlockPro => 'Débloquer avec Pro';

  @override
  String get insightProTeaser =>
      'Passe en Pro pour des conseils d\'économies personnalisés.';

  @override
  String get insightProTeaserTitle => 'Conseils d\'économies personnalisés';

  @override
  String trialBannerDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours restants',
      one: '1 jour restant',
    );
    return 'Essai Pro · $_temp0';
  }

  @override
  String get trialBannerExpired => 'Essai Pro expiré';

  @override
  String get trialBannerUpgrade => 'Débloquer';

  @override
  String get trialPromptTitle => 'Essaie tout gratuitement pendant 7 jours';

  @override
  String get trialPromptSubtitle =>
      'Accès Pro complet — sans engagement, sans paiement.';

  @override
  String get trialPromptFeature1 => 'Abonnements illimités';

  @override
  String get trialPromptFeature2 => 'Scanner de pièges IA — scans illimités';

  @override
  String get trialPromptFeature3 => 'Rappels anticipés (7j, 3j, 1j)';

  @override
  String get trialPromptFeature4 => 'Tableau de bord & statistiques';

  @override
  String get trialPromptFeature5 =>
      'Guides de résiliation & astuces remboursement';

  @override
  String get trialPromptFeature6 =>
      'Conseils intelligents & cartes d\'économies';

  @override
  String get trialPromptLegal =>
      'Après 7 jours : traque jusqu\'à 3 abonnements gratuitement, ou débloque tout pour £4.99 — une fois, pour toujours.';

  @override
  String get trialPromptCta => 'Commencer l\'essai gratuit';

  @override
  String get trialPromptDismiss => 'Passer pour l\'instant';

  @override
  String get trialExpiredTitle => 'Ton essai de 7 jours est terminé';

  @override
  String trialExpiredSubtitle(int count, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
    );
    return 'Tu as traqué $_temp0 d\'une valeur de $price/mois.';
  }

  @override
  String trialExpiredFrozen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements sont maintenant gelés',
      one: '1 abonnement est maintenant gelé',
    );
    return '$_temp0';
  }

  @override
  String get trialExpiredCta => 'Débloquer Chompd Pro — £4.99';

  @override
  String get trialExpiredDismiss => 'Continuer avec la version gratuite';

  @override
  String get frozenSectionHeader => 'GELÉS — PASSER EN PRO POUR DÉBLOQUER';

  @override
  String get frozenBadge => 'GELÉ';

  @override
  String get frozenTapToUpgrade => 'Appuyez pour passer en Pro';

  @override
  String cancelledStatusExpires(String date) {
    return 'Résilié — expire le $date';
  }

  @override
  String cancelledStatusExpired(String date) {
    return 'Résilié — expiré le $date';
  }

  @override
  String get reactivateSubscription => 'Réactiver l\'abonnement';

  @override
  String get scanErrorGeneric =>
      'Impossible de lire cette image. Essaie une autre capture.';

  @override
  String get scanErrorEmpty => 'Le fichier image semble vide. Réessaie.';

  @override
  String scanServiceFound(String name) {
    return '$name trouvé !';
  }

  @override
  String get scanNoSubscriptionsFound =>
      'Aucun abonnement trouvé dans cette image. Essaie de scanner un reçu, un e-mail de confirmation ou une capture de l\'App Store.';

  @override
  String scanRecurringCharge(String name) {
    return 'Frais récurrents trouvés qui ressemblent à $name.';
  }

  @override
  String scanConfirmQuestion(String pct, String name) {
    return '$pct% des utilisateurs avec ces frais disent que c\'est $name. C\'est ça ?';
  }

  @override
  String scanPersonalOrTeam(String name) {
    return 'Ça ressemble à $name. Abonnement personnel ou équipe/entreprise ?';
  }

  @override
  String get scanPersonal => 'Personnel';

  @override
  String get scanTeamBusiness => 'Équipe / Entreprise';

  @override
  String get scanNotSure => 'Pas sûr';

  @override
  String scanAllDoneAdded(String added, String total) {
    return 'Terminé ! $added sur $total abonnements ajoutés.';
  }

  @override
  String scanSubsConfirmed(String count) {
    return '$count abonnements confirmés !';
  }

  @override
  String scanConfirmed(String name) {
    return '$name confirmé !';
  }

  @override
  String get scanLimitReached =>
      'Tu as utilisé ton scan gratuit. Passe à Pro pour des scans illimités !';

  @override
  String get scanUnableToProcess => 'Impossible de traiter l\'image. Réessaie.';

  @override
  String scanTrapDetectedIn(String name) {
    return '⚠️ Piège détecté dans $name !';
  }

  @override
  String scanTrackingTrial(String name) {
    return 'Suivi de l\'essai de $name. On te rappellera avant le prélèvement !';
  }

  @override
  String scanAddedWithAlerts(String name) {
    return '$name ajouté avec alertes de période d\'essai.';
  }

  @override
  String get scanNoConnection =>
      'Pas de connexion internet. Vérifie ton Wi-Fi ou tes données mobiles et réessaie.';

  @override
  String get scanTooManyRequests =>
      'Trop de requêtes — patiente un instant et réessaie.';

  @override
  String get scanServiceDown =>
      'Notre service de scan est temporairement indisponible. Réessaie dans quelques minutes.';

  @override
  String get scanSomethingWrong => 'Quelque chose s\'est mal passé. Réessaie.';

  @override
  String get scanConvertToGbp => 'Convertir en £ GBP';

  @override
  String scanKeepInCurrency(String currency) {
    return 'Garder en $currency';
  }

  @override
  String scanPriceCurrency(String currency, String price) {
    return 'Le prix est en $currency ($price). Comment veux-tu le suivre ?';
  }

  @override
  String get introPrice => 'Prix de lancement';

  @override
  String introPriceExpires(String date) {
    return 'Prix de lancement expire le $date';
  }

  @override
  String introPriceDaysRemaining(int days) {
    return '⚠️ Prix de lancement — $days jours restants';
  }
}
