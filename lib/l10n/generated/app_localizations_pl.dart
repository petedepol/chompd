// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class SPl extends S {
  SPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Chompd';

  @override
  String get tagline => 'Skanuj. Śledź. Odgryzaj się.';

  @override
  String get save => 'Zapisz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get delete => 'Usuń';

  @override
  String get done => 'Gotowe';

  @override
  String get keep => 'Zostaw';

  @override
  String get skip => 'Pomiń';

  @override
  String get next => 'Dalej';

  @override
  String get share => 'Udostępnij';

  @override
  String get confirm => 'Potwierdź';

  @override
  String get other => 'Inne';

  @override
  String get close => 'Zamknij';

  @override
  String get edit => 'Edytuj';

  @override
  String get pro => 'Pro';

  @override
  String get free => 'Darmowy';

  @override
  String get tierTrial => 'Próba';

  @override
  String get onboardingTitle1 => 'Odgryź się subskrypcjom';

  @override
  String get onboardingSubtitle1 =>
      'Chompd śledzi każdą subskrypcję, wyłapuje ukryte pułapki i pomaga anulować to, czego nie potrzebujesz.';

  @override
  String onboardingStatWaste(String amount) {
    return 'Przeciętna osoba marnuje $amount/rok na zapomniane subskrypcje';
  }

  @override
  String get onboardingEaseTag => 'Bez wpisywania. Zrób zdjęcie i gotowe.';

  @override
  String get onboardingTitle2 => 'Jak to działa';

  @override
  String get onboardingStep1Title => 'Zrób zrzut ekranu';

  @override
  String get onboardingStep1Subtitle =>
      'Potwierdzenie, e-mail lub wyciąg bankowy';

  @override
  String get onboardingStep2Title => 'AI odczytuje natychmiast';

  @override
  String get onboardingStep2Subtitle =>
      'Cenę, datę odnowienia i ukryte pułapki';

  @override
  String get onboardingStep3Title => 'Gotowe. Śledzone na zawsze.';

  @override
  String get onboardingStep3Subtitle =>
      'Przypomnimy Ci zanim zostaniesz obciążony';

  @override
  String get onboardingTitle3 => 'Bądź krok przed odnowieniami';

  @override
  String get onboardingSubtitle3 =>
      'Przypomnimy Ci zanim zostaniesz obciążony — żadnych niespodzianek.';

  @override
  String get onboardingNotifMorning => 'Rano w dniu odnowienia';

  @override
  String get onboardingNotif7days => '7 dni przed';

  @override
  String get onboardingNotifTrial => 'Alerty o końcu triali';

  @override
  String get allowNotifications => 'Włącz powiadomienia';

  @override
  String get maybeLater => 'Może później';

  @override
  String get onboardingTitle4 => 'Dodaj pierwszą subskrypcję';

  @override
  String get onboardingSubtitle4 =>
      'Większość ludzi odkrywa zapomniane subskrypcje przy pierwszym skanie. Sprawdźmy, co pożera twoje pieniądze.';

  @override
  String get scanAScreenshot => 'Skanuj zrzut ekranu';

  @override
  String get scanHintTooltip => 'Dotknij mnie, żeby skanować!';

  @override
  String get addManually => 'Dodaj ręcznie';

  @override
  String get skipForNow => 'Pomiń na razie';

  @override
  String homeStatusLine(int active, int cancelled) {
    return '$active aktywnych · $cancelled anulowanych';
  }

  @override
  String get overBudgetMood => 'Auć. Sporo chomptania.';

  @override
  String get underBudgetMood => 'Świetnie! Sporo pod budżetem.';

  @override
  String get sectionActiveSubscriptions => 'AKTYWNE SUBSKRYPCJE';

  @override
  String get sectionCancelledSaved => 'ANULOWANE — ZAOSZCZĘDZONE';

  @override
  String get sectionMilestones => 'KAMIENIE MILOWE';

  @override
  String get sectionYearlyBurn => 'ROCZNE WYDATKI';

  @override
  String get sectionMonthlyBurn => 'MIESIĘCZNE WYDATKI';

  @override
  String get sectionSavedWithChompd => 'ZAOSZCZĘDZONE Z CHOMPD';

  @override
  String perYearAcrossSubs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subskrypcji',
      few: '$count subskrypcje',
      one: '1 subskrypcję',
    );
    return 'rocznie za $_temp0';
  }

  @override
  String perMonthAcrossSubs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subskrypcji',
      few: '$count subskrypcje',
      one: '1 subskrypcję',
    );
    return 'miesięcznie za $_temp0';
  }

  @override
  String get monthlyAvg => 'śr. miesięcznie';

  @override
  String get yearlyTotal => 'roczny koszt';

  @override
  String get dailyCost => 'dzienny koszt';

  @override
  String fromCancelled(int count) {
    return 'z $count anulowanych';
  }

  @override
  String get deleteSubscriptionTitle => 'Usunąć subskrypcję?';

  @override
  String deleteSubscriptionMessage(String name) {
    return 'Usunąć $name na stałe?';
  }

  @override
  String cancelledMonthsAgo(int months) {
    return 'Anulowano $months mies. temu';
  }

  @override
  String get justCancelled => 'Właśnie anulowano';

  @override
  String get subsLeft => 'Pozostałe sub.';

  @override
  String get scansLeft => 'Pozostałe skany';

  @override
  String get aiScanScreenshot => 'Skan AI ze zrzutu';

  @override
  String get aiScanUpgradeToPro => 'Skan AI (Ulepsz do Pro)';

  @override
  String get quickAddManual => 'Szybkie dodawanie / Ręcznie';

  @override
  String get addSubUpgradeToPro => 'Dodaj sub. (Ulepsz do Pro)';

  @override
  String trialsExpiringSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count triali wygasa wkrótce',
      few: '$count triale wygasają wkrótce',
      one: '1 trial wygasa wkrótce',
    );
    return '$_temp0';
  }

  @override
  String trialDaysLeft(String names, int days) {
    return '$names — zostało $days dni';
  }

  @override
  String get proInfinity => 'PRO ∞';

  @override
  String scansLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zostało $count skanów',
      few: 'Zostały $count skany',
      one: 'Został 1 skan',
    );
    return '$_temp0';
  }

  @override
  String get scanTitle => 'Skan AI';

  @override
  String get scanAnalysing => 'Nom nom... przeżuwam twój zrzut ekranu 🐟';

  @override
  String get scanIdleTitle => 'Skanuj zrzut ekranu';

  @override
  String get scanIdleSubtitle =>
      'Udostępnij zrzut ekranu z e-maila potwierdzającego,\nwyciągu bankowego lub paragonu z App Store.';

  @override
  String get takePhoto => 'Zrób zdjęcie';

  @override
  String get chooseFromGallery => 'Wybierz z galerii';

  @override
  String get cameraPermError => 'Brak dostępu do kamery. Sprawdź uprawnienia.';

  @override
  String get galleryPermError =>
      'Brak dostępu do galerii zdjęć. Sprawdź uprawnienia.';

  @override
  String get pasteEmailText => 'Wklej tekst e-maila';

  @override
  String get pasteTextHint =>
      'Wklej tutaj tekst e-maila z subskrypcją lub potwierdzeniem...';

  @override
  String get scanText => 'Skanuj tekst';

  @override
  String get textReceived => 'Nom nom... przeżuwam twój tekst 🐟';

  @override
  String get smartMove => 'Sprytne!';

  @override
  String youSkipped(String service) {
    return 'Pominąłeś $service';
  }

  @override
  String get saved => 'ZAOSZCZĘDZONE';

  @override
  String get addedToUnchompd => 'Dodane do Twojego Unchompd';

  @override
  String get analysing => 'Prawie gotowe... jeszcze jeden kęs';

  @override
  String get scanSniffing => 'Wyszukuję podejrzane opłaty...';

  @override
  String get scanFoundFeast =>
      'Znalazłem ucztę! Przegryzam się przez wszystko...';

  @override
  String get scanEscalation => 'Wzywam większą rybę na pomoc... 🦈';

  @override
  String get scanAlmostDone => 'Prawie gotowe... jeszcze jeden kęs';

  @override
  String scanFoundCount(int count) {
    return 'Znaleziono $count subskrypcji';
  }

  @override
  String get scanTapToExpand => 'Dotknij, aby rozwinąć i edytować';

  @override
  String get scanCancelledHint =>
      'Niektóre subskrypcje zostały anulowane i wkrótce wygasną — odznaczyliśmy je za Ciebie.';

  @override
  String get scanAlreadyCancelled => 'Już anulowana';

  @override
  String get scanExpires => 'Wygasa';

  @override
  String get scanSkipAll => 'Pomiń wszystko';

  @override
  String scanAddSelected(int count) {
    return '+ Dodaj $count wybranych';
  }

  @override
  String get confidence => 'pewność';

  @override
  String get typeYourAnswer => 'Wpisz odpowiedź...';

  @override
  String get addToChompd => 'Dodaj do Chompd';

  @override
  String get monthlyTotal => 'Razem miesięcznie';

  @override
  String addAllToChompd(int count) {
    return 'Dodaj wszystkie ($count) do Chompd';
  }

  @override
  String get autoTier => 'AUTO';

  @override
  String yesIts(String option) {
    return 'Tak, to $option';
  }

  @override
  String get otherAmount => 'Inna kwota';

  @override
  String get trapDetected => 'WYKRYTO PUŁAPKĘ';

  @override
  String trapOfferActually(String name) {
    return 'Ta oferta „$name” to w rzeczywistości:';
  }

  @override
  String skipItSave(String amount) {
    return 'POMIŃ — OSZCZĘDŹ $amount';
  }

  @override
  String get trackTrialAnyway => 'Śledź trial mimo to';

  @override
  String get trapReminder => 'Przypomnimy Ci zanim pobiorą opłatę';

  @override
  String get editSubscription => 'Edytuj subskrypcję';

  @override
  String get addSubscription => 'Dodaj subskrypcję';

  @override
  String get fieldServiceName => 'NAZWA USŁUGI';

  @override
  String get hintServiceName => 'np. Netflix, Spotify';

  @override
  String get errorNameRequired => 'Nazwa jest wymagana';

  @override
  String get fieldPrice => 'CENA';

  @override
  String get hintPrice => '9.99';

  @override
  String get errorPriceRequired => 'Cena jest wymagana';

  @override
  String get errorInvalidPrice => 'Nieprawidłowa cena';

  @override
  String get fieldCurrency => 'WALUTA';

  @override
  String get fieldBillingCycle => 'CYKL ROZLICZENIOWY';

  @override
  String get fieldCategory => 'KATEGORIA';

  @override
  String get fieldNextRenewal => 'NASTĘPNE ODNOWIENIE';

  @override
  String get selectDate => 'Wybierz datę';

  @override
  String get freeTrialToggle => 'To jest darmowy okres próbny';

  @override
  String get trialDurationLabel => 'Długość triala';

  @override
  String get trialDays7 => '7 dni';

  @override
  String get trialDays14 => '14 dni';

  @override
  String get trialDays30 => '30 dni';

  @override
  String trialCustomDays(int days) {
    return '${days}d';
  }

  @override
  String get fieldTrialEnds => 'TRIAL KOŃCZY SIĘ';

  @override
  String get saveChanges => 'Zapisz zmiany';

  @override
  String get subscriptionDetail => 'Szczegóły subskrypcji';

  @override
  String thatsPerYear(String amount) {
    return 'To $amount rocznie';
  }

  @override
  String overThreeYears(String amount) {
    return '$amount przez 3 lata';
  }

  @override
  String trialDaysRemaining(int days) {
    return '⚠️ Trial — zostało $days dni';
  }

  @override
  String get trialExpired => '⚠️ Okres próbny wygasł';

  @override
  String get nextRenewal => 'NASTĘPNE ODNOWIENIE';

  @override
  String chargesToday(String price) {
    return '$price do zapłaty dziś';
  }

  @override
  String chargesTomorrow(String price) {
    return '$price do zapłaty jutro';
  }

  @override
  String chargesSoon(int days, String price) {
    return 'za $days dni — $price wkrótce';
  }

  @override
  String daysCount(int days) {
    return '$days dni';
  }

  @override
  String get sectionReminders => 'PRZYPOMNIENIA';

  @override
  String remindersScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count przypomnień ustawionych',
      few: '$count przypomnienia ustawione',
      one: '1 przypomnienie ustawione',
    );
    return '$_temp0';
  }

  @override
  String get reminderDaysBefore7 => '7 dni przed';

  @override
  String get reminderDaysBefore3 => '3 dni przed';

  @override
  String get reminderDaysBefore1 => '1 dzień przed';

  @override
  String get reminderMorningOf => 'Rano w dniu';

  @override
  String get upgradeForReminders =>
      'Ulepsz do Pro, by dostać wcześniejsze przypomnienia';

  @override
  String get sectionPaymentHistory => 'HISTORIA PŁATNOŚCI';

  @override
  String get totalPaid => 'Zapłacono łącznie';

  @override
  String noPaymentsYet(String date) {
    return 'Brak płatności — dodano $date';
  }

  @override
  String get upcoming => 'Nadchodzące';

  @override
  String get sectionDetails => 'SZCZEGÓŁY';

  @override
  String get detailCategory => 'Kategoria';

  @override
  String get detailCurrency => 'Waluta';

  @override
  String get detailBillingCycle => 'Cykl rozliczeniowy';

  @override
  String get detailAdded => 'Dodano';

  @override
  String addedVia(String date, String source) {
    return '$date przez $source';
  }

  @override
  String get sourceAiScan => 'Skan AI';

  @override
  String get sourceQuickAdd => 'Szybkie dodawanie';

  @override
  String get sourceManual => 'Ręcznie';

  @override
  String get cancelSubscription => 'Anuluj subskrypcję';

  @override
  String cancelSubscriptionConfirm(String name) {
    return 'Anulować $name?';
  }

  @override
  String cancelPlatformPickerTitle(String name) {
    return 'Jak płacisz za $name?';
  }

  @override
  String get cancelPlatformIos => 'Apple App Store';

  @override
  String get cancelPlatformAndroid => 'Google Play';

  @override
  String get cancelPlatformWeb => 'Strona internetowa';

  @override
  String get cancelPlatformNotSure => 'Nie wiem';

  @override
  String get difficultyEasy => 'Łatwe — prosta rezygnacja';

  @override
  String get difficultyModerate => 'Umiarkowane — kilka kroków';

  @override
  String get difficultyMedium => 'Średnie — zajmie kilka minut';

  @override
  String get difficultyHard => 'Trudne — celowo utrudnione';

  @override
  String get difficultyVeryHard => 'Bardzo trudne — wiele ekranów retencji';

  @override
  String get requestRefund => 'Zażądaj zwrotu';

  @override
  String deleteNameTitle(String name) {
    return 'Usunąć $name?';
  }

  @override
  String get deleteNameMessage =>
      'Subskrypcja zostanie trwale usunięta. Tego nie można cofnąć.';

  @override
  String noGuideYet(String name) {
    return 'Brak poradnika dla $name. Wyszukaj \'$name anuluj subskrypcję\' w internecie.';
  }

  @override
  String realAnnualCost(String amount) {
    return 'Realny koszt roczny: $amount/rok';
  }

  @override
  String trialExpires(String date) {
    return 'Trial wygasa $date';
  }

  @override
  String get chompdPro => 'Chompd Pro';

  @override
  String get paywallTagline =>
      'Tracker subskrypcji, który nie jest subskrypcją.';

  @override
  String paywallLimitSubs(int count) {
    return 'Osiągnąłeś darmowy limit $count subskrypcji.';
  }

  @override
  String paywallLimitScans(int count) {
    return 'Wykorzystałeś wszystkie $count darmowe skany AI.';
  }

  @override
  String get paywallLimitReminders =>
      'Wcześniejsze przypomnienia to funkcja Pro.';

  @override
  String get paywallGeneric => 'Odblokuj pełne doświadczenie Chompd.';

  @override
  String get paywallFeature1 =>
      'Oszczędź 500–2500 zł/rok na ukrytych wydatkach';

  @override
  String get paywallFeature2 => 'Nigdy nie przegap końca triala';

  @override
  String get paywallFeature3 => 'Nieograniczone skanowanie pułapek AI';

  @override
  String get paywallFeature4 => 'Śledź każdą subskrypcję';

  @override
  String get paywallFeature5 =>
      'Wczesne ostrzeżenia: 7, 3, 1 dzień przed opłatą';

  @override
  String get paywallFeature6 => 'Karty oszczędności do udostępnienia';

  @override
  String get paywallContext =>
      'Zwraca się po anulowaniu jednej zapomnianej subskrypcji.';

  @override
  String get oneTimePayment => 'Jednorazowa płatność. Na zawsze.';

  @override
  String get lifetime => 'NA ZAWSZE';

  @override
  String get unlockChompdPro => 'Odblokuj Chompd Pro';

  @override
  String get restoring => 'Przywracanie...';

  @override
  String get restorePurchase => 'Przywróć zakup';

  @override
  String get purchaseError => 'Zakup nie powiódł się. Spróbuj ponownie.';

  @override
  String get noPreviousPurchase => 'Nie znaleziono poprzedniego zakupu.';

  @override
  String get renewalCalendar => 'Kalendarz odnowień';

  @override
  String get today => 'DZIŚ';

  @override
  String get noRenewalsThisDay => 'Brak odnowień tego dnia';

  @override
  String get thisMonth => 'TEN MIESIĄC';

  @override
  String get renewals => 'Odnowienia';

  @override
  String get total => 'Łącznie';

  @override
  String renewalsOnDay(int count, String date, String price) {
    return '$count odnowień dnia $date na łączną kwotę $price';
  }

  @override
  String biggestDay(String date, String price) {
    return 'Najdroższy dzień: $date — $price';
  }

  @override
  String get tapDayToSee => 'Stuknij dzień, by zobaczyć odnowienia';

  @override
  String cancelGuideTitle(String name) {
    return 'Anuluj $name';
  }

  @override
  String get whyCancelling => 'Dlaczego anulujesz?';

  @override
  String get whyCancellingHint =>
      'Szybkie stuknięcie — pomaga nam ulepszać Chompd.';

  @override
  String get reasonTooExpensive => 'Za drogie';

  @override
  String get reasonDontUse => 'Za mało używam';

  @override
  String get reasonBreak => 'Robię sobie przerwę';

  @override
  String get reasonSwitching => 'Przechodzę na coś innego';

  @override
  String get difficultyLevel => 'Poziom trudności';

  @override
  String get cancellationSteps => 'Kroki anulowania';

  @override
  String stepNumber(int number) {
    return 'KROK $number';
  }

  @override
  String get openCancelPage => 'Otwórz stronę anulowania';

  @override
  String get iveCancelled => 'Anulowałem';

  @override
  String get couldntCancelRefund => 'Nie możesz anulować? Pomoc ze zwrotem →';

  @override
  String get refundTipTitle => 'Wskazówka: Dlaczego warto poprosić o zwrot?';

  @override
  String get refundTipBody =>
      'Jeśli zostałeś obciążony niespodziewanie, zapisałeś się przez przypadek lub usługa nie działała zgodnie z obietnicą — możesz mieć prawo do zwrotu. Im szybciej poprosisz, tym większe szanse.';

  @override
  String get refundRescue => 'Ratunek zwrotu';

  @override
  String get refundIntro =>
      'Spokojnie — większość ludzi odzyskuje pieniądze. Ogarniemy to.';

  @override
  String chargedYou(String name, String price) {
    return '$name pobrał $price';
  }

  @override
  String get howCharged => 'JAK ZOSTAŁEŚ OBCIĄŻONY?';

  @override
  String successRate(String rate) {
    return 'Skuteczność: $rate';
  }

  @override
  String get copyDisputeEmail => 'Kopiuj e-mail reklamacyjny';

  @override
  String get openRefundPage => 'Otwórz stronę zwrotu';

  @override
  String get iveSubmittedRequest => 'Wysłałem wniosek';

  @override
  String get requestSubmitted => 'Wniosek wysłany!';

  @override
  String get requestSubmittedMessage =>
      'Zapisaliśmy Twój wniosek o zwrot. Sprawdzaj skrzynkę mailową.';

  @override
  String get emailCopied => 'E-mail skopiowany do schowka';

  @override
  String refundWindowDays(String days) {
    return '$days-dniowe okno zwrotu';
  }

  @override
  String avgRefundDays(String days) {
    return '~$days dni śr.';
  }

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get themeTitle => 'MOTYW';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get themeLight => 'Jasny';

  @override
  String get sectionNotifications => 'POWIADOMIENIA';

  @override
  String remindersScheduledSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count przypomnień ustawionych',
      few: '$count przypomnienia ustawione',
      one: '1 przypomnienie ustawione',
    );
    return '$_temp0';
  }

  @override
  String get pushNotifications => 'Powiadomienia push';

  @override
  String get pushNotificationsSubtitle =>
      'Przypomnienia o odnowieniach i trialach';

  @override
  String get morningDigest => 'Poranny przegląd';

  @override
  String morningDigestSubtitle(String time) {
    return 'Codzienne podsumowanie o $time';
  }

  @override
  String get renewalReminders => 'Przypomnienia o odnowieniach';

  @override
  String get trialExpiryAlerts => 'Alerty o końcu triali';

  @override
  String get trialExpirySubtitle =>
      'Ostrzega 3 dni, 1 dzień i w dniu wygaśnięcia';

  @override
  String get sectionReminderSchedule => 'HARMONOGRAM PRZYPOMNIEŃ';

  @override
  String get sectionUpcoming => 'NADCHODZĄCE';

  @override
  String get noUpcomingNotifications => 'Brak nadchodzących powiadomień';

  @override
  String get sectionChompdPro => 'CHOMPD PRO';

  @override
  String get sectionCurrency => 'WALUTA';

  @override
  String get displayCurrency => 'Waluta wyświetlania';

  @override
  String get sectionMonthlyBudget => 'BUDŻET MIESIĘCZNY';

  @override
  String get monthlySpendingTarget => 'Miesięczny cel wydatków';

  @override
  String get budgetHint => 'Używany w pierścieniu wydatków na pulpicie';

  @override
  String get sectionHapticFeedback => 'WIBRACJE';

  @override
  String get hapticFeedback => 'Wibracje';

  @override
  String get hapticSubtitle =>
      'Wibracje przy stuknięciach, przełącznikach i celebracjach';

  @override
  String get sectionDataExport => 'EKSPORT DANYCH';

  @override
  String get exportToCsv => 'Eksportuj do CSV';

  @override
  String get exportHint => 'Pobierz wszystkie subskrypcje jako arkusz';

  @override
  String exportSuccess(int count) {
    return 'Wyeksportowano $count subskrypcji do CSV';
  }

  @override
  String exportFailed(String error) {
    return 'Eksport nie powiódł się: $error';
  }

  @override
  String get sectionAbout => 'O APLIKACJI';

  @override
  String get version => 'Wersja';

  @override
  String get tier => 'Plan';

  @override
  String get aiModel => 'Model AI';

  @override
  String get aiModelValue => 'Claude Haiku 4.5';

  @override
  String get setBudgetTitle => 'Ustaw budżet miesięczny';

  @override
  String get setBudgetSubtitle =>
      'Wpisz docelowe miesięczne wydatki na subskrypcje.';

  @override
  String get reminderSubtitleMorningOnly =>
      'Tylko rano w dniu odnowienia (ulepsz po więcej)';

  @override
  String reminderSubtitleDays(String schedule) {
    return '$schedule przed odnowieniem';
  }

  @override
  String get dayOf => 'w dniu';

  @override
  String get oneDay => '1 dzień';

  @override
  String nDays(int days) {
    return '$days dni';
  }

  @override
  String get timelineLabel7d => '7d';

  @override
  String get timelineLabel3d => '3d';

  @override
  String get timelineLabel1d => '1d';

  @override
  String get timelineLabelDayOf => 'W dniu';

  @override
  String get upgradeProReminders =>
      'Ulepsz do Pro po przypomnienia 7d, 3d i 1d';

  @override
  String proPrice(String price) {
    return '$price';
  }

  @override
  String oneTimePaymentShort(String price) {
    return '$price • Jednorazowa płatność';
  }

  @override
  String get sectionLanguage => 'JĘZYK';

  @override
  String get severityHigh => 'WYSOKIE RYZYKO';

  @override
  String get severityCaution => 'UWAGA';

  @override
  String get severityInfo => 'INFO';

  @override
  String get trapTypeTrialBait => 'Pułapka próbna';

  @override
  String get trapTypePriceFraming => 'Ukrywanie ceny';

  @override
  String get trapTypeHiddenRenewal => 'Ukryte odnowienie';

  @override
  String get trapTypeCancelFriction => 'Utrudnione anulowanie';

  @override
  String get trapTypeGeneric => 'Pułapka subskrypcyjna';

  @override
  String get severityExplainHigh =>
      'Ekstremalny skok cen lub oszukańcze praktyki';

  @override
  String get severityExplainMedium => 'Cena wstępna znacząco wzrasta';

  @override
  String get severityExplainLow =>
      'Standardowy okres próbny z auto-odnowieniem';

  @override
  String trialBadge(int days) {
    return '${days}d trial';
  }

  @override
  String get emptyNoSubscriptions => 'Brak subskrypcji';

  @override
  String get emptyNoSubscriptionsHint =>
      'Skanuj zrzut ekranu lub stuknij +, by zacząć.';

  @override
  String get emptyNoTrials => 'Brak aktywnych triali';

  @override
  String get emptyNoTrialsHint =>
      'Gdy dodasz subskrypcje z trialem,\npojawią się tu z alertami odliczania.';

  @override
  String get emptyNoSavings => 'Brak oszczędności';

  @override
  String get emptyNoSavingsHint =>
      'Anuluj subskrypcje, których nie używasz\ni obserwuj, jak rosną Twoje oszczędności.';

  @override
  String get nudgeReview => 'Sprawdź';

  @override
  String get nudgeKeepIt => 'Zostaw';

  @override
  String get trialLabel => 'TRIAL';

  @override
  String get priceToday => 'DZIŚ';

  @override
  String get priceNow => 'TERAZ';

  @override
  String get priceThen => 'POTEM';

  @override
  String get priceRenewsAt => 'ODNAWIA SIĘ ZA';

  @override
  String dayTrial(String days) {
    return '$days-dniowy trial';
  }

  @override
  String monthIntro(String months) {
    return '$months-mies. oferta wstępna';
  }

  @override
  String realCostFirstYear(String amount) {
    return 'Realny koszt w pierwszym roku: $amount';
  }

  @override
  String get milestoneCoffeeFund => 'Fundusz kawowy';

  @override
  String get milestoneGamePass => 'Karnet na gry';

  @override
  String get milestoneWeekendAway => 'Weekendowy wypad';

  @override
  String get milestoneNewGadget => 'Nowy gadżet';

  @override
  String get milestoneDreamHoliday => 'Wakacje marzeń';

  @override
  String get milestoneFirstBiteBack => 'Pierwszy odgryz';

  @override
  String get milestoneChompSpotter => 'Łowca chomptów';

  @override
  String get milestoneDarkPatternDestroyer => 'Pogromca dark patternów';

  @override
  String get milestoneSubscriptionSentinel => 'Strażnik subskrypcji';

  @override
  String get milestoneUnchompable => 'Niechompdalny';

  @override
  String get milestoneReached => '✓ Osiągnięto!';

  @override
  String milestoneToGo(String amount) {
    return 'brakuje $amount';
  }

  @override
  String get celebrationTitle => 'Brawo! 🎉';

  @override
  String celebrationSavePerYear(String amount) {
    return 'Zaoszczędzisz $amount/rok';
  }

  @override
  String celebrationByDropping(String name) {
    return 'rezygnując z $name';
  }

  @override
  String get tapAnywhereToContinue => 'stuknij gdziekolwiek, by kontynuować';

  @override
  String get trapBadge => 'PUŁAPKA';

  @override
  String trapDays(int days) {
    return '${days}d pułapka';
  }

  @override
  String get unchompd => 'Unchompd';

  @override
  String get fromSubscriptionTraps => 'z pułapek subskrypcyjnych';

  @override
  String trapsDodged(int count) {
    return '$count ominięto';
  }

  @override
  String trialsCancelled(int count) {
    return '$count anulowano';
  }

  @override
  String refundsRecovered(int count) {
    return '$count zwrócono';
  }

  @override
  String get ringYearly => 'ROCZNIE';

  @override
  String get ringMonthly => 'MIESIĘCZNIE';

  @override
  String overBudget(String amount) {
    return '$amount ponad budżet';
  }

  @override
  String ofBudget(String amount) {
    return 'z budżetu $amount';
  }

  @override
  String get tapForMonthly => 'stuknij po miesięczne';

  @override
  String get tapForYearly => 'stuknij po roczne';

  @override
  String budgetRange(String min, String max) {
    return 'Budżet: $min – $max';
  }

  @override
  String get addSubscriptionSheet => 'Dodaj subskrypcję';

  @override
  String get orChooseService => 'lub wybierz usługę';

  @override
  String get searchServices => 'Szukaj usług...';

  @override
  String get priceField => 'Cena';

  @override
  String addServiceName(String name) {
    return 'Dodaj $name';
  }

  @override
  String get tapForMore => 'stuknij po więcej';

  @override
  String shareYearlyBurn(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subskrypcji',
      few: '$count subskrypcje',
      one: '1 subskrypcję',
    );
    return 'Wydaję $symbol$amount/rok na $_temp0 😳';
  }

  @override
  String shareMonthlyDaily(String symbol, String monthly, String daily) {
    return 'To $symbol$monthly/mies. albo $symbol$daily/dzień';
  }

  @override
  String shareSavedBy(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subskrypcji',
      few: '$count subskrypcje',
      one: '1 subskrypcję',
    );
    return '✓ Zaoszczędziłem $symbol$amount anulując $_temp0';
  }

  @override
  String get shareFooter => 'Śledzone z Chompd — Skanuj. Śledź. Odgryzaj się.';

  @override
  String shareSavings(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subskrypcji',
      few: '$count subskrypcje',
      one: '1 subskrypcję',
    );
    return 'Zaoszczędziłem $symbol$amount anulując $_temp0 🎉\n\nOdgryź się subskrypcjom — getchompd.com';
  }

  @override
  String get insightBigSpenderHeadline => 'Duży wydatek';

  @override
  String insightBigSpenderMessage(String name, String amount) {
    return '$name kosztuje Cię **$amount/rok**. To Twoja najdroższa subskrypcja.';
  }

  @override
  String get insightAnnualSavingsHeadline => 'Roczne oszczędności';

  @override
  String insightAnnualSavingsMessage(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subskrypcji',
      few: '$count subskrypcji',
      one: '1 subskrypcji',
    );
    return 'Przejście **$_temp0** na rozliczenie roczne może zaoszczędzić ~**$amount/rok**.';
  }

  @override
  String get insightRealityCheckHeadline => 'Sprawdzian rzeczywistości';

  @override
  String insightRealityCheckMessage(int count) {
    return 'Masz **$count aktywnych subskrypcji**. Średnia to 12 — czy na pewno używasz ich wszystkich?';
  }

  @override
  String get insightMoneySavedHeadline => 'Zaoszczędzone';

  @override
  String insightMoneySavedMessage(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subskrypcji',
      few: '$count subskrypcji',
      one: '1 subskrypcji',
    );
    return 'Zaoszczędziłeś **$amount** od anulowania **$_temp0**. Tak trzymaj!';
  }

  @override
  String get insightTrialEndingHeadline => 'Trial się kończy';

  @override
  String insightTrialEndingMessage(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'triale',
      one: 'trial',
    );
    return '**$names** — $_temp0 kończą się wkrótce. Anuluj teraz albo zostaniesz obciążony.';
  }

  @override
  String get insightDailyCostHeadline => 'Dzienny koszt';

  @override
  String insightDailyCostMessage(String amount) {
    return 'Twoje subskrypcje kosztują **$amount/dzień** — to kawa speciality, każdego dnia.';
  }

  @override
  String notifRenewsToday(String name) {
    return '$name odnawia się dziś';
  }

  @override
  String notifRenewsTomorrow(String name) {
    return '$name odnawia się jutro';
  }

  @override
  String notifRenewsInDays(String name, int days) {
    return '$name odnawia się za $days dni';
  }

  @override
  String notifChargesToday(String price) {
    return 'Zostaniesz obciążony kwotą $price dziś. Stuknij, by sprawdzić lub anulować.';
  }

  @override
  String notifChargesTomorrow(String price) {
    return '$price zostanie pobrane jutro. Chcesz to zachować?';
  }

  @override
  String notifCharges3Days(String price) {
    return 'Odnowienie $price za 3 dni.';
  }

  @override
  String notifChargesInDays(String price, int days) {
    return 'Odnowienie $price za $days dni. Czas na przegląd?';
  }

  @override
  String notifTrialEndsToday(String name) {
    return '⚠ Trial $name kończy się dziś!';
  }

  @override
  String notifTrialEndsTomorrow(String name) {
    return 'Trial $name kończy się jutro';
  }

  @override
  String notifTrialEndsInDays(String name, int days) {
    return 'Trial $name kończy się za $days dni';
  }

  @override
  String notifTrialBodyToday(String price) {
    return 'Twój darmowy trial kończy się dziś! Zostaniesz obciążony kwotą $price. Anuluj teraz, jeśli nie chcesz kontynuować.';
  }

  @override
  String notifTrialBodyTomorrow(String price) {
    return 'Został jeden dzień triala. Potem to $price. Anuluj teraz, by uniknąć opłaty.';
  }

  @override
  String notifTrialBodyDays(int days, String price) {
    return 'Zostało $days dni darmowego triala. Pełna cena to $price po tym okresie.';
  }

  @override
  String notifTrapTrialTitle3d(String name) {
    return 'Trial $name kończy się za 3 dni';
  }

  @override
  String notifTrapTrialBody3d(String price) {
    return 'Automatycznie pobierze $price. Anuluj teraz, jeśli nie chcesz.';
  }

  @override
  String notifTrapTrialTitleTomorrow(String name, String price) {
    return '⚠️ JUTRO: $name pobierze $price';
  }

  @override
  String get notifTrapTrialBodyTomorrow =>
      'Anuluj teraz, jeśli nie chcesz tego zachować.';

  @override
  String notifTrapTrialTitle2h(String name, String price) {
    return '🚨 $name pobierze $price za 2 GODZINY';
  }

  @override
  String get notifTrapTrialBody2h => 'To Twoja ostatnia szansa na anulowanie.';

  @override
  String notifTrapPostCharge(String name) {
    return 'Czy chciałeś zachować $name?';
  }

  @override
  String notifTrapPostChargeBody(String price) {
    return 'Pobrano $price. Stuknij, jeśli potrzebujesz pomocy ze zwrotem.';
  }

  @override
  String notifDigestBoth(int renewalCount, int trialCount) {
    return '$renewalCount odnowień + $trialCount triali dziś';
  }

  @override
  String notifDigestRenewals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subskrypcji odnawia się dziś',
      few: '$count subskrypcje odnawiają się dziś',
      one: '1 subskrypcja odnawia się dziś',
    );
    return '$_temp0';
  }

  @override
  String notifDigestTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count triali wygasa dziś',
      few: '$count triale wygasają dziś',
      one: '1 trial wygasa dziś',
    );
    return '$_temp0';
  }

  @override
  String notifDigestRenewalBody(String names, String total) {
    return '$names — łącznie $total';
  }

  @override
  String notifDigestTrialBody(String names) {
    return '$names — anuluj teraz, by uniknąć opłat';
  }

  @override
  String get cycleWeekly => 'Tygodniowo';

  @override
  String get cycleMonthly => 'Miesięcznie';

  @override
  String get cycleQuarterly => 'Kwartalnie';

  @override
  String get cycleYearly => 'Rocznie';

  @override
  String get cycleWeeklyShort => 'tydz.';

  @override
  String get cycleMonthlyShort => 'mies.';

  @override
  String get cycleQuarterlyShort => 'kw.';

  @override
  String get cycleYearlyShort => 'rok';

  @override
  String scanFound(String details) {
    return 'Znaleziono: $details';
  }

  @override
  String scanRenewsDate(String date) {
    return 'odnawia się $date';
  }

  @override
  String scanChargeFound(String price, String cycle) {
    return 'Znaleziono opłatę za $price/$cycle.';
  }

  @override
  String scanWhichService(String name, String price, String cycle) {
    return 'Znaleziono opłatę za $name na $price/$cycle. Jaka to usługa?';
  }

  @override
  String scanBilledQuestion(String name) {
    return 'Czy $name jest rozliczane miesięcznie czy rocznie?';
  }

  @override
  String scanMissingPrice(String name) {
    return 'Nie znalazłem ceny na tym zdjęciu. Ile kosztuje $name?';
  }

  @override
  String get categoryStreaming => 'Streaming';

  @override
  String get categoryMusic => 'Muzyka';

  @override
  String get categoryAi => 'AI';

  @override
  String get categoryProductivity => 'Produktywność';

  @override
  String get categoryStorage => 'Chmura';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryGaming => 'Gry';

  @override
  String get categoryReading => 'Czytanie';

  @override
  String get categoryCommunication => 'Komunikacja';

  @override
  String get categoryNews => 'Wiadomości';

  @override
  String get categoryFinance => 'Finanse';

  @override
  String get categoryEducation => 'Edukacja';

  @override
  String get categoryVpn => 'VPN';

  @override
  String get categoryDeveloper => 'Developer';

  @override
  String get categoryBundle => 'Pakiet';

  @override
  String get categoryOther => 'Inne';

  @override
  String get paymentsTrackedHint =>
      'Płatności będą śledzone po każdym odnowieniu';

  @override
  String get renewsToday => 'Odnawia się dziś';

  @override
  String get renewsTomorrow => 'Odnawia się jutro';

  @override
  String renewsInDays(int days) {
    return 'Odnawia się za $days dni';
  }

  @override
  String renewsOnDate(String date) {
    return 'Odnawia się $date';
  }

  @override
  String get renewedYesterday => 'Odnowiło się wczoraj';

  @override
  String renewedDaysAgo(int days) {
    return 'Odnowiło się $days dni temu';
  }

  @override
  String get discoveryTipsTitle => 'Gdzie szukać subskrypcji';

  @override
  String get discoveryTipBank => 'Wyciąg bankowy';

  @override
  String get discoveryTipBankDesc =>
      'Zrób screenshot transakcji — znajdziemy wszystkie na raz';

  @override
  String get discoveryTipEmail => 'Szukaj w mailu';

  @override
  String get discoveryTipEmailDesc =>
      'Szukaj „subskrypcja”, „rachunek” lub „odnowienie” w skrzynce';

  @override
  String get discoveryTipAppStore => 'App Store / Play Store';

  @override
  String get discoveryTipAppStoreDesc =>
      'Ustawienia → Subskrypcje pokaże aktywne subskrypcje z appów';

  @override
  String get discoveryTipPaypal => 'PayPal i aplikacje płatnicze';

  @override
  String get discoveryTipPaypalDesc =>
      'Sprawdź automatyczne płatności w PayPalu, Revolut lub innej appce';

  @override
  String get sectionAccount => 'KONTO';

  @override
  String get accountAnonymous => 'Anonimowy';

  @override
  String get accountBackupPrompt => 'Zabezpiecz swoje dane';

  @override
  String get accountBackedUp => 'Zabezpieczone';

  @override
  String accountSignedInAs(String email) {
    return 'Zalogowano jako $email';
  }

  @override
  String get syncStatusSyncing => 'Synchronizacja...';

  @override
  String get syncStatusSynced => 'Zsynchronizowano';

  @override
  String syncStatusLastSync(String time) {
    return 'Ostatnia synchronizacja: $time';
  }

  @override
  String get syncStatusOffline => 'Offline';

  @override
  String get syncStatusNeverSynced => 'Jeszcze nie zsynchronizowano';

  @override
  String get signInToBackUp => 'Zaloguj się, by zabezpieczyć dane';

  @override
  String get signInWithApple => 'Zaloguj przez Apple';

  @override
  String get signInWithGoogle => 'Zaloguj przez Google';

  @override
  String get signInWithEmail => 'Zaloguj przez e-mail';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get signOutConfirm =>
      'Czy na pewno chcesz się wylogować? Dane pozostaną na tym urządzeniu.';

  @override
  String get annualSavingsTitle => 'PRZEJDŹ NA ROCZNY';

  @override
  String get annualSavingsSubtitle =>
      'potencjalne oszczędności przy planach rocznych';

  @override
  String annualSavingsCoverage(int matched, int total) {
    return 'Na podstawie $matched z $total subskrypcji';
  }

  @override
  String annualSavingsHint(String name) {
    return 'Sprawdź ustawienia konta $name, aby znaleźć opcję rozliczenia rocznego';
  }

  @override
  String get seeAll => 'Zobacz wszystkie';

  @override
  String get allSavingsTitle => 'Oszczędności roczne';

  @override
  String get allSavingsSubtitle =>
      'Zmień te miesięczne plany na roczne, żeby zaoszczędzić';

  @override
  String get annualPlanLabel => 'PLAN ROCZNY';

  @override
  String annualPlanAvailable(String amount) {
    return 'Dostępny plan roczny — oszczędź $amount/rok';
  }

  @override
  String get noAnnualPlan => 'Brak planu rocznego dla tej usługi';

  @override
  String monthlyVsAnnual(String monthly, String annual) {
    return '$monthly/mies. → $annual/rok';
  }

  @override
  String get perYear => '/rok';

  @override
  String get insightDidYouKnow => 'CZY WIESZ, ŻE...?';

  @override
  String get insightSaveMoney => 'OSZCZĘDŹ';

  @override
  String get insightLearnMore => 'Dowiedz się więcej';

  @override
  String get insightProLabel => 'WSKAZÓWKA PRO';

  @override
  String get insightUnlockPro => 'Odblokuj z Pro';

  @override
  String get insightProTeaser =>
      'Przejdź na Pro, aby otrzymywać spersonalizowane porady oszczędnościowe.';

  @override
  String get insightProTeaserTitle => 'Spersonalizowane porady oszczędnościowe';

  @override
  String trialBannerDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dni',
      few: '$days dni',
      one: '1 dzień',
    );
    return 'Wersja próbna · $_temp0';
  }

  @override
  String get trialBannerExpired => 'Wersja próbna wygasła';

  @override
  String get trialBannerUpgrade => 'Odblokuj';

  @override
  String get trialPromptTitle => 'Wypróbuj wszystko za darmo przez 7 dni';

  @override
  String get trialPromptSubtitle =>
      'Pełny dostęp Pro — bez zobowiązań, bez płatności.';

  @override
  String get trialPromptFeature1 => 'Nieograniczona liczba subskrypcji';

  @override
  String get trialPromptFeature2 => 'Skaner Pułapek AI — bez limitu';

  @override
  String get trialPromptFeature3 => 'Zaawansowane przypomnienia (7d, 3d, 1d)';

  @override
  String get trialPromptFeature4 => 'Panel wydatków i statystyki';

  @override
  String get trialPromptFeature5 => 'Przewodniki anulowania i zwrotów';

  @override
  String get trialPromptFeature6 =>
      'Inteligentne powiadomienia i karty oszczędności';

  @override
  String get trialPromptLegal =>
      'Po 7 dniach: śledź do 3 subskrypcji za darmo, lub odblokuj wszystko za 24,99 zł — jednorazowo, na zawsze.';

  @override
  String get trialPromptCta => 'Rozpocznij bezpłatny okres próbny';

  @override
  String get trialPromptDismiss => 'Pomiń na razie';

  @override
  String get trialExpiredTitle => 'Twój 7-dniowy okres próbny się zakończył';

  @override
  String trialExpiredSubtitle(int count, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subskrypcji',
      few: '$count subskrypcje',
      one: '1 subskrypcję',
    );
    return 'Śledziłeś $_temp0 o wartości $price/mies.';
  }

  @override
  String trialExpiredFrozen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subskrypcji jest zamrożonych',
      few: '$count subskrypcje są zamrożone',
      one: '1 subskrypcja jest zamrożona',
    );
    return '$_temp0';
  }

  @override
  String get trialExpiredCta => 'Odblokuj Chompd Pro — 24,99 zł';

  @override
  String get trialExpiredDismiss => 'Kontynuuj z darmową wersją';

  @override
  String get frozenSectionHeader => 'ZAMROŻONE — ULEPSZ, ABY ODBLOKOWAĆ';

  @override
  String get frozenBadge => 'ZAMROŻONE';

  @override
  String get frozenTapToUpgrade => 'Kliknij, aby ulepszyć';

  @override
  String cancelledStatusExpires(String date) {
    return 'Anulowana — wygasa $date';
  }

  @override
  String cancelledStatusExpired(String date) {
    return 'Anulowana — wygasła $date';
  }

  @override
  String get reactivateSubscription => 'Reaktywuj subskrypcję';

  @override
  String get scanErrorGeneric =>
      'Nie udało się odczytać tego zdjęcia. Spróbuj inny zrzut ekranu.';

  @override
  String get scanErrorEmpty => 'Plik graficzny jest pusty. Spróbuj ponownie.';
}
