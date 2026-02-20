import '../models/cancel_guide_v2.dart';

/// Generic cancel guides for unmatched services.
///
/// When a subscription isn't in our Supabase service database, these
/// platform-based guides provide helpful general cancellation steps.
/// Same format as service-specific guides so the UI renders identically.
///
/// Includes translations for PL, DE, FR, ES.

const List<CancelGuideData> genericCancelGuides = [
  // ─── iOS (App Store subscriptions) ───
  CancelGuideData(
    platform: 'ios',
    steps: [
      CancelGuideStep(
        step: 1,
        title: 'Open Settings',
        detail: 'Open the Settings app on your iPhone or iPad.',
        titleLocalized: {
          'pl': 'Otwórz Ustawienia',
          'de': 'Öffne Einstellungen',
          'fr': 'Ouvre Réglages',
          'es': 'Abre Ajustes',
        },
        detailLocalized: {
          'pl': 'Otwórz aplikację Ustawienia na swoim iPhonie lub iPadzie.',
          'de': 'Öffne die Einstellungen-App auf deinem iPhone oder iPad.',
          'fr': 'Ouvre l\'app Réglages sur ton iPhone ou iPad.',
          'es': 'Abre la app de Ajustes en tu iPhone o iPad.',
        },
      ),
      CancelGuideStep(
        step: 2,
        title: 'Tap your name',
        detail: 'Tap your name (Apple ID) at the very top of Settings.',
        titleLocalized: {
          'pl': 'Dotknij swojego imienia',
          'de': 'Tippe auf deinen Namen',
          'fr': 'Appuie sur ton nom',
          'es': 'Toca tu nombre',
        },
        detailLocalized: {
          'pl': 'Dotknij swojego imienia (Apple ID) na samej górze Ustawień.',
          'de': 'Tippe auf deinen Namen (Apple-ID) ganz oben in den Einstellungen.',
          'fr': 'Appuie sur ton nom (identifiant Apple) tout en haut des Réglages.',
          'es': 'Toca tu nombre (Apple ID) en la parte superior de Ajustes.',
        },
      ),
      CancelGuideStep(
        step: 3,
        title: 'Tap "Subscriptions"',
        detail: 'You\'ll see a list of all your active and expired subscriptions.',
        titleLocalized: {
          'pl': 'Dotknij „Subskrypcje"',
          'de': 'Tippe auf „Abonnements"',
          'fr': 'Appuie sur « Abonnements »',
          'es': 'Toca "Suscripciones"',
        },
        detailLocalized: {
          'pl': 'Zobaczysz listę wszystkich aktywnych i wygasłych subskrypcji.',
          'de': 'Du siehst eine Liste aller aktiven und abgelaufenen Abonnements.',
          'fr': 'Tu verras la liste de tous tes abonnements actifs et expirés.',
          'es': 'Verás una lista de todas tus suscripciones activas y expiradas.',
        },
      ),
      CancelGuideStep(
        step: 4,
        title: 'Find the subscription',
        detail: 'Scroll through the list and tap the subscription you want to cancel.',
        titleLocalized: {
          'pl': 'Znajdź subskrypcję',
          'de': 'Finde das Abonnement',
          'fr': 'Trouve l\'abonnement',
          'es': 'Encuentra la suscripción',
        },
        detailLocalized: {
          'pl': 'Przewiń listę i dotknij subskrypcji, którą chcesz anulować.',
          'de': 'Scrolle durch die Liste und tippe auf das Abonnement, das du kündigen möchtest.',
          'fr': 'Fais défiler la liste et appuie sur l\'abonnement que tu veux annuler.',
          'es': 'Desplázate por la lista y toca la suscripción que quieres cancelar.',
        },
      ),
      CancelGuideStep(
        step: 5,
        title: 'Tap "Cancel Subscription"',
        detail: 'Scroll down and tap the cancel option. It may say "Cancel Subscription" or "Cancel Free Trial".',
        titleLocalized: {
          'pl': 'Dotknij „Anuluj subskrypcję"',
          'de': 'Tippe auf „Abo kündigen"',
          'fr': 'Appuie sur « Annuler l\'abonnement »',
          'es': 'Toca "Cancelar suscripción"',
        },
        detailLocalized: {
          'pl': 'Przewiń w dół i dotknij opcji anulowania. Może mówić „Anuluj subskrypcję" lub „Anuluj bezpłatny okres próbny".',
          'de': 'Scrolle nach unten und tippe auf die Kündigen-Option. Es kann „Abo kündigen" oder „Probeabo kündigen" heißen.',
          'fr': 'Fais défiler vers le bas et appuie sur l\'option d\'annulation. Elle peut dire « Annuler l\'abonnement » ou « Annuler l\'essai gratuit ».',
          'es': 'Desplázate hacia abajo y toca la opción de cancelar. Puede decir "Cancelar suscripción" o "Cancelar prueba gratuita".',
        },
      ),
      CancelGuideStep(
        step: 6,
        title: 'Confirm cancellation',
        detail: 'Tap "Confirm" to finalise. You\'ll keep access until the end of your current billing period.',
        titleLocalized: {
          'pl': 'Potwierdź anulowanie',
          'de': 'Bestätige die Kündigung',
          'fr': 'Confirme l\'annulation',
          'es': 'Confirma la cancelación',
        },
        detailLocalized: {
          'pl': 'Dotknij „Potwierdź", aby sfinalizować. Zachowasz dostęp do końca bieżącego okresu rozliczeniowego.',
          'de': 'Tippe auf „Bestätigen". Du behältst den Zugang bis zum Ende deines aktuellen Abrechnungszeitraums.',
          'fr': 'Appuie sur « Confirmer » pour finaliser. Tu gardes l\'accès jusqu\'à la fin de ta période de facturation en cours.',
          'es': 'Toca "Confirmar" para finalizar. Mantendrás el acceso hasta el final de tu período de facturación actual.',
        },
      ),
    ],
    cancelDeeplink: 'itms-apps://apps.apple.com/account/subscriptions',
    proTip: 'You keep access until the end of your current billing period. Cancelling early won\'t give you a partial refund.',
    proTipLocalized: {
      'pl': 'Zachowujesz dostęp do końca bieżącego okresu rozliczeniowego. Wcześniejsze anulowanie nie daje częściowego zwrotu.',
      'de': 'Du behältst den Zugang bis zum Ende deines aktuellen Abrechnungszeitraums. Früheres Kündigen gibt keine teilweise Rückerstattung.',
      'fr': 'Tu gardes l\'accès jusqu\'à la fin de ta période de facturation. Annuler plus tôt ne te donne pas de remboursement partiel.',
      'es': 'Mantienes el acceso hasta el final de tu período de facturación. Cancelar antes no te da un reembolso parcial.',
    },
  ),

  // ─── Android (Google Play subscriptions) ───
  CancelGuideData(
    platform: 'android',
    steps: [
      CancelGuideStep(
        step: 1,
        title: 'Open Google Play Store',
        detail: 'Open the Play Store app on your Android device.',
        titleLocalized: {
          'pl': 'Otwórz Google Play Store',
          'de': 'Öffne den Google Play Store',
          'fr': 'Ouvre le Google Play Store',
          'es': 'Abre Google Play Store',
        },
        detailLocalized: {
          'pl': 'Otwórz aplikację Play Store na swoim urządzeniu Android.',
          'de': 'Öffne die Play-Store-App auf deinem Android-Gerät.',
          'fr': 'Ouvre l\'appli Play Store sur ton appareil Android.',
          'es': 'Abre la app de Play Store en tu dispositivo Android.',
        },
      ),
      CancelGuideStep(
        step: 2,
        title: 'Tap your profile icon',
        detail: 'Tap your profile picture or initial in the top right corner.',
        titleLocalized: {
          'pl': 'Dotknij ikony profilu',
          'de': 'Tippe auf dein Profilbild',
          'fr': 'Appuie sur ton icône de profil',
          'es': 'Toca tu icono de perfil',
        },
        detailLocalized: {
          'pl': 'Dotknij zdjęcia profilowego lub inicjału w prawym górnym rogu.',
          'de': 'Tippe auf dein Profilbild oder deinen Anfangsbuchstaben oben rechts.',
          'fr': 'Appuie sur ta photo de profil ou ton initiale en haut à droite.',
          'es': 'Toca tu foto de perfil o inicial en la esquina superior derecha.',
        },
      ),
      CancelGuideStep(
        step: 3,
        title: 'Tap "Payments & subscriptions"',
        detail: 'Select "Payments & subscriptions" from the menu.',
        titleLocalized: {
          'pl': 'Dotknij „Płatności i subskrypcje"',
          'de': 'Tippe auf „Zahlungen und Abos"',
          'fr': 'Appuie sur « Paiements et abonnements »',
          'es': 'Toca "Pagos y suscripciones"',
        },
        detailLocalized: {
          'pl': 'Wybierz „Płatności i subskrypcje" z menu.',
          'de': 'Wähle „Zahlungen und Abos" aus dem Menü.',
          'fr': 'Sélectionne « Paiements et abonnements » dans le menu.',
          'es': 'Selecciona "Pagos y suscripciones" en el menú.',
        },
      ),
      CancelGuideStep(
        step: 4,
        title: 'Tap "Subscriptions"',
        detail: 'You\'ll see all your active Google Play subscriptions.',
        titleLocalized: {
          'pl': 'Dotknij „Subskrypcje"',
          'de': 'Tippe auf „Abos"',
          'fr': 'Appuie sur « Abonnements »',
          'es': 'Toca "Suscripciones"',
        },
        detailLocalized: {
          'pl': 'Zobaczysz wszystkie swoje aktywne subskrypcje Google Play.',
          'de': 'Du siehst alle deine aktiven Google-Play-Abonnements.',
          'fr': 'Tu verras tous tes abonnements Google Play actifs.',
          'es': 'Verás todas tus suscripciones activas de Google Play.',
        },
      ),
      CancelGuideStep(
        step: 5,
        title: 'Find the subscription',
        detail: 'Tap the subscription you want to cancel.',
        titleLocalized: {
          'pl': 'Znajdź subskrypcję',
          'de': 'Finde das Abonnement',
          'fr': 'Trouve l\'abonnement',
          'es': 'Encuentra la suscripción',
        },
        detailLocalized: {
          'pl': 'Dotknij subskrypcji, którą chcesz anulować.',
          'de': 'Tippe auf das Abonnement, das du kündigen möchtest.',
          'fr': 'Appuie sur l\'abonnement que tu veux annuler.',
          'es': 'Toca la suscripción que quieres cancelar.',
        },
      ),
      CancelGuideStep(
        step: 6,
        title: 'Tap "Cancel subscription"',
        detail: 'Tap the cancel button at the bottom.',
        titleLocalized: {
          'pl': 'Dotknij „Anuluj subskrypcję"',
          'de': 'Tippe auf „Abo kündigen"',
          'fr': 'Appuie sur « Annuler l\'abonnement »',
          'es': 'Toca "Cancelar suscripción"',
        },
        detailLocalized: {
          'pl': 'Dotknij przycisku anulowania na dole.',
          'de': 'Tippe auf den Kündigen-Button unten.',
          'fr': 'Appuie sur le bouton d\'annulation en bas.',
          'es': 'Toca el botón de cancelar en la parte inferior.',
        },
      ),
      CancelGuideStep(
        step: 7,
        title: 'Follow the prompts',
        detail: 'Google may offer a discount to keep you. Decide if it\'s worth it, then confirm cancellation.',
        titleLocalized: {
          'pl': 'Postępuj zgodnie z instrukcjami',
          'de': 'Folge den Anweisungen',
          'fr': 'Suis les instructions',
          'es': 'Sigue las instrucciones',
        },
        detailLocalized: {
          'pl': 'Google może zaoferować zniżkę, żebyś został. Zdecyduj, czy to się opłaca, a potem potwierdź anulowanie.',
          'de': 'Google bietet dir möglicherweise einen Rabatt an. Entscheide, ob es sich lohnt, und bestätige dann die Kündigung.',
          'fr': 'Google peut te proposer une réduction. Décide si ça vaut le coup, puis confirme l\'annulation.',
          'es': 'Google puede ofrecerte un descuento. Decide si vale la pena y luego confirma la cancelación.',
        },
      ),
    ],
    cancelDeeplink: 'https://play.google.com/store/account/subscriptions',
    proTip: 'Google may offer a discounted rate to keep you \u2014 check if it\'s worth it before confirming.',
    proTipLocalized: {
      'pl': 'Google może zaoferować obniżoną cenę, żebyś został \u2014 sprawdź, czy to się opłaca, zanim potwierdzisz.',
      'de': 'Google bietet dir möglicherweise einen Rabatt an \u2014 prüfe, ob es sich lohnt, bevor du bestätigst.',
      'fr': 'Google peut te proposer un tarif réduit \u2014 vérifie si ça vaut le coup avant de confirmer.',
      'es': 'Google puede ofrecerte un precio reducido \u2014 comprueba si vale la pena antes de confirmar.',
    },
  ),

  // ─── Web (billed directly by the service) ───
  CancelGuideData(
    platform: 'web',
    steps: [
      CancelGuideStep(
        step: 1,
        title: 'Log in to the service\'s website',
        detail: 'Go to the service\'s website and sign in to your account.',
        titleLocalized: {
          'pl': 'Zaloguj się na stronie usługi',
          'de': 'Melde dich auf der Website des Dienstes an',
          'fr': 'Connecte-toi sur le site du service',
          'es': 'Inicia sesión en la web del servicio',
        },
        detailLocalized: {
          'pl': 'Przejdź na stronę usługi i zaloguj się na swoje konto.',
          'de': 'Gehe auf die Website des Dienstes und melde dich bei deinem Konto an.',
          'fr': 'Va sur le site du service et connecte-toi à ton compte.',
          'es': 'Ve a la web del servicio e inicia sesión en tu cuenta.',
        },
      ),
      CancelGuideStep(
        step: 2,
        title: 'Go to Account Settings or Billing',
        detail: 'Look for "Account", "Settings", "Billing", or "Subscription" in the menu.',
        titleLocalized: {
          'pl': 'Przejdź do Ustawień konta lub Płatności',
          'de': 'Gehe zu Kontoeinstellungen oder Abrechnung',
          'fr': 'Va dans Paramètres du compte ou Facturation',
          'es': 'Ve a Ajustes de cuenta o Facturación',
        },
        detailLocalized: {
          'pl': 'Szukaj „Konto", „Ustawienia", „Płatności" lub „Subskrypcja" w menu.',
          'de': 'Suche nach „Konto", „Einstellungen", „Abrechnung" oder „Abonnement" im Menü.',
          'fr': 'Cherche « Compte », « Paramètres », « Facturation » ou « Abonnement » dans le menu.',
          'es': 'Busca "Cuenta", "Ajustes", "Facturación" o "Suscripción" en el menú.',
        },
      ),
      CancelGuideStep(
        step: 3,
        title: 'Find the subscription or plan section',
        detail: 'Look for "Subscription", "Membership", "Plan", or "Billing".',
        titleLocalized: {
          'pl': 'Znajdź sekcję subskrypcji lub planu',
          'de': 'Finde den Bereich Abonnement oder Tarif',
          'fr': 'Trouve la section abonnement ou forfait',
          'es': 'Encuentra la sección de suscripción o plan',
        },
        detailLocalized: {
          'pl': 'Szukaj „Subskrypcja", „Członkostwo", „Plan" lub „Płatności".',
          'de': 'Suche nach „Abonnement", „Mitgliedschaft", „Tarif" oder „Abrechnung".',
          'fr': 'Cherche « Abonnement », « Adhésion », « Forfait » ou « Facturation ».',
          'es': 'Busca "Suscripción", "Membresía", "Plan" o "Facturación".',
        },
      ),
      CancelGuideStep(
        step: 4,
        title: 'Find the cancel option',
        detail: 'It might be labelled "Cancel", "Downgrade", "End subscription", or similar.',
        titleLocalized: {
          'pl': 'Znajdź opcję anulowania',
          'de': 'Finde die Kündigen-Option',
          'fr': 'Trouve l\'option d\'annulation',
          'es': 'Encuentra la opción de cancelar',
        },
        detailLocalized: {
          'pl': 'Może mieć etykietę „Anuluj", „Obniż plan", „Zakończ subskrypcję" itp.',
          'de': 'Sie kann „Kündigen", „Downgrade", „Abo beenden" oder ähnlich heißen.',
          'fr': 'Elle peut être intitulée « Annuler », « Rétrograder », « Mettre fin à l\'abonnement » ou similaire.',
          'es': 'Puede estar etiquetada como "Cancelar", "Reducir plan", "Finalizar suscripción" o similar.',
        },
      ),
      CancelGuideStep(
        step: 5,
        title: 'Follow the cancellation steps',
        detail: 'Some services show retention offers or surveys. Complete them to finish cancelling.',
        titleLocalized: {
          'pl': 'Postępuj zgodnie z krokami anulowania',
          'de': 'Folge den Kündigungsschritten',
          'fr': 'Suis les étapes d\'annulation',
          'es': 'Sigue los pasos de cancelación',
        },
        detailLocalized: {
          'pl': 'Niektóre usługi pokazują oferty zatrzymania lub ankiety. Przejdź przez nie, aby dokończyć anulowanie.',
          'de': 'Manche Dienste zeigen Halte-Angebote oder Umfragen. Schließe sie ab, um die Kündigung zu beenden.',
          'fr': 'Certains services affichent des offres de rétention ou des sondages. Complète-les pour terminer l\'annulation.',
          'es': 'Algunos servicios muestran ofertas de retención o encuestas. Complétalas para terminar la cancelación.',
        },
      ),
      CancelGuideStep(
        step: 6,
        title: 'Save your confirmation',
        detail: 'Screenshot or save the cancellation confirmation page and check your email for a confirmation.',
        titleLocalized: {
          'pl': 'Zapisz potwierdzenie',
          'de': 'Speichere die Bestätigung',
          'fr': 'Enregistre ta confirmation',
          'es': 'Guarda tu confirmación',
        },
        detailLocalized: {
          'pl': 'Zrób zrzut ekranu lub zapisz stronę potwierdzenia anulowania i sprawdź e-mail.',
          'de': 'Mache einen Screenshot oder speichere die Bestätigungsseite und prüfe deine E-Mails.',
          'fr': 'Fais une capture d\'écran ou enregistre la page de confirmation et vérifie tes e-mails.',
          'es': 'Haz una captura de pantalla o guarda la página de confirmación y revisa tu correo electrónico.',
        },
      ),
    ],
    warningText: 'Some services bury the cancel option. Try searching their help centre for "cancel" if you can\'t find it.',
    warningTextLocalized: {
      'pl': 'Niektóre usługi ukrywają opcję anulowania. Spróbuj wyszukać „anuluj" w ich centrum pomocy.',
      'de': 'Manche Dienste verstecken die Kündigen-Option. Suche im Hilfe-Center nach „kündigen", wenn du sie nicht findest.',
      'fr': 'Certains services cachent l\'option d\'annulation. Essaie de chercher « annuler » dans leur centre d\'aide.',
      'es': 'Algunos servicios esconden la opción de cancelar. Intenta buscar "cancelar" en su centro de ayuda.',
    },
    proTip: 'Check your email for a cancellation confirmation. If you don\'t get one within 24 hours, contact support directly.',
    proTipLocalized: {
      'pl': 'Sprawdź e-mail w poszukiwaniu potwierdzenia anulowania. Jeśli nie otrzymasz go w ciągu 24 godzin, skontaktuj się bezpośrednio z obsługą.',
      'de': 'Prüfe deine E-Mails auf eine Kündigungsbestätigung. Wenn du innerhalb von 24 Stunden keine bekommst, kontaktiere den Support direkt.',
      'fr': 'Vérifie tes e-mails pour une confirmation d\'annulation. Si tu n\'en reçois pas sous 24 heures, contacte le support directement.',
      'es': 'Revisa tu correo para una confirmación de cancelación. Si no la recibes en 24 horas, contacta al soporte directamente.',
    },
  ),

  // ─── Bank/Card (last resort) ───
  CancelGuideData(
    platform: 'bank',
    steps: [
      CancelGuideStep(
        step: 1,
        title: 'Check your bank statement',
        detail: 'Identify the exact merchant name from your bank or card statement.',
        titleLocalized: {
          'pl': 'Sprawdź wyciąg bankowy',
          'de': 'Prüfe deinen Kontoauszug',
          'fr': 'Vérifie ton relevé bancaire',
          'es': 'Revisa tu extracto bancario',
        },
        detailLocalized: {
          'pl': 'Zidentyfikuj dokładną nazwę sprzedawcy z wyciągu bankowego lub karty.',
          'de': 'Identifiziere den genauen Händlernamen aus deinem Bank- oder Kartenauszug.',
          'fr': 'Identifie le nom exact du marchand sur ton relevé bancaire ou de carte.',
          'es': 'Identifica el nombre exacto del comerciante en tu extracto bancario o de tarjeta.',
        },
      ),
      CancelGuideStep(
        step: 2,
        title: 'Search for cancellation instructions',
        detail: 'Search "[merchant name] cancel subscription" in your browser.',
        titleLocalized: {
          'pl': 'Wyszukaj instrukcje anulowania',
          'de': 'Suche nach Kündigungsanleitungen',
          'fr': 'Cherche les instructions d\'annulation',
          'es': 'Busca instrucciones de cancelación',
        },
        detailLocalized: {
          'pl': 'Wyszukaj w przeglądarce „[nazwa sprzedawcy] anuluj subskrypcję".',
          'de': 'Suche im Browser nach „[Händlername] Abo kündigen".',
          'fr': 'Cherche dans ton navigateur « [nom du marchand] annuler abonnement ».',
          'es': 'Busca en tu navegador "[nombre del comerciante] cancelar suscripción".',
        },
      ),
      CancelGuideStep(
        step: 3,
        title: 'Log in and find billing settings',
        detail: 'Log in to the service and look for account or billing settings.',
        titleLocalized: {
          'pl': 'Zaloguj się i znajdź ustawienia płatności',
          'de': 'Melde dich an und finde die Zahlungseinstellungen',
          'fr': 'Connecte-toi et trouve les paramètres de facturation',
          'es': 'Inicia sesión y encuentra los ajustes de facturación',
        },
        detailLocalized: {
          'pl': 'Zaloguj się do usługi i poszukaj ustawień konta lub płatności.',
          'de': 'Melde dich beim Dienst an und suche nach Konto- oder Zahlungseinstellungen.',
          'fr': 'Connecte-toi au service et cherche les paramètres de compte ou facturation.',
          'es': 'Inicia sesión en el servicio y busca los ajustes de cuenta o facturación.',
        },
      ),
      CancelGuideStep(
        step: 4,
        title: 'Contact support if needed',
        detail: 'If you can\'t find a cancel option, email their support team requesting cancellation.',
        titleLocalized: {
          'pl': 'Skontaktuj się z obsługą, jeśli potrzeba',
          'de': 'Kontaktiere den Support, falls nötig',
          'fr': 'Contacte le support si nécessaire',
          'es': 'Contacta al soporte si es necesario',
        },
        detailLocalized: {
          'pl': 'Jeśli nie możesz znaleźć opcji anulowania, napisz do zespołu wsparcia z prośbą o anulowanie.',
          'de': 'Wenn du keine Kündigen-Option findest, schreibe dem Support-Team eine E-Mail mit der Bitte um Kündigung.',
          'fr': 'Si tu ne trouves pas d\'option d\'annulation, envoie un e-mail au support pour demander l\'annulation.',
          'es': 'Si no encuentras la opción de cancelar, envía un correo al equipo de soporte solicitando la cancelación.',
        },
      ),
      CancelGuideStep(
        step: 5,
        title: 'Block charges as a last resort',
        detail: 'If all else fails, contact your bank to block future charges from this merchant.',
        titleLocalized: {
          'pl': 'Zablokuj obciążenia jako ostateczność',
          'de': 'Sperre Abbuchungen als letzten Ausweg',
          'fr': 'Bloque les prélèvements en dernier recours',
          'es': 'Bloquea los cargos como último recurso',
        },
        detailLocalized: {
          'pl': 'Jeśli nic innego nie zadziała, skontaktuj się z bankiem, aby zablokować przyszłe obciążenia od tego sprzedawcy.',
          'de': 'Wenn alles andere scheitert, kontaktiere deine Bank, um zukünftige Abbuchungen von diesem Händler zu sperren.',
          'fr': 'Si rien d\'autre ne fonctionne, contacte ta banque pour bloquer les futurs prélèvements de ce marchand.',
          'es': 'Si nada más funciona, contacta a tu banco para bloquear futuros cargos de este comerciante.',
        },
      ),
    ],
    warningText: 'Blocking charges through your bank should be a last resort \u2014 some services may send your account to collections.',
    warningTextLocalized: {
      'pl': 'Blokowanie obciążeń przez bank powinno być ostatecznością \u2014 niektóre usługi mogą przekazać twoje konto do windykacji.',
      'de': 'Das Sperren von Abbuchungen über die Bank sollte der letzte Ausweg sein \u2014 manche Dienste könnten dein Konto an ein Inkassobüro übergeben.',
      'fr': 'Bloquer les prélèvements via ta banque devrait être un dernier recours \u2014 certains services peuvent transmettre ton compte au recouvrement.',
      'es': 'Bloquear los cargos a través de tu banco debería ser el último recurso \u2014 algunos servicios pueden enviar tu cuenta a cobranza.',
    },
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
