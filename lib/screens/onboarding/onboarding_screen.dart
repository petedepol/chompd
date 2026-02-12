import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/notification_service.dart';
import '../../widgets/mascot_image.dart';

class OnboardingScreen extends StatefulWidget {
  /// Called when the user finishes or skips onboarding.
  /// Can be async (e.g. to persist the "seen" flag).
  final Future<void> Function() onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
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

  Future<void> _completeOnboarding() async {
    await widget.onComplete();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChompdColors.bg,
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
                            ChompdColors.mint.withValues(alpha: 0.08),
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
                  'Bite Back at Subscriptions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ChompdColors.text,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Subtitle
                const Text(
                  'Chompd tracks every subscription, catches hidden traps, and helps you cancel what you don\'t need.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ChompdColors.textMid,
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
                    color: ChompdColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ChompdColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('💸', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'The average person wastes £240/year on forgotten subscriptions',
                          style: TextStyle(
                            fontSize: 12,
                            color: ChompdColors.textMid,
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
                  iconColor: ChompdColors.mint,
                  title: 'Snap a screenshot',
                  subtitle: 'Receipt, email, or bank statement',
                  isLast: false,
                ),
                _buildStep(
                  number: 2,
                  icon: Icons.auto_awesome,
                  iconColor: ChompdColors.purple,
                  title: 'AI reads it instantly',
                  subtitle: 'Price, renewal date, and hidden traps',
                  isLast: false,
                ),
                _buildStep(
                  number: 3,
                  icon: Icons.check_circle,
                  iconColor: ChompdColors.mint,
                  title: 'Done. Tracked forever.',
                  subtitle: 'Get reminders before you\'re charged',
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
    return Column(
      children: [
        Row(
          children: [
            // Icon circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ChompdColors.bgElevated,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ChompdColors.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ChompdColors.textDim,
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
                    color: ChompdColors.border,
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
                        'Stay Ahead of Renewals',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: ChompdColors.text,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      const Text(
                        'We\'ll remind you before you\'re charged — no surprises.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ChompdColors.textMid,
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
                          _notifFeature('Morning of renewal'),
                          _notifFeature('7 days before'),
                          _notifFeature('Trial expiry alerts'),
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
                      backgroundColor: ChompdColors.mint,
                      foregroundColor: ChompdColors.bg,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Allow Notifications',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _nextPage,
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ChompdColors.textDim,
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
                        'Add Your First Subscription',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: ChompdColors.text,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Subtitle — more urgency
                      const Text(
                        'Most people find forgotten subscriptions in their first scan. Let\'s see what you\'re paying for.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ChompdColors.textMid,
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
                          ChompdColors.mint,
                          ChompdColors.mintDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: ChompdColors.bg,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Scan a Screenshot',
                            style: TextStyle(
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
                    onPressed: _completeOnboarding,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ChompdColors.textMid,
                      side: const BorderSide(
                        color: ChompdColors.border,
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Add Manually',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ChompdColors.textDim,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ChompdColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ChompdColors.amber.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: ChompdColors.amber,
        ),
      ),
    );
  }

  // ─── Bottom Navigation ───
  Widget _buildBottomNavigation() {
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
                      ? ChompdColors.mint
                      : ChompdColors.border,
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
                  children: const [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ChompdColors.mint,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: ChompdColors.mint,
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
