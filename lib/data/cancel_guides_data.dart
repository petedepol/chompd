import '../models/cancel_guide.dart';
import '../models/cancel_guide_v2.dart';

/// Pre-loaded cancel guides for the most common services.
///
/// Shipped with the app — updatable via app updates later.
/// ~20 guides covering App Store, Google Play, and major services.
/// Includes PL, DE, FR, ES translations.
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
    stepsLocalized: {
      'pl': [
        'Otwórz aplikację Ustawienia na iPhonie',
        'Dotknij swojego imienia na górze',
        'Dotknij „Subskrypcje"',
        'Znajdź subskrypcję, którą chcesz anulować',
        'Dotknij „Anuluj subskrypcję"',
        'Potwierdź anulowanie',
      ],
      'de': [
        'Öffne die Einstellungen-App auf deinem iPhone',
        'Tippe oben auf deinen Namen',
        'Tippe auf „Abonnements"',
        'Finde das Abonnement, das du kündigen möchtest',
        'Tippe auf „Abo kündigen"',
        'Bestätige die Kündigung',
      ],
      'fr': [
        'Ouvre l\'app Réglages sur ton iPhone',
        'Appuie sur ton nom en haut',
        'Appuie sur « Abonnements »',
        'Trouve l\'abonnement que tu veux annuler',
        'Appuie sur « Annuler l\'abonnement »',
        'Confirme l\'annulation',
      ],
      'es': [
        'Abre la app de Ajustes en tu iPhone',
        'Toca tu nombre en la parte superior',
        'Toca "Suscripciones"',
        'Encuentra la suscripción que quieres cancelar',
        'Toca "Cancelar suscripción"',
        'Confirma la cancelación',
      ],
    },
    notesLocalized: {
      'pl': 'Zachowujesz dostęp do końca bieżącego okresu rozliczeniowego.',
      'de': 'Du behältst den Zugang bis zum Ende deines aktuellen Abrechnungszeitraums.',
      'fr': 'Tu gardes l\'accès jusqu\'à la fin de ta période de facturation en cours.',
      'es': 'Mantienes el acceso hasta el final de tu período de facturación actual.',
    },
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
    stepsLocalized: {
      'pl': [
        'Otwórz aplikację Google Play Store',
        'Dotknij ikony profilu (prawy górny róg)',
        'Dotknij „Płatności i subskrypcje"',
        'Dotknij „Subskrypcje"',
        'Wybierz subskrypcję do anulowania',
        'Dotknij „Anuluj subskrypcję"',
        'Postępuj zgodnie z instrukcjami, aby potwierdzić',
      ],
      'de': [
        'Öffne die Google Play Store App',
        'Tippe auf dein Profilbild (oben rechts)',
        'Tippe auf „Zahlungen und Abos"',
        'Tippe auf „Abos"',
        'Wähle das Abonnement zum Kündigen',
        'Tippe auf „Abo kündigen"',
        'Folge den Anweisungen zur Bestätigung',
      ],
      'fr': [
        'Ouvre l\'appli Google Play Store',
        'Appuie sur ton icône de profil (en haut à droite)',
        'Appuie sur « Paiements et abonnements »',
        'Appuie sur « Abonnements »',
        'Sélectionne l\'abonnement à annuler',
        'Appuie sur « Annuler l\'abonnement »',
        'Suis les instructions pour confirmer',
      ],
      'es': [
        'Abre la app de Google Play Store',
        'Toca tu icono de perfil (arriba a la derecha)',
        'Toca "Pagos y suscripciones"',
        'Toca "Suscripciones"',
        'Selecciona la suscripción a cancelar',
        'Toca "Cancelar suscripción"',
        'Sigue las instrucciones para confirmar',
      ],
    },
    notesLocalized: {
      'pl': 'Dostęp trwa do końca bieżącego okresu rozliczeniowego.',
      'de': 'Der Zugang bleibt bis zum Ende des aktuellen Abrechnungszeitraums bestehen.',
      'fr': 'L\'accès continue jusqu\'à la fin de la période de facturation en cours.',
      'es': 'El acceso continúa hasta el final del período de facturación actual.',
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na netflix.com i zaloguj się',
        'Kliknij ikonę profilu \u2192 „Konto"',
        'Kliknij „Anuluj członkostwo"',
        'Potwierdź anulowanie',
      ],
      'de': [
        'Gehe auf netflix.com und melde dich an',
        'Klicke auf dein Profilbild \u2192 „Konto"',
        'Klicke auf „Mitgliedschaft kündigen"',
        'Bestätige die Kündigung',
      ],
      'fr': [
        'Va sur netflix.com et connecte-toi',
        'Clique sur ton icône de profil \u2192 « Compte »',
        'Clique sur « Annuler l\'abonnement »',
        'Confirme l\'annulation',
      ],
      'es': [
        'Ve a netflix.com e inicia sesión',
        'Haz clic en tu icono de perfil \u2192 "Cuenta"',
        'Haz clic en "Cancelar membresía"',
        'Confirma la cancelación',
      ],
    },
    notesLocalized: {
      'pl': 'Możesz oglądać do końca okresu rozliczeniowego. Netflix zachowuje twój profil przez 10 miesięcy.',
      'de': 'Du kannst bis zum Ende deines Abrechnungszeitraums weiterschauen. Netflix speichert dein Profil 10 Monate lang.',
      'fr': 'Tu peux regarder jusqu\'à la fin de ta période de facturation. Netflix conserve ton profil pendant 10 mois.',
      'es': 'Puedes ver contenido hasta el final de tu período de facturación. Netflix guarda tu perfil durante 10 meses.',
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na spotify.com/account',
        'Kliknij „Twój plan"',
        'Kliknij „Anuluj Premium" (lub „Anuluj plan")',
        'Potwierdź \u2014 zachowasz Premium do końca okresu rozliczeniowego',
      ],
      'de': [
        'Gehe auf spotify.com/account',
        'Klicke auf „Dein Abo"',
        'Klicke auf „Premium kündigen" (oder „Abo kündigen")',
        'Bestätige \u2014 du behältst Premium bis zum Ende des Abrechnungszeitraums',
      ],
      'fr': [
        'Va sur spotify.com/account',
        'Clique sur « Ton abonnement »',
        'Clique sur « Annuler Premium » (ou « Annuler l\'abonnement »)',
        'Confirme \u2014 tu gardes Premium jusqu\'à la fin de la période de facturation',
      ],
      'es': [
        'Ve a spotify.com/account',
        'Haz clic en "Tu plan"',
        'Haz clic en "Cancelar Premium" (o "Cancelar plan")',
        'Confirma \u2014 mantendrás Premium hasta el final del período de facturación',
      ],
    },
    notesLocalized: {
      'pl': 'Nie można anulować przez aplikację \u2014 musisz użyć strony internetowej. Wrócisz do darmowego planu z reklamami.',
      'de': 'Kann nicht über die App gekündigt werden \u2014 du musst die Website nutzen. Du wechselst zum kostenlosen Tarif mit Werbung.',
      'fr': 'Impossible d\'annuler via l\'appli \u2014 tu dois utiliser le site web. Tu reviens au niveau gratuit avec publicités.',
      'es': 'No se puede cancelar desde la app \u2014 debes usar la web. Vuelves al nivel gratuito con anuncios.',
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na amazon.co.uk/prime',
        'Kliknij „Zarządzaj członkostwem"',
        'Kliknij „Zmień, anuluj i więcej"',
        'Kliknij „Zakończ członkostwo"',
        'Potwierdź przez kilka ekranów „czy na pewno"',
      ],
      'de': [
        'Gehe auf amazon.de/prime',
        'Klicke auf „Mitgliedschaft verwalten"',
        'Klicke auf „Ändern, kündigen und mehr"',
        'Klicke auf „Mitgliedschaft beenden"',
        'Bestätige durch mehrere „Bist du sicher"-Bildschirme',
      ],
      'fr': [
        'Va sur amazon.fr/prime',
        'Clique sur « Gérer mon abonnement »',
        'Clique sur « Modifier, annuler et plus »',
        'Clique sur « Mettre fin à l\'abonnement »',
        'Confirme en passant plusieurs écrans de confirmation',
      ],
      'es': [
        'Ve a amazon.es/prime',
        'Haz clic en "Administrar membresía"',
        'Haz clic en "Actualizar, cancelar y más"',
        'Haz clic en "Finalizar membresía"',
        'Confirma a través de varias pantallas de "¿estás seguro?"',
      ],
    },
    notesLocalized: {
      'pl': 'Amazon pokazuje kilka ofert zatrzymania \u2014 klikaj dalej, żeby faktycznie anulować. Możesz otrzymać częściowy zwrot, jeśli nie korzystałeś.',
      'de': 'Amazon zeigt mehrere Halte-Angebote \u2014 klicke weiter, um tatsächlich zu kündigen. Bei Nichtnutzung ist eine teilweise Rückerstattung möglich.',
      'fr': 'Amazon affiche plusieurs offres de rétention \u2014 continue de cliquer pour vraiment annuler. Tu peux obtenir un remboursement partiel si non utilisé.',
      'es': 'Amazon muestra varias ofertas de retención \u2014 sigue haciendo clic para cancelar realmente. Puedes obtener un reembolso parcial si no lo usaste.',
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na account.adobe.com/plans',
        'Kliknij „Zarządzaj planem" obok subskrypcji',
        'Kliknij „Anuluj plan"',
        'Wybierz powód',
        'Sprawdź opłatę za wcześniejsze rozwiązanie (jeśli masz plan roczny)',
        'Potwierdź anulowanie',
      ],
      'de': [
        'Gehe auf account.adobe.com/plans',
        'Klicke auf „Abo verwalten" neben deinem Abonnement',
        'Klicke auf „Abo kündigen"',
        'Wähle einen Grund',
        'Prüfe die Gebühr für vorzeitige Kündigung (bei Jahresabo)',
        'Bestätige die Kündigung',
      ],
      'fr': [
        'Va sur account.adobe.com/plans',
        'Clique sur « Gérer le forfait » à côté de ton abonnement',
        'Clique sur « Annuler le forfait »',
        'Choisis une raison',
        'Vérifie les frais de résiliation anticipée (si abonnement annuel)',
        'Confirme l\'annulation',
      ],
      'es': [
        'Ve a account.adobe.com/plans',
        'Haz clic en "Administrar plan" junto a tu suscripción',
        'Haz clic en "Cancelar plan"',
        'Elige un motivo',
        'Revisa la tarifa por cancelación anticipada (si tienes plan anual)',
        'Confirma la cancelación',
      ],
    },
    notesLocalized: {
      'pl': 'Plany roczne rozliczane miesięcznie mają opłatę za wcześniejsze rozwiązanie (50% pozostałych miesięcy). Zmień najpierw na plan miesięczny, jeśli to możliwe.',
      'de': 'Jahrespläne mit monatlicher Zahlung haben eine Gebühr für vorzeitige Kündigung (50% der verbleibenden Monate). Wechsle zuerst zum Monatsabo, wenn möglich.',
      'fr': 'Les forfaits annuels facturés mensuellement ont des frais de résiliation anticipée (50% des mois restants). Passe d\'abord au forfait mensuel si possible.',
      'es': 'Los planes anuales con cobro mensual tienen una tarifa por cancelación anticipada (50% de los meses restantes). Cambia primero a plan mensual si es posible.',
    },
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
    stepsLocalized: {
      'pl': [
        'Otwórz Ustawienia na iPhonie',
        'Dotknij swojego imienia \u2192 „Subskrypcje"',
        'Dotknij „Apple One"',
        'Dotknij „Anuluj wszystkie usługi" lub „Anuluj poszczególne usługi"',
        'Potwierdź',
      ],
      'de': [
        'Öffne Einstellungen auf deinem iPhone',
        'Tippe auf deinen Namen \u2192 „Abonnements"',
        'Tippe auf „Apple One"',
        'Tippe auf „Alle Dienste kündigen" oder „Einzelne Dienste kündigen"',
        'Bestätige',
      ],
      'fr': [
        'Ouvre Réglages sur ton iPhone',
        'Appuie sur ton nom \u2192 « Abonnements »',
        'Appuie sur « Apple One »',
        'Appuie sur « Annuler tous les services » ou « Annuler des services individuels »',
        'Confirme',
      ],
      'es': [
        'Abre Ajustes en tu iPhone',
        'Toca tu nombre \u2192 "Suscripciones"',
        'Toca "Apple One"',
        'Toca "Cancelar todos los servicios" o "Cancelar servicios individuales"',
        'Confirma',
      ],
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na youtube.com/paid_memberships',
        'Kliknij „Zarządzaj członkostwem"',
        'Kliknij „Dezaktywuj"',
        'Potwierdź anulowanie',
      ],
      'de': [
        'Gehe auf youtube.com/paid_memberships',
        'Klicke auf „Mitgliedschaft verwalten"',
        'Klicke auf „Deaktivieren"',
        'Bestätige die Kündigung',
      ],
      'fr': [
        'Va sur youtube.com/paid_memberships',
        'Clique sur « Gérer l\'abonnement »',
        'Clique sur « Désactiver »',
        'Confirme l\'annulation',
      ],
      'es': [
        'Ve a youtube.com/paid_memberships',
        'Haz clic en "Administrar membresía"',
        'Haz clic en "Desactivar"',
        'Confirma la cancelación',
      ],
    },
    notesLocalized: {
      'pl': 'Jeśli subskrybujesz przez iOS, anuluj w Ustawienia \u2192 Subskrypcje.',
      'de': 'Wenn du über iOS abonniert hast, kündige über Einstellungen \u2192 Abonnements.',
      'fr': 'Si tu es abonné via iOS, annule dans Réglages \u2192 Abonnements.',
      'es': 'Si te suscribiste a través de iOS, cancela en Ajustes \u2192 Suscripciones.',
    },
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
    stepsLocalized: {
      'pl': [
        'Otwórz aplikację Disney+ lub przejdź na disneyplus.com',
        'Przejdź do Profilu \u2192 Konto',
        'Wybierz swoją subskrypcję',
        'Kliknij „Anuluj subskrypcję"',
        'Potwierdź',
      ],
      'de': [
        'Öffne die Disney+-App oder gehe auf disneyplus.com',
        'Gehe zu Profil \u2192 Konto',
        'Wähle dein Abonnement',
        'Klicke auf „Abo kündigen"',
        'Bestätige',
      ],
      'fr': [
        'Ouvre l\'appli Disney+ ou va sur disneyplus.com',
        'Va dans Profil \u2192 Compte',
        'Sélectionne ton abonnement',
        'Clique sur « Annuler l\'abonnement »',
        'Confirme',
      ],
      'es': [
        'Abre la app de Disney+ o ve a disneyplus.com',
        'Ve a Perfil \u2192 Cuenta',
        'Selecciona tu suscripción',
        'Haz clic en "Cancelar suscripción"',
        'Confirma',
      ],
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na chat.openai.com',
        'Kliknij swój profil (lewy dolny róg)',
        'Kliknij „Mój plan"',
        'Kliknij „Zarządzaj subskrypcją"',
        'Kliknij „Anuluj plan"',
      ],
      'de': [
        'Gehe auf chat.openai.com',
        'Klicke auf dein Profil (unten links)',
        'Klicke auf „Mein Abo"',
        'Klicke auf „Mein Abo verwalten"',
        'Klicke auf „Abo kündigen"',
      ],
      'fr': [
        'Va sur chat.openai.com',
        'Clique sur ton profil (en bas à gauche)',
        'Clique sur « Mon abonnement »',
        'Clique sur « Gérer mon abonnement »',
        'Clique sur « Annuler l\'abonnement »',
      ],
      'es': [
        'Ve a chat.openai.com',
        'Haz clic en tu perfil (abajo a la izquierda)',
        'Haz clic en "Mi plan"',
        'Haz clic en "Administrar mi suscripción"',
        'Haz clic en "Cancelar plan"',
      ],
    },
    notesLocalized: {
      'pl': 'Jeśli subskrybujesz przez App Store, anuluj w Ustawienia \u2192 Subskrypcje.',
      'de': 'Wenn du über den App Store abonniert hast, kündige über Einstellungen \u2192 Abonnements.',
      'fr': 'Si tu es abonné via l\'App Store, annule dans Réglages \u2192 Abonnements.',
      'es': 'Si te suscribiste a través del App Store, cancela en Ajustes \u2192 Suscripciones.',
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na account.microsoft.com/services',
        'Znajdź swoją subskrypcję Game Pass',
        'Kliknij „Zarządzaj"',
        'Kliknij „Anuluj subskrypcję"',
        'Postępuj zgodnie z instrukcjami (Microsoft pokazuje kilka ekranów zatrzymania)',
      ],
      'de': [
        'Gehe auf account.microsoft.com/services',
        'Finde dein Game-Pass-Abonnement',
        'Klicke auf „Verwalten"',
        'Klicke auf „Abonnement kündigen"',
        'Folge den Anweisungen (Microsoft zeigt mehrere Halte-Bildschirme)',
      ],
      'fr': [
        'Va sur account.microsoft.com/services',
        'Trouve ton abonnement Game Pass',
        'Clique sur « Gérer »',
        'Clique sur « Annuler l\'abonnement »',
        'Suis les instructions (Microsoft affiche plusieurs écrans de rétention)',
      ],
      'es': [
        'Ve a account.microsoft.com/services',
        'Encuentra tu suscripción de Game Pass',
        'Haz clic en "Administrar"',
        'Haz clic en "Cancelar suscripción"',
        'Sigue las instrucciones (Microsoft muestra varias pantallas de retención)',
      ],
    },
    notesLocalized: {
      'pl': 'Microsoft wymusza przejście przez 3\u20134 ekrany zatrzymania. Klikaj dalej.',
      'de': 'Microsoft lässt dich durch 3\u20134 Halte-Bildschirme klicken. Mach einfach weiter.',
      'fr': 'Microsoft te fait passer par 3\u20134 écrans de rétention. Continue de cliquer.',
      'es': 'Microsoft te hace pasar por 3\u20134 pantallas de retención. Sigue adelante.',
    },
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
    stepsLocalized: {
      'pl': [
        'Sprawdź umowę pod kątem polityki anulowania i okresu wypowiedzenia',
        'Większość siłowni wymaga pisemnego wypowiedzenia (e-mail lub list)',
        'Wyślij e-mail z wypowiedzeniem do działu członkostwa siłowni',
        'Poproś o pisemne potwierdzenie anulowania',
        'Uwaga: wiele siłowni wymaga 30 dni wypowiedzenia \u2014 możesz musieć zapłacić jeszcze jedną ratę',
      ],
      'de': [
        'Prüfe deinen Vertrag auf die Kündigungsbedingungen und Kündigungsfrist',
        'Die meisten Fitnessstudios erfordern eine schriftliche Kündigung (E-Mail oder Brief)',
        'Sende die Kündigung per E-Mail an das Mitgliedschaftsteam',
        'Bitte um schriftliche Bestätigung der Kündigung',
        'Hinweis: Viele Studios verlangen 30 Tage Kündigungsfrist \u2014 eine weitere Zahlung kann fällig sein',
      ],
      'fr': [
        'Vérifie ton contrat pour la politique d\'annulation et le préavis',
        'La plupart des salles de sport exigent un préavis écrit (e-mail ou lettre)',
        'Envoie un e-mail d\'annulation à l\'équipe d\'adhésion de la salle',
        'Demande une confirmation écrite de l\'annulation',
        'Note : beaucoup de salles exigent 30 jours de préavis \u2014 tu devras peut-être payer un mois de plus',
      ],
      'es': [
        'Revisa tu contrato para la política de cancelación y período de aviso',
        'La mayoría de los gimnasios requieren aviso por escrito (correo o carta)',
        'Envía un correo de cancelación al equipo de membresía del gimnasio',
        'Solicita confirmación por escrito de la cancelación',
        'Nota: muchos gimnasios requieren 30 días de aviso \u2014 puede que debas un pago más',
      ],
    },
    notesLocalized: {
      'pl': 'Polityki anulowania siłowni bardzo się różnią. Sprawdź umowę pod kątem okresu wypowiedzenia i opłat za anulowanie.',
      'de': 'Die Kündigungsbedingungen von Fitnessstudios variieren stark. Prüfe deinen Vertrag auf Kündigungsfrist und mögliche Gebühren.',
      'fr': 'Les politiques d\'annulation des salles de sport varient énormément. Vérifie ton contrat pour le préavis et les frais éventuels.',
      'es': 'Las políticas de cancelación de gimnasios varían mucho. Revisa tu contrato para el período de aviso y las posibles tarifas.',
    },
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
    stepsLocalized: {
      'pl': [
        'Otwórz Ustawienia na iPhonie',
        'Dotknij swojego imienia \u2192 „Subskrypcje"',
        'Dotknij „Apple Music"',
        'Dotknij „Anuluj subskrypcję"',
        'Potwierdź',
      ],
      'de': [
        'Öffne Einstellungen auf deinem iPhone',
        'Tippe auf deinen Namen \u2192 „Abonnements"',
        'Tippe auf „Apple Music"',
        'Tippe auf „Abo kündigen"',
        'Bestätige',
      ],
      'fr': [
        'Ouvre Réglages sur ton iPhone',
        'Appuie sur ton nom \u2192 « Abonnements »',
        'Appuie sur « Apple Music »',
        'Appuie sur « Annuler l\'abonnement »',
        'Confirme',
      ],
      'es': [
        'Abre Ajustes en tu iPhone',
        'Toca tu nombre \u2192 "Suscripciones"',
        'Toca "Apple Music"',
        'Toca "Cancelar suscripción"',
        'Confirma',
      ],
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na amazon.co.uk/music/settings',
        'Znajdź „Amazon Music Unlimited"',
        'Kliknij „Anuluj subskrypcję"',
        'Potwierdź, przechodząc przez ekrany zatrzymania',
      ],
      'de': [
        'Gehe auf amazon.de/music/settings',
        'Finde „Amazon Music Unlimited"',
        'Klicke auf „Abonnement kündigen"',
        'Bestätige durch die Halte-Bildschirme',
      ],
      'fr': [
        'Va sur amazon.fr/music/settings',
        'Trouve « Amazon Music Unlimited »',
        'Clique sur « Annuler l\'abonnement »',
        'Confirme en passant les écrans de rétention',
      ],
      'es': [
        'Ve a amazon.es/music/settings',
        'Encuentra "Amazon Music Unlimited"',
        'Haz clic en "Cancelar suscripción"',
        'Confirma pasando las pantallas de retención',
      ],
    },
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
    stepsLocalized: {
      'pl': [
        'Otwórz Ustawienia na iPhonie',
        'Dotknij swojego imienia \u2192 „iCloud"',
        'Dotknij „Zarządzaj pamięcią konta" lub „Zarządzaj pamięcią"',
        'Dotknij „Zmień plan pamięci"',
        'Dotknij „Opcje obniżenia"',
        'Wybierz „Darmowe 5 GB" i potwierdź',
      ],
      'de': [
        'Öffne Einstellungen auf deinem iPhone',
        'Tippe auf deinen Namen \u2192 „iCloud"',
        'Tippe auf „Speicher verwalten" oder „Account-Speicher verwalten"',
        'Tippe auf „Speicherplan ändern"',
        'Tippe auf „Downgrade-Optionen"',
        'Wähle „Kostenlos 5 GB" und bestätige',
      ],
      'fr': [
        'Ouvre Réglages sur ton iPhone',
        'Appuie sur ton nom \u2192 « iCloud »',
        'Appuie sur « Gérer le stockage du compte » ou « Gérer le stockage »',
        'Appuie sur « Changer de forfait de stockage »',
        'Appuie sur « Options de rétrogradation »',
        'Sélectionne « Gratuit 5 Go » et confirme',
      ],
      'es': [
        'Abre Ajustes en tu iPhone',
        'Toca tu nombre \u2192 "iCloud"',
        'Toca "Administrar almacenamiento" o "Gestionar almacenamiento"',
        'Toca "Cambiar plan de almacenamiento"',
        'Toca "Opciones de reducción"',
        'Selecciona "Gratis 5 GB" y confirma',
      ],
    },
    notesLocalized: {
      'pl': 'Musisz zmniejszyć użycie iCloud poniżej 5 GB, inaczej twoje dane mogą zostać usunięte po 30 dniach.',
      'de': 'Du musst deinen iCloud-Verbrauch unter 5 GB reduzieren, sonst können deine Daten nach 30 Tagen gelöscht werden.',
      'fr': 'Tu devras réduire ton utilisation iCloud en dessous de 5 Go sinon tes données pourraient être supprimées après 30 jours.',
      'es': 'Necesitarás reducir tu uso de iCloud por debajo de 5 GB o tus datos podrían eliminarse después de 30 días.',
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na account.nowtv.com',
        'Kliknij „Passy i kupony"',
        'Wybierz pass, który chcesz anulować',
        'Kliknij „Anuluj pass"',
        'Potwierdź',
      ],
      'de': [
        'Gehe auf account.nowtv.com',
        'Klicke auf „Pässe & Gutscheine"',
        'Wähle den Pass, den du kündigen möchtest',
        'Klicke auf „Pass kündigen"',
        'Bestätige',
      ],
      'fr': [
        'Va sur account.nowtv.com',
        'Clique sur « Pass et bons »',
        'Sélectionne le pass que tu veux annuler',
        'Clique sur « Annuler le pass »',
        'Confirme',
      ],
      'es': [
        'Ve a account.nowtv.com',
        'Haz clic en "Pases y cupones"',
        'Selecciona el pase que quieres cancelar',
        'Haz clic en "Cancelar pase"',
        'Confirma',
      ],
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na audible.co.uk/account',
        'Kliknij „Anuluj członkostwo" (na dole)',
        'Wybierz powód',
        'Przejrzyj oferty zatrzymania',
        'Potwierdź anulowanie',
      ],
      'de': [
        'Gehe auf audible.de/account',
        'Klicke auf „Mitgliedschaft kündigen" (unten)',
        'Wähle einen Grund',
        'Prüfe eventuelle Halte-Angebote',
        'Bestätige die Kündigung',
      ],
      'fr': [
        'Va sur audible.fr/account',
        'Clique sur « Annuler l\'abonnement » (en bas)',
        'Choisis une raison',
        'Passe en revue les offres de rétention',
        'Confirme l\'annulation',
      ],
      'es': [
        'Ve a audible.co.uk/account',
        'Haz clic en "Cancelar membresía" (en la parte inferior)',
        'Selecciona un motivo',
        'Revisa las ofertas de retención',
        'Confirma la cancelación',
      ],
    },
    notesLocalized: {
      'pl': 'Audible może zaoferować obniżoną cenę lub darmowy miesiąc, żebyś został. Zachowujesz niewykorzystane kredyty.',
      'de': 'Audible bietet dir möglicherweise einen Rabatt oder einen Gratismonat an. Du behältst nicht genutzte Credits.',
      'fr': 'Audible peut te proposer un tarif réduit ou un mois gratuit. Tu conserves tes crédits non utilisés.',
      'es': 'Audible puede ofrecerte un precio reducido o un mes gratis. Conservas los créditos no utilizados.',
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na linkedin.com/mypreferences/d/manage-premium',
        'Kliknij „Anuluj subskrypcję"',
        'Postępuj zgodnie z instrukcjami',
        'Potwierdź anulowanie',
      ],
      'de': [
        'Gehe auf linkedin.com/mypreferences/d/manage-premium',
        'Klicke auf „Abonnement kündigen"',
        'Folge den Anweisungen',
        'Bestätige die Kündigung',
      ],
      'fr': [
        'Va sur linkedin.com/mypreferences/d/manage-premium',
        'Clique sur « Annuler l\'abonnement »',
        'Suis les instructions',
        'Confirme l\'annulation',
      ],
      'es': [
        'Ve a linkedin.com/mypreferences/d/manage-premium',
        'Haz clic en "Cancelar suscripción"',
        'Sigue las instrucciones',
        'Confirma la cancelación',
      ],
    },
    notesLocalized: {
      'pl': 'Funkcje Premium są dostępne do końca okresu rozliczeniowego.',
      'de': 'Premium-Funktionen bleiben bis zum Ende des Abrechnungszeitraums erhalten.',
      'fr': 'Les fonctionnalités Premium restent disponibles jusqu\'à la fin de la période de facturation.',
      'es': 'Las funciones Premium se mantienen hasta el final del período de facturación.',
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na paramountplus.com/account',
        'Kliknij „Anuluj subskrypcję"',
        'Potwierdź anulowanie',
      ],
      'de': [
        'Gehe auf paramountplus.com/account',
        'Klicke auf „Abonnement kündigen"',
        'Bestätige die Kündigung',
      ],
      'fr': [
        'Va sur paramountplus.com/account',
        'Clique sur « Annuler l\'abonnement »',
        'Confirme l\'annulation',
      ],
      'es': [
        'Ve a paramountplus.com/account',
        'Haz clic en "Cancelar suscripción"',
        'Confirma la cancelación',
      ],
    },
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
    stepsLocalized: {
      'pl': [
        'Przejdź na crunchyroll.com/account',
        'Kliknij „Subskrypcja i płatności"',
        'Kliknij „Anuluj subskrypcję"',
        'Potwierdź',
      ],
      'de': [
        'Gehe auf crunchyroll.com/account',
        'Klicke auf „Abonnement & Abrechnung"',
        'Klicke auf „Abonnement kündigen"',
        'Bestätige',
      ],
      'fr': [
        'Va sur crunchyroll.com/account',
        'Clique sur « Abonnement et facturation »',
        'Clique sur « Annuler l\'abonnement »',
        'Confirme',
      ],
      'es': [
        'Ve a crunchyroll.com/account',
        'Haz clic en "Suscripción y facturación"',
        'Haz clic en "Cancelar suscripción"',
        'Confirma',
      ],
    },
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

