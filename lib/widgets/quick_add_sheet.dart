import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../screens/detail/add_edit_screen.dart';
import '../services/haptic_service.dart';
import '../utils/l10n_extension.dart';

/// Pre-loaded popular service templates for quick-add.
class ServiceTemplate {
  final String name;
  final String category;
  final String icon;
  final String brandColor;

  const ServiceTemplate({
    required this.name,
    required this.category,
    required this.icon,
    required this.brandColor,
  });
}

const _templates = [
  ServiceTemplate(name: 'Netflix', category: 'streaming', icon: 'N', brandColor: '#E50914'),
  ServiceTemplate(name: 'Spotify', category: 'music', icon: 'S', brandColor: '#1DB954'),
  ServiceTemplate(name: 'Disney+', category: 'streaming', icon: 'D', brandColor: '#113CCF'),
  ServiceTemplate(name: 'Apple Music', category: 'music', icon: '\u266B', brandColor: '#FC3C44'),
  ServiceTemplate(name: 'YouTube Premium', category: 'streaming', icon: '\u25B6', brandColor: '#FF0000'),
  ServiceTemplate(name: 'Amazon Prime', category: 'streaming', icon: 'A', brandColor: '#FF9900'),
  ServiceTemplate(name: 'iCloud+', category: 'storage', icon: '\u2601', brandColor: '#4285F4'),
  ServiceTemplate(name: 'ChatGPT Plus', category: 'ai', icon: 'G', brandColor: '#10A37F'),
  ServiceTemplate(name: 'Claude Pro', category: 'ai', icon: 'C', brandColor: '#D97757'),
  ServiceTemplate(name: 'Xbox Game Pass', category: 'gaming', icon: 'X', brandColor: '#107C10'),
  ServiceTemplate(name: 'PlayStation Plus', category: 'gaming', icon: 'P', brandColor: '#003087'),
  ServiceTemplate(name: 'Adobe CC', category: 'developer', icon: 'Ai', brandColor: '#FF0000'),
  ServiceTemplate(name: 'Figma', category: 'developer', icon: 'F', brandColor: '#A259FF'),
  ServiceTemplate(name: 'Notion', category: 'productivity', icon: 'N', brandColor: '#000000'),
  ServiceTemplate(name: 'Strava', category: 'fitness', icon: '\u25B2', brandColor: '#FC4C02'),
  ServiceTemplate(name: 'Zwift', category: 'fitness', icon: 'Z', brandColor: '#FC6719'),
  ServiceTemplate(name: 'NordVPN', category: 'vpn', icon: 'N', brandColor: '#4687FF'),
  ServiceTemplate(name: 'Dropbox', category: 'storage', icon: 'D', brandColor: '#0061FE'),
  ServiceTemplate(name: 'Microsoft 365', category: 'productivity', icon: 'M', brandColor: '#00A4EF'),
  ServiceTemplate(name: 'The Athletic', category: 'news', icon: 'A', brandColor: '#1DA1F2'),
];

/// Shows the quick-add bottom sheet with popular services + manual add.
void showQuickAddSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _QuickAddSheet(),
  );
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  const _QuickAddSheet();

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  String _search = '';

  List<ServiceTemplate> get _filtered {
    if (_search.isEmpty) return _templates;
    final q = _search.toLowerCase();
    return _templates
        .where((t) =>
            t.name.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q))
        .toList();
  }

  void _onSearchChanged(String value) {
    setState(() => _search = value);
  }

  void _openAddFormWithTemplate(ServiceTemplate tpl) {
    HapticService.instance.selection();
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditScreen(
          prefillName: tpl.name,
          prefillCategory: tpl.category,
          prefillIcon: tpl.icon,
          prefillBrandColor: tpl.brandColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: c.bgElevated.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.addSubscriptionSheet,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: c.textDim,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Manual add button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddEditScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [c.mintDark, c.mint],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: c.bg),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.addManually,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.bg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Divider with "or choose a service"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: Divider(color: c.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    context.l10n.orChooseService,
                    style: TextStyle(
                      fontSize: 10,
                      color: c.textDim,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: c.border)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: _onSearchChanged,
              style: TextStyle(fontSize: 13, color: c.text),
              decoration: InputDecoration(
                hintText: context.l10n.searchServices,
                hintStyle: TextStyle(color: c.textDim),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: c.textDim,
                ),
                filled: true,
                fillColor: c.bgCard,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.mint),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Service list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final tpl = _filtered[index];
                return _TemplateRow(
                  template: tpl,
                  onTap: () => _openAddFormWithTemplate(tpl),
                );
              },
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }
}

// ─── Template Row ───

class _TemplateRow extends StatelessWidget {
  final ServiceTemplate template;
  final VoidCallback onTap;
  const _TemplateRow({
    required this.template,
    required this.onTap,
  });

  Color get _color {
    final hex = template.brandColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [_color.withValues(alpha: 0.87), _color.withValues(alpha: 0.53)],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                template.icon,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                  ),
                  Text(
                    AppConstants.localisedCategory(template.category, context.l10n),
                    style: TextStyle(
                      fontSize: 10,
                      color: c.textDim,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: c.mint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: c.mint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
