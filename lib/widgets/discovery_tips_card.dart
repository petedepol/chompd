import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/l10n_extension.dart';

/// Collapsible card showing tips for where to find active subscriptions.
///
/// Displayed on the home screen empty state to help users discover
/// what to scan (bank statements, emails, app store, payment apps).
class DiscoveryTipsCard extends StatefulWidget {
  const DiscoveryTipsCard({super.key});

  @override
  State<DiscoveryTipsCard> createState() => _DiscoveryTipsCardState();
}

class _DiscoveryTipsCardState extends State<DiscoveryTipsCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ChompdColors.border,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header — always visible, tappable
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ChompdColors.purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: ChompdColors.purple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.discoveryTipsTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ChompdColors.text,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: ChompdColors.textDim,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 1,
                  color: ChompdColors.border,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      _TipRow(
                        icon: Icons.account_balance,
                        iconColor: ChompdColors.mint,
                        title: l10n.discoveryTipBank,
                        subtitle: l10n.discoveryTipBankDesc,
                      ),
                      const SizedBox(height: 12),
                      _TipRow(
                        icon: Icons.email_outlined,
                        iconColor: ChompdColors.blue,
                        title: l10n.discoveryTipEmail,
                        subtitle: l10n.discoveryTipEmailDesc,
                      ),
                      const SizedBox(height: 12),
                      _TipRow(
                        icon: Icons.phone_iphone,
                        iconColor: ChompdColors.amber,
                        title: l10n.discoveryTipAppStore,
                        subtitle: l10n.discoveryTipAppStoreDesc,
                      ),
                      const SizedBox(height: 12),
                      _TipRow(
                        icon: Icons.payment,
                        iconColor: ChompdColors.purple,
                        title: l10n.discoveryTipPaypal,
                        subtitle: l10n.discoveryTipPaypalDesc,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _TipRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 15,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ChompdColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: ChompdColors.textDim,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