/// Convert a v1 [CancelGuide] to v2 [CancelGuideData] with translations.
///
/// The v1 data has full translations for PL, DE, FR, ES as flat step lists.
/// This converter maps them into the v2 per-step localisation maps so the
/// cancel guide screen renders localised content.
CancelGuideData cancelGuideToV2(CancelGuide guide) {
  final steps = <CancelGuideStep>[];

  for (var i = 0; i < guide.steps.length; i++) {
    final titleLocalised = <String, String>{};
    final detailLocalised = <String, String>{};

    for (final entry in guide.stepsLocalized.entries) {
      final langCode = entry.key;
      final langSteps = entry.value;
      if (i < langSteps.length) {
        titleLocalised[langCode] = langSteps[i];
        detailLocalised[langCode] = langSteps[i];
      }
    }

    steps.add(CancelGuideStep(
      step: i + 1,
      title: guide.steps[i],
      detail: guide.steps[i],
      deeplink: i == 0 ? (guide.deepLink ?? guide.cancellationUrl) : null,
      titleLocalized: titleLocalised,
      detailLocalized: detailLocalised,
    ));
  }

  return CancelGuideData(
    platform: guide.platform,
    steps: steps,
    cancelDeeplink: guide.deepLink,
    cancelWebUrl: guide.cancellationUrl,
    warningText: guide.notes,
    warningTextLocalized: guide.notesLocalized,
  );
}

/// Find a v1 cancel guide for [name] and convert to v2 with translations.
///
/// Returns null if no matching v1 guide exists.
CancelGuideData? findTranslatedCancelGuide(String name) {
  final normalised = name.toLowerCase().trim();
  final slug = normalised.replaceAll(' ', '_');

  // Direct slug match
  for (final g in cancelGuidesData) {
    if (g.serviceName == slug) return cancelGuideToV2(g);
  }

  // Partial match
  for (final g in cancelGuidesData) {
    final gName = g.serviceName.replaceAll('_', ' ');
    if (normalised.contains(gName) || gName.contains(normalised)) {
      return cancelGuideToV2(g);
    }
  }

  return null;
}
