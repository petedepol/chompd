// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Chompd';

  @override
  String get tagline => 'Escanea. Rastrea. Contraataca.';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get done => 'Hecho';

  @override
  String get keep => 'Mantener';

  @override
  String get skip => 'Omitir';

  @override
  String get next => 'Siguiente';

  @override
  String get share => 'Compartir';

  @override
  String get confirm => 'Confirmar';

  @override
  String get other => 'Otro';

  @override
  String get close => 'Cerrar';

  @override
  String get edit => 'Editar';

  @override
  String get pro => 'Pro';

  @override
  String get free => 'Gratis';

  @override
  String get tierTrial => 'Prueba';

  @override
  String get onboardingTitle1 => 'Planta cara a las suscripciones';

  @override
  String get onboardingSubtitle1 =>
      'Chompd rastrea cada suscripción, detecta trampas ocultas y te ayuda a cancelar lo que no necesitas.';

  @override
  String onboardingStatWaste(String amount) {
    return 'De media, se desperdician $amount/año en suscripciones olvidadas';
  }

  @override
  String get onboardingEaseTag => 'Sin teclear. Solo foto y a rastrear.';

  @override
  String get onboardingTitle2 => 'Cómo funciona';

  @override
  String get onboardingStep1Title => 'Haz una captura de pantalla';

  @override
  String get onboardingStep1Subtitle =>
      'Confirmación, email o extracto bancario';

  @override
  String get onboardingStep2Title => 'La IA la lee al instante';

  @override
  String get onboardingStep2Subtitle =>
      'Precio, fecha de renovación y trampas ocultas';

  @override
  String get onboardingStep3Title => 'Listo. Rastreado para siempre.';

  @override
  String get onboardingStep3Subtitle => 'Te avisamos antes de que te cobren';

  @override
  String get onboardingTitle3 => 'Ve un paso por delante';

  @override
  String get onboardingSubtitle3 =>
      'Te recordamos antes de cada cobro — sin sorpresas.';

  @override
  String get onboardingNotifMorning => 'La mañana de la renovación';

  @override
  String get onboardingNotif7days => '7 días antes';

  @override
  String get onboardingNotifTrial => 'Alertas de fin de prueba';

  @override
  String get allowNotifications => 'Permitir notificaciones';

  @override
  String get maybeLater => 'Quizás más tarde';

  @override
  String get onboardingTitle4 => 'Añade tu primera suscripción';

  @override
  String get onboardingSubtitle4 =>
      'La mayoría descubren suscripciones olvidadas en su primer escaneo. Veamos qué se come tu dinero.';

  @override
  String get scanAScreenshot => 'Escanear una captura';

  @override
  String get scanHintTooltip => '¡Tócame para escanear!';

  @override
  String get addManually => 'Añadir manualmente';

  @override
  String get skipForNow => 'Omitir por ahora';

  @override
  String homeStatusLine(int active, int cancelled) {
    return '$active activas · $cancelled canceladas';
  }

  @override
  String get overBudgetMood => 'Ay. Eso es bastante.';

  @override
  String get underBudgetMood => '¡Genial! Bien por debajo del presupuesto.';

  @override
  String get sectionActiveSubscriptions => 'SUSCRIPCIONES ACTIVAS';

  @override
  String get sectionCancelledSaved => 'CANCELADAS — AHORRADO';

  @override
  String get sectionMilestones => 'LOGROS';

  @override
  String get sectionYearlyBurn => 'GASTO ANUAL';

  @override
  String get sectionMonthlyBurn => 'GASTO MENSUAL';

  @override
  String get sectionSavedWithChompd => 'AHORRADO CON CHOMPD';

  @override
  String perYearAcrossSubs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones',
      one: '1 suscripción',
    );
    return 'al año en $_temp0';
  }

  @override
  String perMonthAcrossSubs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones',
      one: '1 suscripción',
    );
    return 'al mes en $_temp0';
  }

  @override
  String get monthlyAvg => 'media mensual';

  @override
  String get yearlyTotal => 'total anual';

  @override
  String get dailyCost => 'coste diario';

  @override
  String fromCancelled(int count) {
    return 'de $count canceladas';
  }

  @override
  String get deleteSubscriptionTitle => '¿Eliminar suscripción?';

  @override
  String deleteSubscriptionMessage(String name) {
    return '¿Eliminar $name definitivamente?';
  }

  @override
  String cancelledMonthsAgo(int months) {
    return 'Cancelada hace $months meses';
  }

  @override
  String get justCancelled => 'Recién cancelada';

  @override
  String get subsLeft => 'Subs restantes';

  @override
  String get scansLeft => 'Escaneos restantes';

  @override
  String get aiScanScreenshot => 'Escaneo IA de captura';

  @override
  String get aiScanUpgradeToPro => 'Escaneo IA (Mejora a Pro)';

  @override
  String get quickAddManual => 'Añadido rápido / Manual';

  @override
  String get addSubUpgradeToPro => 'Añadir sub (Mejora a Pro)';

  @override
  String trialsExpiringSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pruebas expiran pronto',
      one: '1 prueba expira pronto',
    );
    return '$_temp0';
  }

  @override
  String trialDaysLeft(String names, int days) {
    return '$names — quedan $days días';
  }

  @override
  String get proInfinity => 'PRO ∞';

  @override
  String scansLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escaneos restantes',
      one: '1 escaneo restante',
    );
    return '$_temp0';
  }

  @override
  String get scanTitle => 'Escaneo IA';

  @override
  String get scanAnalysing => 'Ñam ñam... masticando tu captura de pantalla 🐟';

  @override
  String get scanIdleTitle => 'Escanea una captura de pantalla';

  @override
  String get scanIdleSubtitle =>
      'Comparte una captura de un email de confirmación,\nextracto bancario o recibo de la App Store.';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get chooseFromGallery => 'Elegir de la galería';

  @override
  String get cameraPermError =>
      'Sin acceso a la cámara. Verifica los permisos.';

  @override
  String get galleryPermError =>
      'Sin acceso a la galería. Verifica los permisos.';

  @override
  String get pasteEmailText => 'Pegar texto de email';

  @override
  String get pasteTextHint =>
      'Pega aquí el texto de tu email de suscripción o confirmación...';

  @override
  String get scanText => 'Escanear texto';

  @override
  String get textReceived => 'Ñam ñam... masticando tu texto 🐟';

  @override
  String get smartMove => '¡Buen movimiento!';

  @override
  String youSkipped(String service) {
    return 'Has evitado $service';
  }

  @override
  String get saved => 'AHORRADO';

  @override
  String get addedToUnchompd => 'Añadido a tu total Unchompd';

  @override
  String get analysing => 'Casi listo... un último mordisco';

  @override
  String get scanSniffing => 'Olfateando cargos sospechosos...';

  @override
  String get scanFoundFeast => '¡Encontré un festín! Mordiendo todo...';

  @override
  String get scanEscalation => 'Llamando a un pez más grande de refuerzo... 🦈';

  @override
  String get scanAlmostDone => 'Casi listo... un último mordisco';

  @override
  String scanFoundCount(int count) {
    return '$count suscripciones encontradas';
  }

  @override
  String get scanTapToExpand => 'Toca para expandir y editar';

  @override
  String get scanCancelledHint =>
      'Algunas suscripciones ya están canceladas y expirarán pronto — las hemos desmarcado por ti.';

  @override
  String get scanAlreadyCancelled => 'Ya cancelada';

  @override
  String get scanExpires => 'Expira';

  @override
  String get scanSkipAll => 'Omitir todo';

  @override
  String scanAddSelected(int count) {
    return '+ Añadir $count seleccionadas';
  }

  @override
  String get confidence => 'confianza';

  @override
  String get typeYourAnswer => 'Escribe tu respuesta...';

  @override
  String get addToChompd => 'Añadir a Chompd';

  @override
  String get monthlyTotal => 'Total mensual';

  @override
  String addAllToChompd(int count) {
    return 'Añadir todos ($count) a Chompd';
  }

  @override
  String get autoTier => 'AUTO';

  @override
  String yesIts(String option) {
    return 'Sí, es $option';
  }

  @override
  String get otherAmount => 'Otra cantidad';

  @override
  String get trapDetected => 'TRAMPA DETECTADA';

  @override
  String trapOfferActually(String name) {
    return 'Esta oferta de «$name» en realidad es:';
  }

  @override
  String skipItSave(String amount) {
    return 'EVITAR — AHORRAR $amount';
  }

  @override
  String get trackTrialAnyway => 'Rastrear la prueba de todos modos';

  @override
  String get trapReminder => 'Te avisaremos antes de que te cobren';

  @override
  String get editSubscription => 'Editar suscripción';

  @override
  String get addSubscription => 'Añadir suscripción';

  @override
  String get fieldServiceName => 'NOMBRE DEL SERVICIO';

  @override
  String get hintServiceName => 'ej. Netflix, Spotify';

  @override
  String get errorNameRequired => 'Nombre requerido';

  @override
  String get fieldPrice => 'PRECIO';

  @override
  String get hintPrice => '9,99';

  @override
  String get errorPriceRequired => 'Precio requerido';

  @override
  String get errorInvalidPrice => 'Precio no válido';

  @override
  String get fieldCurrency => 'MONEDA';

  @override
  String get fieldBillingCycle => 'CICLO DE FACTURACIÓN';

  @override
  String get fieldCategory => 'CATEGORÍA';

  @override
  String get fieldNextRenewal => 'PRÓXIMA RENOVACIÓN';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get freeTrialToggle => 'Es una prueba gratuita';

  @override
  String get trialDurationLabel => 'Duración de la prueba';

  @override
  String get trialDays7 => '7 días';

  @override
  String get trialDays14 => '14 días';

  @override
  String get trialDays30 => '30 días';

  @override
  String trialCustomDays(int days) {
    return '${days}d';
  }

  @override
  String get fieldTrialEnds => 'FIN DE LA PRUEBA';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get subscriptionDetail => 'Detalle de suscripción';

  @override
  String thatsPerYear(String amount) {
    return 'Son $amount al año';
  }

  @override
  String overThreeYears(String amount) {
    return '$amount en 3 años';
  }

  @override
  String trialDaysRemaining(int days) {
    return '⚠️ Prueba — quedan $days días';
  }

  @override
  String get trialExpired => '⚠️ Prueba expirada';

  @override
  String get nextRenewal => 'PRÓXIMA RENOVACIÓN';

  @override
  String chargesToday(String price) {
    return '$price se cobra hoy';
  }

  @override
  String chargesTomorrow(String price) {
    return '$price se cobra mañana';
  }

  @override
  String chargesSoon(int days, String price) {
    return '$days días — $price pronto';
  }

  @override
  String daysCount(int days) {
    return '$days días';
  }

  @override
  String get sectionReminders => 'RECORDATORIOS';

  @override
  String remindersScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordatorios programados',
      one: '1 recordatorio programado',
    );
    return '$_temp0';
  }

  @override
  String get reminderDaysBefore7 => '7 días antes';

  @override
  String get reminderDaysBefore3 => '3 días antes';

  @override
  String get reminderDaysBefore1 => '1 día antes';

  @override
  String get reminderMorningOf => 'La mañana del día';

  @override
  String get upgradeForReminders =>
      'Mejora a Pro para recordatorios anticipados';

  @override
  String get sectionPaymentHistory => 'HISTORIAL DE PAGOS';

  @override
  String get totalPaid => 'Total pagado';

  @override
  String noPaymentsYet(String date) {
    return 'Sin pagos aún — añadida el $date';
  }

  @override
  String get upcoming => 'Próximos';

  @override
  String get sectionDetails => 'DETALLES';

  @override
  String get detailCategory => 'Categoría';

  @override
  String get detailCurrency => 'Moneda';

  @override
  String get detailBillingCycle => 'Ciclo de facturación';

  @override
  String get detailAdded => 'Añadida';

  @override
  String addedVia(String date, String source) {
    return '$date vía $source';
  }

  @override
  String get sourceAiScan => 'Escaneo IA';

  @override
  String get sourceQuickAdd => 'Añadido rápido';

  @override
  String get sourceManual => 'Manual';

  @override
  String get cancelSubscription => 'Cancelar suscripción';

  @override
  String cancelSubscriptionConfirm(String name) {
    return '¿Cancelar $name?';
  }

  @override
  String cancelPlatformPickerTitle(String name) {
    return '¿Cómo pagas $name?';
  }

  @override
  String get cancelPlatformIos => 'Apple App Store';

  @override
  String get cancelPlatformAndroid => 'Google Play';

  @override
  String get cancelPlatformWeb => 'Sitio web / Directo';

  @override
  String get cancelPlatformNotSure => 'No estoy seguro';

  @override
  String get difficultyEasy => 'Fácil — cancelación sencilla';

  @override
  String get difficultyModerate => 'Moderado — algunos pasos necesarios';

  @override
  String get difficultyMedium => 'Medio — lleva unos minutos';

  @override
  String get difficultyHard => 'Difícil — deliberadamente complicado';

  @override
  String get difficultyVeryHard =>
      'Muy difícil — múltiples pantallas de retención';

  @override
  String get requestRefund => 'Solicitar reembolso';

  @override
  String deleteNameTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get deleteNameMessage =>
      'Esta suscripción se eliminará permanentemente. No se puede deshacer.';

  @override
  String noGuideYet(String name) {
    return 'Aún no hay guía para $name. Busca \"$name cancelar suscripción\" en internet.';
  }

  @override
  String realAnnualCost(String amount) {
    return 'Coste anual real: $amount/año';
  }

  @override
  String trialExpires(String date) {
    return 'La prueba expira el $date';
  }

  @override
  String get chompdPro => 'Chompd Pro';

  @override
  String get paywallTagline =>
      'Un rastreador de suscripciones que no es una suscripción.';

  @override
  String paywallLimitSubs(int count) {
    return 'Has alcanzado el límite gratuito de $count suscripciones.';
  }

  @override
  String get paywallLimitScans => 'Has usado tu escaneo IA gratuito.';

  @override
  String get paywallLimitReminders =>
      'Los recordatorios anticipados son una función Pro.';

  @override
  String get paywallGeneric => 'Desbloquea la experiencia completa de Chompd.';

  @override
  String get paywallFeature1 => 'Ahorra 100–500/año en gastos ocultos';

  @override
  String get paywallFeature2 => 'No vuelvas a olvidar un vencimiento de prueba';

  @override
  String get paywallFeature3 => 'Escaneo ilimitado de trampas con IA';

  @override
  String get paywallFeature4 => 'Rastrea cada suscripción';

  @override
  String get paywallFeature5 =>
      'Alertas tempranas: 7, 3, 1 día antes del cobro';

  @override
  String get paywallFeature6 => 'Tarjetas de ahorro para compartir';

  @override
  String get paywallContext =>
      'Se amortiza al cancelar una sola suscripción olvidada.';

  @override
  String get oneTimePayment => 'Pago único. Para siempre.';

  @override
  String get lifetime => 'DE POR VIDA';

  @override
  String get unlockChompdPro => 'Desbloquear Chompd Pro';

  @override
  String get restoring => 'Restaurando...';

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get purchaseError =>
      'No se pudo completar la compra. Inténtalo de nuevo.';

  @override
  String get noPreviousPurchase => 'No se encontró compra anterior.';

  @override
  String get purchaseCancelled => 'Compra cancelada.';

  @override
  String get renewalCalendar => 'Calendario de renovaciones';

  @override
  String get today => 'HOY';

  @override
  String get noRenewalsThisDay => 'Sin renovaciones este día';

  @override
  String get thisMonth => 'ESTE MES';

  @override
  String get renewals => 'Renovaciones';

  @override
  String get total => 'Total';

  @override
  String renewalsOnDay(int count, String date, String price) {
    return '$count renovaciones el $date por un total de $price';
  }

  @override
  String biggestDay(String date, String price) {
    return 'Día más caro: $date — $price';
  }

  @override
  String get tapDayToSee => 'Toca un día para ver las renovaciones';

  @override
  String cancelGuideTitle(String name) {
    return 'Cancelar $name';
  }

  @override
  String get whyCancelling => '¿Por qué cancelas?';

  @override
  String get whyCancellingHint =>
      'Un toque rápido — nos ayuda a mejorar Chompd.';

  @override
  String get reasonTooExpensive => 'Demasiado caro';

  @override
  String get reasonDontUse => 'No lo uso suficiente';

  @override
  String get reasonBreak => 'Me tomo un descanso';

  @override
  String get reasonSwitching => 'Cambio a otra cosa';

  @override
  String get difficultyLevel => 'Nivel de dificultad';

  @override
  String get cancellationSteps => 'Pasos de cancelación';

  @override
  String stepNumber(int number) {
    return 'PASO $number';
  }

  @override
  String get openCancelPage => 'Abrir página de cancelación';

  @override
  String get iveCancelled => 'Ya he cancelado';

  @override
  String get couldntCancelRefund =>
      '¿No puedes cancelar? Ayuda con reembolso →';

  @override
  String get refundTipTitle => 'Consejo: ¿Por qué pedir un reembolso?';

  @override
  String get refundTipBody =>
      'Si te cobraron inesperadamente, te registraste por error, o el servicio no funcionó como prometía — puedes tener derecho a un reembolso. Cuanto antes lo pidas, mejor.';

  @override
  String get refundRescue => 'Ayuda con reembolso';

  @override
  String get refundIntro =>
      'No te preocupes — la mayoría recupera su dinero. Vamos a solucionarlo.';

  @override
  String chargedYou(String name, String price) {
    return '$name te cobró $price';
  }

  @override
  String get howCharged => '¿CÓMO TE COBRARON?';

  @override
  String successRate(String rate) {
    return 'Tasa de éxito: $rate';
  }

  @override
  String get copyDisputeEmail => 'Copiar email de reclamación';

  @override
  String get openRefundPage => 'Abrir página de reembolso';

  @override
  String get iveSubmittedRequest => 'He enviado mi solicitud';

  @override
  String get requestSubmitted => '¡Solicitud enviada!';

  @override
  String get requestSubmittedMessage =>
      'Tu solicitud de reembolso ha sido registrada. Revisa tu email.';

  @override
  String get emailCopied => 'Email copiado al portapapeles';

  @override
  String refundWindowDays(String days) {
    return 'Ventana de reembolso de $days días';
  }

  @override
  String avgRefundDays(String days) {
    return '~${days}d prom.';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get themeTitle => 'TEMA';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get sectionNotifications => 'NOTIFICACIONES';

  @override
  String remindersScheduledSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordatorios programados',
      one: '1 recordatorio programado',
    );
    return '$_temp0';
  }

  @override
  String get pushNotifications => 'Notificaciones push';

  @override
  String get pushNotificationsSubtitle =>
      'Recordatorios de renovaciones y pruebas';

  @override
  String get morningDigest => 'Resumen matutino';

  @override
  String morningDigestSubtitle(String time) {
    return 'Resumen diario a las $time';
  }

  @override
  String get renewalReminders => 'Recordatorios de renovación';

  @override
  String get trialExpiryAlerts => 'Alertas de vencimiento de prueba';

  @override
  String get trialExpirySubtitle => 'Alerta a 3 días, 1 día y el mismo día';

  @override
  String get sectionReminderSchedule => 'PROGRAMA DE RECORDATORIOS';

  @override
  String get sectionUpcoming => 'PRÓXIMOS';

  @override
  String get noUpcomingNotifications => 'Sin notificaciones próximas';

  @override
  String get sectionChompdPro => 'CHOMPD PRO';

  @override
  String get sectionCurrency => 'MONEDA';

  @override
  String get displayCurrency => 'Moneda de visualización';

  @override
  String get sectionMonthlyBudget => 'PRESUPUESTO MENSUAL';

  @override
  String get monthlySpendingTarget => 'Objetivo de gasto mensual';

  @override
  String get budgetHint => 'Se usa para el anillo de gastos en el panel';

  @override
  String get sectionHapticFeedback => 'RESPUESTA HÁPTICA';

  @override
  String get hapticFeedback => 'Respuesta háptica';

  @override
  String get hapticSubtitle => 'Vibraciones al tocar, cambiar y celebrar';

  @override
  String get sectionDataExport => 'EXPORTAR DATOS';

  @override
  String get exportToCsv => 'Exportar a CSV';

  @override
  String get exportHint =>
      'Descarga todas tus suscripciones como hoja de cálculo';

  @override
  String exportSuccess(int count) {
    return '$count suscripciones exportadas a CSV';
  }

  @override
  String exportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get sectionAbout => 'ACERCA DE';

  @override
  String get version => 'Versión';

  @override
  String get tier => 'Plan';

  @override
  String get aiModel => 'Modelo IA';

  @override
  String get aiModelValue => 'Claude Haiku 4.5';

  @override
  String get setBudgetTitle => 'Establecer presupuesto mensual';

  @override
  String get setBudgetSubtitle =>
      'Indica tu objetivo de gasto mensual en suscripciones.';

  @override
  String get reminderSubtitleMorningOnly =>
      'Solo por la mañana (mejora para más)';

  @override
  String reminderSubtitleDays(String schedule) {
    return '$schedule antes de la renovación';
  }

  @override
  String get dayOf => 'El día';

  @override
  String get oneDay => '1 día';

  @override
  String nDays(int days) {
    return '$days días';
  }

  @override
  String get timelineLabel7d => '7d';

  @override
  String get timelineLabel3d => '3d';

  @override
  String get timelineLabel1d => '1d';

  @override
  String get timelineLabelDayOf => 'El día';

  @override
  String get upgradeProReminders =>
      'Mejora a Pro para recordatorios 7d, 3d y 1d';

  @override
  String proPrice(String price) {
    return '£$price';
  }

  @override
  String oneTimePaymentShort(String price) {
    return '$price • Pago único';
  }

  @override
  String get sectionLanguage => 'IDIOMA';

  @override
  String get severityHigh => 'ALTO RIESGO';

  @override
  String get severityCaution => 'PRECAUCIÓN';

  @override
  String get severityInfo => 'INFO';

  @override
  String get trapTypeTrialBait => 'Cebo de prueba';

  @override
  String get trapTypePriceFraming => 'Precio engañoso';

  @override
  String get trapTypeHiddenRenewal => 'Renovación oculta';

  @override
  String get trapTypeCancelFriction => 'Cancelación difícil';

  @override
  String get trapTypeGeneric => 'Trampa de suscripción';

  @override
  String get severityExplainHigh =>
      'Subida de precio extrema o presentación engañosa';

  @override
  String get severityExplainMedium =>
      'El precio introductorio sube significativamente';

  @override
  String get severityExplainLow => 'Prueba estándar con renovación automática';

  @override
  String trialBadge(int days) {
    return '${days}d prueba';
  }

  @override
  String introBadge(int days) {
    return '${days}d promo';
  }

  @override
  String get emptyNoSubscriptions => 'Aún sin suscripciones';

  @override
  String get emptyNoSubscriptionsHint =>
      'Escanea una captura o toca + para empezar.';

  @override
  String get emptyNoTrials => 'Sin pruebas activas';

  @override
  String get emptyNoTrialsHint =>
      'Cuando añadas suscripciones de prueba,\naparecerán aquí con alertas de cuenta regresiva.';

  @override
  String get emptyNoSavings => 'Aún sin ahorros';

  @override
  String get emptyNoSavingsHint =>
      'Cancela las suscripciones que no uses\ny mira cómo crecen tus ahorros.';

  @override
  String get nudgeReview => 'Revisar';

  @override
  String get nudgeKeepIt => 'Mantener';

  @override
  String get trialLabel => 'PRUEBA';

  @override
  String get priceToday => 'HOY';

  @override
  String get priceNow => 'AHORA';

  @override
  String get priceThen => 'DESPUÉS';

  @override
  String get priceRenewsAt => 'SE RENUEVA A';

  @override
  String dayTrial(String days) {
    return 'Prueba de $days días';
  }

  @override
  String monthIntro(String months) {
    return 'Oferta de $months meses';
  }

  @override
  String realCostFirstYear(String amount) {
    return 'Coste real el 1er año: $amount';
  }

  @override
  String get milestoneCoffeeFund => 'Fondo para café';

  @override
  String get milestoneGamePass => 'Game Pass';

  @override
  String get milestoneWeekendAway => 'Escapada de fin de semana';

  @override
  String get milestoneNewGadget => 'Gadget nuevo';

  @override
  String get milestoneDreamHoliday => 'Vacaciones soñadas';

  @override
  String get milestoneFirstBiteBack => 'Primer contraataque';

  @override
  String get milestoneChompSpotter => 'Detector de trampas';

  @override
  String get milestoneDarkPatternDestroyer => 'Destructor de dark patterns';

  @override
  String get milestoneSubscriptionSentinel => 'Centinela de suscripciones';

  @override
  String get milestoneUnchompable => 'Unchompable';

  @override
  String get milestoneReached => '✓ ¡Conseguido!';

  @override
  String milestoneToGo(String amount) {
    return 'faltan $amount';
  }

  @override
  String get celebrationTitle => '¡Genial! 🎉';

  @override
  String celebrationSavePerYear(String amount) {
    return 'Ahorrarás $amount/año';
  }

  @override
  String celebrationByDropping(String name) {
    return 'al cancelar $name';
  }

  @override
  String get tapAnywhereToContinue => 'toca en cualquier lugar para continuar';

  @override
  String get trapBadge => 'TRAMPA';

  @override
  String trapDays(int days) {
    return '${days}d trampa';
  }

  @override
  String get unchompd => 'Unchompd';

  @override
  String get fromSubscriptionTraps => 'de trampas de suscripción';

  @override
  String trapsDodged(int count) {
    return '$count evitadas';
  }

  @override
  String trialsCancelled(int count) {
    return '$count canceladas';
  }

  @override
  String refundsRecovered(int count) {
    return '$count reembolsadas';
  }

  @override
  String get ringYearly => 'ANUAL';

  @override
  String get ringMonthly => 'MENSUAL';

  @override
  String overBudget(String amount) {
    return '$amount sobre presupuesto';
  }

  @override
  String ofBudget(String amount) {
    return 'de $amount de presupuesto';
  }

  @override
  String get tapForMonthly => 'toca para mensual';

  @override
  String get tapForYearly => 'toca para anual';

  @override
  String budgetRange(String min, String max) {
    return 'Presupuesto: $min – $max';
  }

  @override
  String get addSubscriptionSheet => 'Añadir suscripción';

  @override
  String get orChooseService => 'o elige un servicio';

  @override
  String get searchServices => 'Buscar servicios...';

  @override
  String get priceField => 'Precio';

  @override
  String addServiceName(String name) {
    return 'Añadir $name';
  }

  @override
  String get tapForMore => 'toca para más';

  @override
  String shareYearlyBurn(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones',
      one: '1 suscripción',
    );
    return 'Gasto $symbol$amount/año en $_temp0 😳';
  }

  @override
  String shareMonthlyDaily(String symbol, String monthly, String daily) {
    return 'Son $symbol$monthly/mes o $symbol$daily/día';
  }

  @override
  String shareSavedBy(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones',
      one: '1 suscripción',
    );
    return '✓ Ahorré $symbol$amount cancelando $_temp0';
  }

  @override
  String get shareFooter =>
      'Rastreado con Chompd — Escanea. Rastrea. Contraataca.';

  @override
  String shareSavings(String symbol, String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones',
      one: '1 suscripción',
    );
    return 'Ahorré $symbol$amount cancelando $_temp0 🎉\n\nPlanta cara a las suscripciones — getchompd.com';
  }

  @override
  String get insightBigSpenderHeadline => 'Gran gasto';

  @override
  String insightBigSpenderMessage(String name, String amount) {
    return '$name te cuesta **$amount/año**. Es tu suscripción más cara.';
  }

  @override
  String get insightAnnualSavingsHeadline => 'Ahorros anuales';

  @override
  String insightAnnualSavingsMessage(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones',
      one: '1 suscripción',
    );
    return 'Cambiar **$_temp0** a facturación anual podría ahorrar ~**$amount/año**.';
  }

  @override
  String get insightRealityCheckHeadline => 'Revisión';

  @override
  String insightRealityCheckMessage(int count) {
    return 'Tienes **$count suscripciones activas**. La media es 12 — ¿las usas todas?';
  }

  @override
  String get insightMoneySavedHeadline => 'Dinero ahorrado';

  @override
  String insightMoneySavedMessage(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones',
      one: '1 suscripción',
    );
    return 'Has ahorrado **$amount** desde que cancelaste **$_temp0**. ¡Bien hecho!';
  }

  @override
  String get insightTrialEndingHeadline => 'Prueba por acabar';

  @override
  String insightTrialEndingMessage(String names, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pruebas expiran',
      one: 'prueba expira',
    );
    return '**$names** — $_temp0 pronto. Cancela ahora o te cobrarán.';
  }

  @override
  String get insightDailyCostHeadline => 'Coste diario';

  @override
  String insightDailyCostMessage(String amount) {
    return 'Tus suscripciones cuestan **$amount/día** — eso es un café premium, todos los días.';
  }

  @override
  String notifRenewsToday(String name) {
    return '$name se renueva hoy';
  }

  @override
  String notifRenewsTomorrow(String name) {
    return '$name se renueva mañana';
  }

  @override
  String notifRenewsInDays(String name, int days) {
    return '$name se renueva en $days días';
  }

  @override
  String notifChargesToday(String price) {
    return 'Te cobrarán $price hoy. Toca para revisar o cancelar.';
  }

  @override
  String notifChargesTomorrow(String price) {
    return '$price se cobrará mañana. ¿Quieres mantenerlo?';
  }

  @override
  String notifCharges3Days(String price) {
    return 'Renovación de $price en 3 días.';
  }

  @override
  String notifChargesInDays(String price, int days) {
    return 'Renovación de $price en $days días. ¿Hora de revisar?';
  }

  @override
  String notifTrialEndsToday(String name) {
    return '⚠ ¡La prueba de $name termina hoy!';
  }

  @override
  String notifTrialEndsTomorrow(String name) {
    return 'La prueba de $name termina mañana';
  }

  @override
  String notifTrialEndsInDays(String name, int days) {
    return 'La prueba de $name termina en $days días';
  }

  @override
  String notifTrialBodyToday(String price) {
    return '¡Tu prueba gratuita termina hoy! Te cobrarán $price. Cancela ahora si no quieres continuar.';
  }

  @override
  String notifTrialBodyTomorrow(String price) {
    return 'Queda un día de prueba. Después serán $price. Cancela ahora para evitar el cobro.';
  }

  @override
  String notifTrialBodyDays(int days, String price) {
    return 'Quedan $days días de prueba gratis. El precio completo es $price después.';
  }

  @override
  String notifTrapTrialTitle3d(String name) {
    return 'La prueba de $name termina en 3 días';
  }

  @override
  String notifTrapTrialBody3d(String price) {
    return 'Se cobrarán $price automáticamente. Cancela ahora si no lo quieres.';
  }

  @override
  String notifTrapTrialTitleTomorrow(String name, String price) {
    return '⚠️ MAÑANA: $name cobrará $price';
  }

  @override
  String get notifTrapTrialBodyTomorrow =>
      'Cancela ahora si no quieres mantenerlo.';

  @override
  String notifTrapTrialTitle2h(String name, String price) {
    return '🚨 $name cobrará $price en 2 HORAS';
  }

  @override
  String get notifTrapTrialBody2h => 'Es tu última oportunidad para cancelar.';

  @override
  String notifTrapPostCharge(String name) {
    return '¿Querías mantener $name?';
  }

  @override
  String notifTrapPostChargeBody(String price) {
    return 'Te cobraron $price. Toca si necesitas ayuda con el reembolso.';
  }

  @override
  String notifDigestBoth(int renewalCount, int trialCount) {
    return '$renewalCount renovación(es) + $trialCount prueba(s) hoy';
  }

  @override
  String notifDigestRenewals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones se renuevan hoy',
      one: '1 suscripción se renueva hoy',
    );
    return '$_temp0';
  }

  @override
  String notifDigestTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pruebas expiran hoy',
      one: '1 prueba expira hoy',
    );
    return '$_temp0';
  }

  @override
  String notifDigestRenewalBody(String names, String total) {
    return '$names — total $total';
  }

  @override
  String notifDigestTrialBody(String names) {
    return '$names — cancela ahora para evitar cargos';
  }

  @override
  String get cycleWeekly => 'Semanal';

  @override
  String get cycleMonthly => 'Mensual';

  @override
  String get cycleQuarterly => 'Trimestral';

  @override
  String get cycleYearly => 'Anual';

  @override
  String get cycleWeeklyShort => 'sem.';

  @override
  String get cycleMonthlyShort => 'mes';

  @override
  String get cycleQuarterlyShort => 'trim.';

  @override
  String get cycleYearlyShort => 'año';

  @override
  String scanFound(String details) {
    return 'Encontrado: $details';
  }

  @override
  String scanRenewsDate(String date) {
    return 'se renueva el $date';
  }

  @override
  String scanChargeFound(String price, String cycle) {
    return 'Cargo encontrado: $price/$cycle.';
  }

  @override
  String scanWhichService(String name, String price, String cycle) {
    return 'Cargo para $name encontrado: $price/$cycle. ¿Qué servicio es?';
  }

  @override
  String scanBilledQuestion(String name) {
    return '¿Se factura $name mensual o anualmente?';
  }

  @override
  String scanMissingPrice(String name) {
    return 'No encontré el precio. ¿Cuánto cuesta $name?';
  }

  @override
  String get categoryStreaming => 'Streaming';

  @override
  String get categoryMusic => 'Música';

  @override
  String get categoryAi => 'IA';

  @override
  String get categoryProductivity => 'Productividad';

  @override
  String get categoryStorage => 'Almacenamiento';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryGaming => 'Juegos';

  @override
  String get categoryReading => 'Lectura';

  @override
  String get categoryCommunication => 'Comunicación';

  @override
  String get categoryNews => 'Noticias';

  @override
  String get categoryFinance => 'Finanzas';

  @override
  String get categoryEducation => 'Educación';

  @override
  String get categoryVpn => 'VPN';

  @override
  String get categoryDeveloper => 'Desarrollador';

  @override
  String get categoryBundle => 'Paquete';

  @override
  String get categoryOther => 'Otro';

  @override
  String get paymentsTrackedHint =>
      'Los pagos se rastrearán tras cada renovación';

  @override
  String get renewsToday => 'Se renueva hoy';

  @override
  String get renewsTomorrow => 'Se renueva mañana';

  @override
  String renewsInDays(int days) {
    return 'Se renueva en $days días';
  }

  @override
  String renewsOnDate(String date) {
    return 'Se renueva el $date';
  }

  @override
  String get renewedYesterday => 'Se renovó ayer';

  @override
  String renewedDaysAgo(int days) {
    return 'Se renovó hace $days días';
  }

  @override
  String get discoveryTipsTitle => 'Dónde encontrar tus suscripciones';

  @override
  String get discoveryTipBank => 'Extracto bancario';

  @override
  String get discoveryTipBankDesc =>
      'Haz una captura de tus transacciones — las encontraremos todas de una vez';

  @override
  String get discoveryTipEmail => 'Búsqueda por email';

  @override
  String get discoveryTipEmailDesc =>
      'Busca «suscripción», «recibo» o «renovación» en tu bandeja de entrada';

  @override
  String get discoveryTipAppStore => 'App Store / Play Store';

  @override
  String get discoveryTipAppStoreDesc =>
      'Ajustes → Suscripciones muestra todas las suscripciones de apps activas';

  @override
  String get discoveryTipPaypal => 'PayPal y apps de pago';

  @override
  String get discoveryTipPaypalDesc =>
      'Revisa los pagos automáticos en PayPal, Revolut o tu app de pagos';

  @override
  String get sectionAccount => 'CUENTA';

  @override
  String get accountAnonymous => 'Anónimo';

  @override
  String get accountBackupPrompt => 'Haz copia de seguridad';

  @override
  String get accountBackedUp => 'Copia hecha';

  @override
  String accountSignedInAs(String email) {
    return 'Sesión como $email';
  }

  @override
  String get syncStatusSyncing => 'Sincronizando...';

  @override
  String get syncStatusSynced => 'Sincronizado';

  @override
  String syncStatusLastSync(String time) {
    return 'Última sincro: $time';
  }

  @override
  String get syncStatusOffline => 'Sin conexión';

  @override
  String get syncStatusNeverSynced => 'Aún no sincronizado';

  @override
  String get signInToBackUp => 'Inicia sesión para guardar tus datos';

  @override
  String get signInWithApple => 'Iniciar sesión con Apple';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get signInWithEmail => 'Iniciar sesión con email';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutConfirm =>
      '¿Seguro que quieres cerrar sesión? Tus datos permanecerán en este dispositivo.';

  @override
  String get annualSavingsTitle => 'CAMBIAR A ANUAL';

  @override
  String get annualSavingsSubtitle =>
      'ahorros potenciales al cambiar a planes anuales';

  @override
  String annualSavingsCoverage(int matched, int total) {
    return 'Basado en $matched de $total suscripciones';
  }

  @override
  String annualSavingsHint(String name) {
    return 'Revisa los ajustes de tu cuenta de $name para opciones de facturación anual';
  }

  @override
  String get seeAll => 'Ver todo';

  @override
  String get allSavingsTitle => 'Ahorros anuales';

  @override
  String get allSavingsSubtitle =>
      'Cambia estos planes mensuales a anuales para ahorrar';

  @override
  String get annualPlanLabel => 'PLAN ANUAL';

  @override
  String annualPlanAvailable(String amount) {
    return 'Plan anual disponible — ahorra $amount/año';
  }

  @override
  String get noAnnualPlan => 'No hay plan anual disponible para este servicio';

  @override
  String monthlyVsAnnual(String monthly, String annual) {
    return '$monthly/mes → $annual/año';
  }

  @override
  String get perYear => '/año';

  @override
  String get insightDidYouKnow => '¿SABÍAS QUE...?';

  @override
  String get insightSaveMoney => 'AHORRA';

  @override
  String get insightLearnMore => 'Saber más';

  @override
  String get insightProLabel => 'CONSEJO PRO';

  @override
  String get insightUnlockPro => 'Desbloquear con Pro';

  @override
  String get insightProTeaser =>
      'Mejora a Pro para consejos de ahorro personalizados.';

  @override
  String get insightProTeaserTitle => 'Consejos de ahorro personalizados';

  @override
  String trialBannerDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días restantes',
      one: '1 día restante',
    );
    return 'Prueba Pro · $_temp0';
  }

  @override
  String get trialBannerExpired => 'Prueba Pro expirada';

  @override
  String get trialBannerUpgrade => 'Mejorar';

  @override
  String get trialPromptTitle => 'Prueba todo gratis durante 7 días';

  @override
  String get trialPromptSubtitle =>
      'Acceso Pro completo — sin compromiso, sin pago.';

  @override
  String get trialPromptFeature1 => 'Suscripciones ilimitadas';

  @override
  String get trialPromptFeature2 =>
      'Escáner de trampas IA — escaneos ilimitados';

  @override
  String get trialPromptFeature3 => 'Recordatorios anticipados (7d, 3d, 1d)';

  @override
  String get trialPromptFeature4 => 'Panel de gastos y estadísticas';

  @override
  String get trialPromptFeature5 =>
      'Guías de cancelación y consejos de reembolso';

  @override
  String get trialPromptFeature6 =>
      'Consejos inteligentes y tarjetas de ahorro';

  @override
  String get trialPromptLegal =>
      'Después de 7 días: rastrea hasta 3 suscripciones gratis, o desbloquea todo por £4.99 — una vez, para siempre.';

  @override
  String get trialPromptCta => 'Iniciar prueba gratuita';

  @override
  String get trialPromptDismiss => 'Omitir por ahora';

  @override
  String get trialExpiredTitle => 'Tu prueba de 7 días ha terminado';

  @override
  String trialExpiredSubtitle(int count, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones',
      one: '1 suscripción',
    );
    return 'Rastreaste $_temp0 con un valor de $price/mes.';
  }

  @override
  String trialExpiredFrozen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suscripciones están ahora congeladas',
      one: '1 suscripción está ahora congelada',
    );
    return '$_temp0';
  }

  @override
  String get trialExpiredCta => 'Desbloquear Chompd Pro — £4.99';

  @override
  String get trialExpiredDismiss => 'Continuar con la versión gratuita';

  @override
  String get frozenSectionHeader => 'CONGELADAS — MEJORA PARA DESBLOQUEAR';

  @override
  String get frozenBadge => 'CONGELADA';

  @override
  String get frozenTapToUpgrade => 'Toca para mejorar';

  @override
  String cancelledStatusExpires(String date) {
    return 'Cancelada — expira el $date';
  }

  @override
  String cancelledStatusExpired(String date) {
    return 'Cancelada — expiró el $date';
  }

  @override
  String get reactivateSubscription => 'Reactivar suscripción';

  @override
  String get scanErrorGeneric =>
      'No se pudo leer esta imagen. Prueba otra captura.';

  @override
  String get scanErrorEmpty =>
      'El archivo de imagen parece vacío. Inténtalo de nuevo.';

  @override
  String scanServiceFound(String name) {
    return '¡$name encontrado!';
  }

  @override
  String get scanNoSubscriptionsFound =>
      'No se encontraron suscripciones en esta imagen. Intenta escanear un recibo, email de confirmación o captura de la tienda de apps.';

  @override
  String scanRecurringCharge(String name) {
    return 'Se encontró un cargo recurrente que parece ser $name.';
  }

  @override
  String scanConfirmQuestion(String pct, String name) {
    return 'El $pct% de los usuarios con este cargo dicen que es $name. ¿Es correcto?';
  }

  @override
  String scanPersonalOrTeam(String name) {
    return 'Parece $name. ¿Suscripción personal o de equipo/empresa?';
  }

  @override
  String get scanPersonal => 'Personal';

  @override
  String get scanTeamBusiness => 'Equipo / Empresa';

  @override
  String get scanNotSure => 'No estoy seguro';

  @override
  String scanAllDoneAdded(String added, String total) {
    return '¡Listo! $added de $total suscripciones añadidas.';
  }

  @override
  String scanSubsConfirmed(String count) {
    return '¡$count suscripciones confirmadas!';
  }

  @override
  String scanConfirmed(String name) {
    return '¡$name confirmado!';
  }

  @override
  String get scanLimitReached =>
      'Has usado tu escaneo gratuito. ¡Pasa a Pro para escaneos ilimitados!';

  @override
  String get scanUnableToProcess =>
      'No se pudo procesar la imagen. Inténtalo de nuevo.';

  @override
  String scanTrapDetectedIn(String name) {
    return '⚠️ ¡Trampa detectada en $name!';
  }

  @override
  String scanTrackingTrial(String name) {
    return 'Seguimiento de prueba de $name. ¡Te recordaremos antes del cobro!';
  }

  @override
  String scanAddedWithAlerts(String name) {
    return '$name añadido con alertas de prueba.';
  }

  @override
  String get scanNoConnection =>
      'Sin conexión a internet. Comprueba tu Wi-Fi o datos móviles e inténtalo de nuevo.';

  @override
  String get scanTooManyRequests =>
      'Demasiadas solicitudes — espera un momento e inténtalo de nuevo.';

  @override
  String get scanServiceDown =>
      'Nuestro servicio de escaneo no está disponible temporalmente. Inténtalo en unos minutos.';

  @override
  String get scanSomethingWrong => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get scanConvertToGbp => 'Convertir a £ GBP';

  @override
  String scanKeepInCurrency(String currency) {
    return 'Mantener en $currency';
  }

  @override
  String scanPriceCurrency(String currency, String price) {
    return 'El precio está en $currency ($price). ¿Cómo quieres rastrearlo?';
  }

  @override
  String get introPrice => 'Precio de lanzamiento';

  @override
  String introPriceExpires(String date) {
    return 'Precio de lanzamiento termina el $date';
  }

  @override
  String introPriceDaysRemaining(int days) {
    return '⚠️ Precio de lanzamiento — quedan $days días';
  }

  @override
  String get unmatchedServiceNote =>
      'Aún no tenemos datos específicos para este servicio. Las guías de cancelación y reembolso muestran pasos generales para tu plataforma.';

  @override
  String get aiConsentTitle => 'Escaneo con IA';

  @override
  String get aiConsentBody =>
      'Chompd utiliza Anthropic Claude, un servicio de IA externo, para analizar tus capturas de pantalla y texto en busca de detalles de suscripción.';

  @override
  String get aiConsentBullet1 =>
      'Tu imagen o texto se envía a los servidores de Anthropic para su análisis';

  @override
  String get aiConsentBullet2 =>
      'La IA extrae información: nombre, precio, fechas y trampas ocultas';

  @override
  String get aiConsentBullet3 =>
      'Anthropic puede retener datos hasta 30 días para monitoreo de seguridad';

  @override
  String get aiConsentBullet4 =>
      'Tus datos no se usan para entrenar modelos de IA';

  @override
  String get aiConsentBullet5 =>
      'No se adjuntan identificadores personales a los datos enviados';

  @override
  String get aiConsentLocalNote =>
      'Los datos de suscripción se almacenan solo en tu dispositivo.';

  @override
  String get aiConsentAccept => 'Entendido, continuar';

  @override
  String get aiConsentCancel => 'Cancelar';
}
