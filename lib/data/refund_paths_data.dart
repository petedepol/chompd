import 'package:intl/intl.dart';

import '../models/refund_template.dart';
import '../models/subscription.dart';

/// The four escalation paths for recovering money.
final List<RefundTemplate> refundPaths = [
  const RefundTemplate(
    id: 'app_store',
    name: 'Apple App Store Refund',
    path: RefundPath.appStore,
    steps: [
      'Go to reportaproblem.apple.com',
      'Sign in with your Apple ID',
      'Find the charge in your purchase history',
      'Tap "Report a Problem" next to the charge',
      'Select "I didn\'t intend to purchase this item" or '
          '"I didn\'t authorise this purchase"',
      'Add a brief explanation: "I was misled by trial terms"',
      'Submit your request',
    ],
    url: 'https://reportaproblem.apple.com',
    successRate: '~80% for first request',
    timeframe: 'Usually refunded within 48 hours',
  ),
  const RefundTemplate(
    id: 'google_play',
    name: 'Google Play Refund',
    path: RefundPath.googlePlay,
    steps: [
      'Go to play.google.com/store/account/orderhistory',
      'Find the charge you want to dispute',
      'Click "Report a problem"',
      'Select "I didn\'t mean to make this purchase" or '
          '"My purchase doesn\'t work as expected"',
      'Fill in the details and submit',
    ],
    url: 'https://play.google.com/store/account/orderhistory',
    successRate: '~70% for first request',
    timeframe: 'Usually 1\u20134 business days',
  ),
  const RefundTemplate(
    id: 'direct_billing',
    name: 'Email the Company',
    path: RefundPath.directBilling,
    steps: [
      'Find the company\'s support email (check their website '
          'footer or your confirmation email)',
      'Copy the pre-written dispute email below',
      'Fill in the highlighted fields with your details',
      'Send the email',
      'If no response in 7 days, follow up once',
      'If still no response after 14 days, escalate to bank chargeback',
    ],
    emailTemplate: '''Subject: Refund Request \u2014 Misleading Subscription Terms

Dear [Company] Support,

I signed up for what I understood to be a {trial_price} trial of {service_name} on {signup_date}.

I was not clearly informed that this would automatically renew at {real_price}. The pricing terms were not presented transparently at the point of purchase.

Under the UK Consumer Rights Act 2015, consumers are entitled to clear and transparent pricing. I am requesting a full refund of {charge_amount} charged on {charge_date}.

Please process this refund within 14 days.

Regards,
[Your name]''',
    successRate: '~50\u201360% \u2014 varies by company',
    timeframe: '3\u201314 days depending on company',
  ),
  const RefundTemplate(
    id: 'bank_chargeback',
    name: 'Bank Chargeback (Last Resort)',
    path: RefundPath.bankChargeback,
    steps: [
      'Open your banking app or call your bank',
      'Find the transaction you want to dispute',
      'Select "Dispute transaction" or "Chargeback"',
      'Reason: "Misleading subscription terms" or '
          '"Services not as described"',
      'Provide evidence: screenshot of the original offer '
          'showing the trial price',
      'Your bank will investigate \u2014 this usually takes '
          '5\u201310 business days',
    ],
    successRate: '~70\u201380% \u2014 banks are familiar with this pattern',
    timeframe: '5\u201310 business days',
  ),
];

/// Auto-fills the direct billing dispute email template with
/// subscription-specific details.
String buildDisputeEmail(Subscription sub) {
  final template = refundPaths
      .firstWhere((p) => p.id == 'direct_billing')
      .emailTemplate!;

  final dateFormat = DateFormat('d MMMM yyyy');

  return template
      .replaceAll('{service_name}', sub.name)
      .replaceAll(
        '{trial_price}',
        '\u00A3${sub.trialPrice?.toStringAsFixed(2) ?? "free"}',
      )
      .replaceAll(
        '{real_price}',
        '\u00A3${sub.realPrice?.toStringAsFixed(2) ?? sub.price.toStringAsFixed(2)}/${sub.cycle.shortLabel}',
      )
      .replaceAll('{signup_date}', dateFormat.format(sub.createdAt))
      .replaceAll(
        '{charge_amount}',
        '\u00A3${sub.realPrice?.toStringAsFixed(2) ?? sub.price.toStringAsFixed(2)}',
      )
      .replaceAll('{charge_date}', dateFormat.format(sub.nextRenewal));
}
