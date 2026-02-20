import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/theme.dart';
import '../../utils/l10n_extension.dart';
import '../../providers/entitlement_provider.dart';
import '../../services/haptic_service.dart';
import '../../widgets/mascot_image.dart';

const _kTrialPromptShownKey = 'trial_prompt_shown';

/// Whether the trial prompt has already been shown.
Future<bool> hasTrialPromptBeenShown() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kTrialPromptShownKey) ?? false;
}

/// Mark the trial prompt as shown.
Future<void> markTrialPromptShown() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kTrialPromptShownKey, true);
}

/// Glassmorphic modal offering the 7-day free trial.
///
/// Shown once after onboarding completes. User can either start the
/// trial or dismiss to free tier.
class TrialPromptScreen extends ConsumerWidget {
  const TrialPromptScreen({super.key});

  /// Show the trial prompt as a full-screen modal dialog.
  static Future<void> show(BuildContext context) async {
    await markTrialPromptShown();
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => const TrialPromptScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.bgElevated.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: c.mint.withValues(alpha: 0.2),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mascot
                  const MascotImage(
                    asset: 'piranha_wave.png',
                    size: 100,
                    fadeIn: true,
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    l.trialPromptTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    l.trialPromptSubtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: c.textMid,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Feature list
                  _FeatureRow(icon: Icons.all_inclusive, text: l.trialPromptFeature1, color: c.mint),
                  _FeatureRow(icon: Icons.auto_awesome, text: l.trialPromptFeature2, color: c.purple),
                  _FeatureRow(icon: Icons.notifications_active_outlined, text: l.trialPromptFeature3, color: c.amber),
                  _FeatureRow(icon: Icons.dashboard_outlined, text: l.trialPromptFeature4, color: c.blue),
                  _FeatureRow(icon: Icons.help_outline, text: l.trialPromptFeature5, color: c.mint),
                  _FeatureRow(icon: Icons.share_outlined, text: l.trialPromptFeature6, color: c.purple),
                  const SizedBox(height: 20),

                  // Legal line
                  Text(
                    l.trialPromptLegal,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: c.textDim,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Start Trial CTA
                  GestureDetector(
                    onTap: () async {
                      HapticService.instance.success();
                      await ref
                          .read(entitlementProvider.notifier)
                          .startTrial();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [c.mintDark, c.mint],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: c.mint.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l.trialPromptCta,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: c.bg,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dismiss
                  GestureDetector(
                    onTap: () {
                      HapticService.instance.light();
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l.trialPromptDismiss,
                        style: TextStyle(
                          fontSize: 13,
                          color: c.textDim,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _FeatureRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: c.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
