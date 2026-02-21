import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/theme.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/mascot_image.dart';

/// Preference key for AI consent acceptance.
const _kAiConsentAccepted = 'ai_scan_consent_accepted';

/// Checks whether AI consent has been given. If not, shows the consent screen.
///
/// Returns `true` if consent exists or user just accepted.
/// Returns `false` if user cancelled — caller should abort the scan.
Future<bool> checkAiConsent(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final hasConsent = prefs.getBool(_kAiConsentAccepted) ?? false;
  if (hasConsent) return true;

  if (!context.mounted) return false;

  final accepted = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const AiConsentScreen(),
    ),
  );

  return accepted == true;
}

/// One-time AI consent screen shown before the user's first scan.
///
/// Required by Apple Guideline 5.1.2(i) — apps must get explicit consent
/// before sending user data to third-party AI services.
class AiConsentScreen extends StatelessWidget {
  const AiConsentScreen({super.key});

  Future<void> _accept(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAiConsentAccepted, true);
    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _cancel(BuildContext context) {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Piranha mascot
              const MascotImage(
                asset: 'piranha_thinking.png',
                size: 100,
                fadeIn: true,
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                l.aiConsentTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Body text
              Text(
                l.aiConsentBody,
                style: TextStyle(
                  fontSize: 14,
                  color: c.textMid,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Bullet points card
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BulletPoint(text: l.aiConsentBullet1, color: c.textMid),
                        const SizedBox(height: 10),
                        _BulletPoint(text: l.aiConsentBullet2, color: c.textMid),
                        const SizedBox(height: 10),
                        _BulletPoint(text: l.aiConsentBullet3, color: c.textMid),
                        const SizedBox(height: 10),
                        _BulletPoint(text: l.aiConsentBullet4, color: c.mint),
                        const SizedBox(height: 10),
                        _BulletPoint(text: l.aiConsentBullet5, color: c.mint),
                        const SizedBox(height: 16),
                        // Local storage note
                        Row(
                          children: [
                            Icon(Icons.phone_iphone, size: 16, color: c.textDim),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l.aiConsentLocalNote,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: c.textDim,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Primary CTA — "I Understand, Continue"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _accept(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.mint,
                    foregroundColor: c.bg,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l.aiConsentAccept),
                ),
              ),

              const SizedBox(height: 8),

              // Secondary — "Cancel"
              TextButton(
                onPressed: () => _cancel(context),
                child: Text(
                  l.aiConsentCancel,
                  style: TextStyle(
                    fontSize: 14,
                    color: c.textDim,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single bullet point row with a coloured dot.
class _BulletPoint extends StatelessWidget {
  final String text;
  final Color color;

  const _BulletPoint({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
