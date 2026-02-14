import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../config/theme.dart';
import '../../models/subscription.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/haptic_service.dart';
import '../../utils/date_helpers.dart';
import '../../utils/l10n_extension.dart';
import '../detail/detail_screen.dart';

/// Calendar view showing which days you get charged.
///
/// Each day displays coloured dots for renewing subscriptions.
/// Tap a day to see the full breakdown in a bottom sheet.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  String get _currencyCode => ref.read(currencyProvider);

  @override
  Widget build(BuildContext context) {
    final calendar = ref.watch(renewalCalendarProvider);
    ref.watch(currencyProvider); // Rebuild when currency changes

    return Scaffold(
      backgroundColor: ChompdColors.bg,
      body: CustomScrollView(
        slivers: [
          // Safe area
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.top + 8,
            ),
          ),

          // ─── Header ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _BackButton(onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.renewalCalendar,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ChompdColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ─── Calendar Widget ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildCalendar(calendar),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ─── Selected Day Detail / Monthly Summary ───
          SliverToBoxAdapter(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _selectedDay != null
                    ? _buildDayDetail(calendar)
                    : _buildMonthlySummary(calendar),
              ),
            ),
          ),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(Map<DateTime, List<Subscription>> calendar) {
    return Container(
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ChompdColors.border),
      ),
      child: TableCalendar<Subscription>(
        firstDay: DateTime.now().subtract(const Duration(days: 30)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) {
          final key = DateTime(day.year, day.month, day.day);
          return calendar[key] ?? [];
        },
        onDaySelected: (selectedDay, focusedDay) {
          HapticService.instance.selection();
          setState(() {
            // Toggle off if tapping same day again
            _selectedDay = isSameDay(_selectedDay, selectedDay)
                ? null
                : selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
            _selectedDay = null; // Clear day selection when changing month
          });
        },

        // ─── Styling ───
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: ChompdColors.textMid,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: ChompdColors.textMid,
          ),
          titleTextStyle: ChompdTypography.mono(
            size: 14,
            weight: FontWeight.w700,
            color: ChompdColors.text,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: ChompdTypography.mono(
            size: 10,
            color: ChompdColors.textDim,
          ),
          weekendStyle: ChompdTypography.mono(
            size: 10,
            color: ChompdColors.textDim,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: const EdgeInsets.all(3),

          // Default day
          defaultTextStyle: const TextStyle(
            fontSize: 13,
            color: ChompdColors.text,
          ),

          // Weekend
          weekendTextStyle: const TextStyle(
            fontSize: 13,
            color: ChompdColors.textMid,
          ),

          // Today
          todayDecoration: BoxDecoration(
            color: ChompdColors.mintGlow,
            shape: BoxShape.circle,
            border: Border.all(
              color: ChompdColors.mint.withValues(alpha: 0.4),
            ),
          ),
          todayTextStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ChompdColors.mint,
          ),

          // Selected
          selectedDecoration: const BoxDecoration(
            color: ChompdColors.mint,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: ChompdColors.bg,
          ),

          // Markers (the coloured dots)
          markersMaxCount: 4,
          markerSize: 5,
          markerDecoration: const BoxDecoration(
            color: ChompdColors.mint,
            shape: BoxShape.circle,
          ),
        ),

        // Custom builders for brand-coloured dots + bold renewal dates
        calendarBuilders: CalendarBuilders(
          // Tweak 2: Bold renewal dates, dim empty dates
          defaultBuilder: (context, day, focusedDay) {
            final key = DateTime(day.year, day.month, day.day);
            final daySubs = calendar[key] ?? [];
            final hasRenewal = daySubs.isNotEmpty;
            final daySpend =
                daySubs.fold(0.0, (sum, s) => sum + s.price);

            // High-cost day glow: ≥£50 red, ≥£30 amber
            Color? glowColor;
            if (daySpend >= 50) {
              glowColor = ChompdColors.red;
            } else if (daySpend >= 30) {
              glowColor = ChompdColors.amber;
            }

            return Container(
              decoration: glowColor != null
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.25),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    )
                  : null,
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        hasRenewal ? FontWeight.w600 : FontWeight.w400,
                    color: glowColor ?? (hasRenewal
                        ? ChompdColors.text
                        : ChompdColors.textDim),
                  ),
                ),
              ),
            );
          },
          // Tweaks 1+3: Bigger dots with glow, category dedup, overflow count
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;
            return Positioned(
              bottom: 2,
              child: _buildDayDots(events),
            );
          },
        ),
      ),
    );
  }

  /// Builds dots for a day cell — unique colours with glow.
  ///
  /// Up to 3 dots shown individually; 4+ shows 2 dots + "+N" count.
  /// Uses brand colour per sub, falling back to category colour.
  Widget _buildDayDots(List<Subscription> renewals) {
    if (renewals.isEmpty) return const SizedBox.shrink();

    // Unique colours — brand with category fallback, deduplicated
    final colors = renewals.map((s) {
      final brand = _brandColor(s);
      return brand == ChompdColors.textDim
          ? CategoryColors.forCategory(s.category)
          : brand;
    }).toSet().toList();

    if (colors.length <= 3) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: colors
            .map((c) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c,
                      boxShadow: [
                        BoxShadow(
                          color: c.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      );
    } else {
      // 4+ unique colours: show 2 dots + count
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...colors.take(2).map((c) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c,
                    boxShadow: [
                      BoxShadow(
                        color: c.withValues(alpha: 0.4),
                        blurRadius: 3,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),
              )),
          Text(
            '+${colors.length - 2}',
            style: ChompdTypography.mono(
              size: 7,
              color: ChompdColors.textDim,
            ),
          ),
        ],
      );
    }
  }

  /// Detail panel for the selected day.
  Widget _buildDayDetail(Map<DateTime, List<Subscription>> calendar) {
    final key = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    final subs = calendar[key] ?? [];
    final dayTotal = subs.fold(0.0, (sum, s) => sum + s.price);
    final isToday = isSameDay(_selectedDay!, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Row(
          children: [
            Text(
              DateHelpers.shortDate(_selectedDay!),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ChompdColors.text,
              ),
            ),
            if (isToday) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: ChompdColors.mintGlow,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  context.l10n.today,
                  style: ChompdTypography.mono(
                    size: 9,
                    weight: FontWeight.w700,
                    color: ChompdColors.mint,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (subs.isNotEmpty)
              Text(
                Subscription.formatPrice(dayTotal, _currencyCode),
                style: ChompdTypography.mono(
                  size: 16,
                  weight: FontWeight.w700,
                  color: ChompdColors.mint,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (subs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: ChompdColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ChompdColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 28,
                  color: ChompdColors.mint.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.noRenewalsThisDay,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ChompdColors.textDim,
                  ),
                ),
              ],
            ),
          )
        else
          ...subs.map((sub) => _buildSubRow(sub)),
      ],
    );
  }

  /// Row for a single subscription in the day detail.
  Widget _buildSubRow(Subscription sub) {
    final color = _brandColor(sub);
    return GestureDetector(
      onTap: () {
        HapticService.instance.light();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailScreen(subscription: sub),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ChompdColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ChompdColors.border),
        ),
        child: Row(
          children: [
            // Brand dot
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                sub.iconName ?? (sub.name.isNotEmpty ? sub.name[0] : '?'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + cycle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ChompdColors.text,
                    ),
                  ),
                  Text(
                    sub.cycle.localLabel(context.l10n),
                    style: const TextStyle(
                      fontSize: 10,
                      color: ChompdColors.textDim,
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Text(
              sub.priceDisplay,
              style: ChompdTypography.mono(
                size: 13,
                weight: FontWeight.w700,
                color: ChompdColors.text,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: ChompdColors.textDim,
            ),
          ],
        ),
      ),
    );
  }

  /// Monthly summary: busiest days and total.
  Widget _buildMonthlySummary(Map<DateTime, List<Subscription>> calendar) {
    // Filter to focused month
    final monthStart = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final monthEnd = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final monthEntries = calendar.entries.where((e) =>
        !e.key.isBefore(monthStart) && !e.key.isAfter(monthEnd));

    final totalRenewals =
        monthEntries.fold(0, (sum, e) => sum + e.value.length);
    final totalSpend = monthEntries.fold(
      0.0,
      (sum, e) => sum + e.value.fold(0.0, (s, sub) => s + sub.price),
    );

    // Busiest day
    MapEntry<DateTime, List<Subscription>>? busiest;
    for (final entry in monthEntries) {
      if (busiest == null || entry.value.length > busiest.value.length) {
        busiest = entry;
      }
    }

    // Most expensive single day
    MapEntry<DateTime, List<Subscription>>? priciest;
    double priciestSpend = 0;
    for (final entry in monthEntries) {
      final daySpend =
          entry.value.fold(0.0, (sum, s) => sum + s.price);
      if (daySpend > priciestSpend) {
        priciestSpend = daySpend;
        priciest = entry;
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ChompdColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ChompdColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.thisMonth, style: ChompdTypography.sectionLabel),
          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              _StatPill(
                label: context.l10n.renewals,
                value: '$totalRenewals',
                color: ChompdColors.mint,
              ),
              const SizedBox(width: 10),
              _StatPill(
                label: context.l10n.total,
                value: Subscription.formatPrice(totalSpend, _currencyCode),
                color: ChompdColors.mint,
              ),
            ],
          ),

          if (busiest != null && busiest.value.length > 1) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: ChompdColors.amberGlow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ChompdColors.amber.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: ChompdColors.amber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.renewalsOnDay(
                        busiest.value.length,
                        DateHelpers.shortDate(busiest.key),
                        Subscription.formatPrice(busiest.value.fold(0.0, (s, sub) => s + sub.price), _currencyCode),
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: ChompdColors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Most expensive day insight
          if (priciest != null && priciestSpend >= 30) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: priciestSpend >= 50
                    ? ChompdColors.red.withValues(alpha: 0.08)
                    : ChompdColors.amberGlow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: priciestSpend >= 50
                      ? ChompdColors.red.withValues(alpha: 0.2)
                      : ChompdColors.amber.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 14,
                    color: priciestSpend >= 50
                        ? ChompdColors.red
                        : ChompdColors.amber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.biggestDay(
                        DateHelpers.shortDate(priciest.key),
                        Subscription.formatPrice(priciestSpend, _currencyCode),
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        color: priciestSpend >= 50
                            ? ChompdColors.red
                            : ChompdColors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          Text(
            context.l10n.tapDayToSee,
            style: const TextStyle(
              fontSize: 10,
              color: ChompdColors.textDim,
            ),
          ),
        ],
      ),
    );
  }

  /// Parses brand colour from hex string.
  Color _brandColor(Subscription sub) {
    if (sub.brandColor == null) return ChompdColors.textDim;
    final hex = sub.brandColor!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

// ─── Shared Widgets ───

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: ChompdColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ChompdColors.border),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_back_rounded,
          size: 16,
          color: ChompdColors.textMid,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: ChompdColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: ChompdTypography.mono(
                size: 16,
                weight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: ChompdColors.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
