import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../utils/l10n_extension.dart';
import '../../models/subscription.dart';
import '../../providers/currency_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/mascot_image.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  /// Called when the user finishes or skips onboarding.
  /// [openScan] is true when the user tapped "Scan a Screenshot".
  /// [openManualAdd] is true when the user tapped "Add Manually".
  final Future<void> Function({bool openScan, bool openManualAdd}) onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = _pageController.page?.round() ?? 0;
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding({bool openScan = false, bool openManualAdd = false}) async {
    await widget.onComplete(openScan: openScan, openManualAdd: openManualAdd);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildWelcomePage(),
              _buildHowItWorksPage(),
              _buildNotificationsPage(),
              _buildGetStartedPage(),
            ],
          ),
          // Navigation indicators and buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  // ─── Page 1: Welcome ───
  Widget _buildWelcomePage() {
    final c = context.colors;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Piranha mascot with subtle glow behind
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background glow
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            c.mint.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const MascotImage(
                      asset: 'piranha_wave.png',
                      size: 220,
                      fadeIn: true,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Title
                Text(
                  context.l10n.onboardingTitle1,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: c.text,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  context.l10n.onboardingSubtitle1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: c.textMid,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Confronting stat
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: c.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💸', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          context.l10n.onboardingStatWaste(Subscription.formatPrice(240, ref.watch(currencyProvider), decimals: 0)),
                          style: TextStyle(
                            fontSize: 12,
                            color: c.textMid,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Page 2: How It Works ───
  Widget _buildHowItWorksPage() {
    final c = context.colors;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Piranha mascot — with phone (scan tutorial)
                const MascotImage(
                  asset: 'piranha_full.png',
                  size: 120,
                  fadeIn: true,
                ),
                const SizedBox(height: 24),
                _buildStep(
                  number: 1,
                  icon: Icons.camera_alt,
                  iconColor: c.mint,
                  title: context.l10n.onboardingStep1Title,
                  subtitle: context.l10n.onboardingStep1Subtitle,
                  isLast: false,
                ),
                _buildStep(
                  number: 2,
                  icon: Icons.auto_awesome,
                  iconColor: c.purple,
                  title: context.l10n.onboardingStep2Title,
                  subtitle: context.l10n.onboardingStep2Subtitle,
                  isLast: false,
                ),
                _buildStep(
                  number: 3,
                  icon: Icons.check_circle,
                  iconColor: c.mint,
                  title: context.l10n.onboardingStep3Title,
                  subtitle: context.l10n.onboardingStep3Subtitle,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool isLast,
  }) {
    final c = context.colors;
    return Column(
      children: [
        Row(
          children: [
            // Icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.bgElevated,
                border: Border.all(
                  color: iconColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: c.textDim,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          // Dotted connector line
          SizedBox(
            height: 24,
            child: Stack(
              children: List.generate(
                4,
                (index) => Positioned(
                  left: 19,
                  top: index * 6.0,
                  child: Container(
                    width: 2,
                    height: 4,
                    color: c.border,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 8),
      ],
    );
  }

  // ─── Page 3: Notifications ───
  Widget _buildNotificationsPage() {
    final c = context.colors;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Piranha mascot — alert
                      const MascotImage(
                        asset: 'piranha_alert.png',
                        size: 160,
                        fadeIn: true,
                      ),
                      const SizedBox(height: 28),
                      // Title
                      Text(
                        context.l10n.onboardingTitle3,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: c.text,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      Text(
                        context.l10n.onboardingSubtitle3,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: c.textMid,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // What you get — compact feature pills
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _notifFeature(context.l10n.onboardingNotifMorning),
                          _notifFeature(context.l10n.onboardingNotif7days),
                          _notifFeature(context.l10n.onboardingNotifTrial),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await NotificationService.instance.requestPermission();
                      _nextPage();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.mint,
                      foregroundColor: c.bg,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      context.l10n.allowNotifications,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _nextPage,
                  child: Text(
                    context.l10n.maybeLater,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.textDim,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Page 4: Get Started ───
  Widget _buildGetStartedPage() {
    final c = context.colors;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Piranha mascot — celebrate
                      const MascotImage(
                        asset: 'piranha_celebrate.png',
                        size: 160,
                        fadeIn: true,
                      ),
                      const SizedBox(height: 28),
                      // Title
                      Text(
                        context.l10n.onboardingTitle4,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: c.text,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Subtitle — more urgency
                      Text(
                        context.l10n.onboardingSubtitle4,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: c.textMid,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          c.mint,
                          c.mintDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: () => _completeOnboarding(openScan: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: c.bg,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.scanAScreenshot,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _completeOnboarding(openManualAdd: true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.textMid,
                      side: BorderSide(
                        color: c.border,
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      context.l10n.addManually,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    context.l10n.skipForNow,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: c.textDim,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _notifFeature(String text) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: c.amber.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: c.amber,
        ),
      ),
    );
  }

  // ─── Bottom Navigation ───
  Widget _buildBottomNavigation() {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? c.mint
                      : c.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          // Show Next button only on pages 1-2
          if (_currentPage < 2) ...[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _nextPage,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.next,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.mint,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: c.mint,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
