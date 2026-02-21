import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/subscription.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/exchange_rate_service.dart';
import '../../services/haptic_service.dart';
import '../../utils/date_helpers.dart';
import '../../utils/l10n_extension.dart';
import '../detail/detail_screen.dart';

/// Calendar view showing which days you get charged.
///
/// Heat-map intensity circles show spend density per day.
/// Brand-coloured dots below each date identify which services renew.
/// Tap a day to see the full breakdown in styled detail cards.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  /// Tracks month transitions for fade animation.
  double _heatMapOpacity = 1.0;

  String get _currencyCode => ref.read(currencyProvider);

  /// GBP-based thresholds converted to the user's display currency.
  double get _thresholdAmber =>
      ExchangeRateService.instance.convert(30, 'GBP', _currencyCode);
  double get _thresholdRed =>
      ExchangeRateService.instance.convert(50, 'GBP', _currencyCode);

  /// Compute the total month spend for heat-map normalisation.
  double _monthTotal(Map<DateTime, List<Subscription>> calendar) {
    final monthStart = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final monthEnd = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    return calendar.entries
        .where((e) => !e.key.isBefore(monthStart) && !e.key.isAfter(monthEnd))
        .fold(0.0, (sum, e) =>
            sum + e.value.fold(0.0, (s, sub) => s + sub.priceInOnDate(_currencyCode, e.key)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final calendar = ref.watch(renewalCalendarProvider);
    ref.watch(currencyProvider); // Rebuild when currency changes

    return Scaffold(
      backgroundColor: c.bg,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: c.text,
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
    final c = context.colors;
    final monthSpend = _monthTotal(calendar);

    return Container(
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: TableCalendar<Subscription>(
        locale: Localizations.localeOf(context).toString(),
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
          // Trigger heat-map fade transition
          setState(() {
            _heatMapOpacity = 0.0;
            _focusedDay = focusedDay;
            _selectedDay = null;
          });
          // Fade back in after a frame
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) setState(() => _heatMapOpacity = 1.0);
          });
        },

        // ─── Styling ───
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: c.textMid,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: c.textMid,
          ),
          titleTextStyle: ChompdTypography.mono(
            size: 14,
            weight: FontWeight.w700,
            color: c.text,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: ChompdTypography.mono(
            size: 10,
            color: c.textDim,
          ),
          weekendStyle: ChompdTypography.mono(
            size: 10,
            color: c.textDim,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: const EdgeInsets.all(2),
          // Hide default markers — we use custom markerBuilder
          markersMaxCount: 0,
          // Default text styles (overridden by custom builders)
          defaultTextStyle: TextStyle(fontSize: 13, color: c.text),
          weekendTextStyle: TextStyle(fontSize: 13, color: c.textMid),
          // Today — overridden by todayBuilder
          todayDecoration: const BoxDecoration(),
          todayTextStyle: TextStyle(fontSize: 13, color: c.mint),
          // Selected — overridden by selectedBuilder
          selectedDecoration: const BoxDecoration(),
          selectedTextStyle: TextStyle(fontSize: 13, color: c.bg),
        ),

        // Custom builders for heat-map + brand dots + bold renewal dates
        calendarBuilders: CalendarBuilders(
          // ─── Default day: heat-map intensity circle ───
          defaultBuilder: (context, day, focusedDay) {
            return _buildHeatMapCell(
              day: day,
              calendar: calendar,
              monthSpend: monthSpend,
              isSelected: false,
              isToday: false,
            );
          },
          // ─── Today: heat-map + mint ring ───
          todayBuilder: (context, day, focusedDay) {
            return _buildHeatMapCell(
              day: day,
              calendar: calendar,
              monthSpend: monthSpend,
              isSelected: false,
              isToday: true,
            );
          },
          // ─── Selected day: solid mint circle ───
          selectedBuilder: (context, day, focusedDay) {
            final key = DateTime(day.year, day.month, day.day);
            final daySubs = calendar[key] ?? [];
            return _HeatMapDayCell(
              day: day,
              isSelected: true,
              isToday: isSameDay(day, DateTime.now()),
              renewals: daySubs,
              currencyCode: _currencyCode,
              brandColorFn: _brandColor,
              heatMapOpacity: _heatMapOpacity,
            );
          },
          // ─── Brand-coloured dots below date numbers ───
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

  /// Builds a heat-map cell for default/today builders.
  Widget _buildHeatMapCell({
    required DateTime day,
    required Map<DateTime, List<Subscription>> calendar,
    required double monthSpend,
    required bool isSelected,
    required bool isToday,
  }) {
    final key = DateTime(day.year, day.month, day.day);
    final daySubs = calendar[key] ?? [];

    return _HeatMapDayCell(
      day: day,
      isSelected: isSelected,
      isToday: isToday,
      renewals: daySubs,
      monthSpend: monthSpend,
      currencyCode: _currencyCode,
      thresholdAmber: _thresholdAmber,
      thresholdRed: _thresholdRed,
      brandColorFn: _brandColor,
      heatMapOpacity: _heatMapOpacity,
    );
  }

  /// Builds dots for a day cell — unique colours with glow.
  ///
  /// Up to 3 dots shown individually; 4+ shows 2 dots + "+N" count.
  /// Uses brand colour per sub, falling back to category colour.
  Widget _buildDayDots(List<Subscription> renewals) {
    final c = context.colors;
    if (renewals.isEmpty) return const SizedBox.shrink();

    // Unique colours — brand with category fallback, deduplicated
    final colors = renewals.map((s) {
      final brand = _brandColor(s);
      return brand == c.textDim
          ? CategoryColors.forCategory(s.category)
          : brand;
    }).toSet().toList();

    if (colors.length <= 3) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: colors
            .map((color) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 3,
                          spreadRadius: 0.5,
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
          ...colors.take(2).map((color) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
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
              color: c.textDim,
            ),
          ),
        ],
      );
    }
  }

  /// Detail panel for the selected day with staggered card animations.
  Widget _buildDayDetail(Map<DateTime, List<Subscription>> calendar) {
    final c = context.colors;
    final key = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    final subs = calendar[key] ?? [];
    final dayTotal = subs.fold(0.0, (sum, s) => sum + s.priceInOnDate(_currencyCode, key));
    final isToday = isSameDay(_selectedDay!, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Row(
          children: [
            Text(
              DateHelpers.shortDate(_selectedDay!, locale: Localizations.localeOf(context).languageCode),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.text,
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
                  color: c.mintGlow,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  context.l10n.today,
                  style: ChompdTypography.mono(
                    size: 9,
                    weight: FontWeight.w700,
                    color: c.mint,
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
                  color: c.mint,
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
              color: c.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 28,
                  color: c.mint.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.noRenewalsThisDay,
                  style: TextStyle(
                    fontSize: 12,
                    color: c.textDim,
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(subs.length, (i) => _StaggeredSubCard(
            key: ValueKey('${_selectedDay}_${subs[i].id}'),
            sub: subs[i],
            date: key,
            index: i,
            currencyCode: _currencyCode,
            brandColorFn: _brandColor,
          )),
      ],
    );
  }

  /// Monthly summary: total spend, category breakdown, busiest day.
  Widget _buildMonthlySummary(Map<DateTime, List<Subscription>> calendar) {
    final c = context.colors;
    final locale = Localizations.localeOf(context).languageCode;
    // Filter to focused month
    final monthStart = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final monthEnd = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final monthEntries = calendar.entries.where((e) =>
        !e.key.isBefore(monthStart) && !e.key.isAfter(monthEnd));

    final totalRenewals =
        monthEntries.fold(0, (sum, e) => sum + e.value.length);
    final totalSpend = monthEntries.fold(
      0.0,
      (sum, e) => sum + e.value.fold(0.0, (s, sub) => s + sub.priceInOnDate(_currencyCode, e.key)),
    );

    // Category breakdown
    final categorySpend = <String, double>{};
    for (final entry in monthEntries) {
      for (final sub in entry.value) {
        final p = sub.priceInOnDate(_currencyCode, entry.key);
        categorySpend.update(
          sub.category,
          (v) => v + p,
          ifAbsent: () => p,
        );
      }
    }
    // Sort by spend descending, take top 3
    final topCategories = categorySpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = topCategories.take(3).toList();

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
          entry.value.fold(0.0, (sum, s) => sum + s.priceInOnDate(_currencyCode, entry.key));
      if (daySpend > priciestSpend) {
        priciestSpend = daySpend;
        priciest = entry;
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Row 1: Total spend + renewal count ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Subscription.formatPrice(totalSpend, _currencyCode),
                style: ChompdTypography.mono(
                  size: 24,
                  weight: FontWeight.w700,
                  color: c.mint,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.bgElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 12, color: c.textDim),
                    const SizedBox(width: 4),
                    Text(
                      '$totalRenewals ${context.l10n.renewals.toLowerCase()}',
                      style: ChompdTypography.mono(
                        size: 10,
                        color: c.textMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── Row 2: Category breakdown chips (scrollable) ───
          if (top3.isNotEmpty) ...[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: top3.asMap().entries.map((mapEntry) {
                  final entry = mapEntry.value;
                  final catColor = CategoryColors.forCategory(entry.key);
                  return Padding(
                    padding: EdgeInsets.only(right: mapEntry.key < top3.length - 1 ? 6 : 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: catColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: catColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            AppConstants.localisedCategory(entry.key, context.l10n),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: c.textMid,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            Subscription.formatPrice(entry.value, _currencyCode),
                            style: ChompdTypography.mono(
                              size: 10,
                              weight: FontWeight.w600,
                              color: catColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // ─── Row 3: Busiest day pill ───
          if (busiest case final b? when b.value.length > 1 &&
              !(_selectedDay != null && isSameDay(b.key, _selectedDay!))) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: c.amberGlow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: c.amber.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: c.amber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.renewalsOnDay(
                        b.value.length,
                        DateHelpers.shortDate(b.key, locale: locale),
                        Subscription.formatPrice(b.value.fold(0.0, (s, sub) => s + sub.priceInOnDate(_currencyCode, b.key)), _currencyCode),
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        color: c.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ─── Row 4: Biggest day pill — ALWAYS show when ≥1 renewal ───
          // No threshold conditions — just show the day with highest spend.
          if (priciest != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B5A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFF6B5A).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.l10n.biggestDay(
                        DateHelpers.shortDate(priciest.key, locale: locale),
                        Subscription.formatPrice(priciestSpend, _currencyCode),
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFFF6B5A),
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
            style: TextStyle(
              fontSize: 10,
              color: c.textDim,
            ),
          ),
        ],
      ),
    );
  }

  /// Parses brand colour from hex string.
  Color _brandColor(Subscription sub) {
    final c = context.colors;
    if (sub.brandColor == null) return c.textDim;
    final hex = sub.brandColor!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

// ═══════════════════════════════════════════════════════════════════
// Heat-Map Day Cell
// ═══════════════════════════════════════════════════════════════════

/// A single day cell in the calendar with heat-map intensity background
/// and spring animation on selection.
///
/// The mint-green circle opacity scales with the day's spend relative
/// to the month total, creating a "constellation" effect in dark mode.
/// When selected, the cell springs to 1.15x scale then settles back.
class _HeatMapDayCell extends StatefulWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final List<Subscription> renewals;
  final double monthSpend;
  final String currencyCode;
  final double thresholdAmber;
  final double thresholdRed;
  final Color Function(Subscription) brandColorFn;
  final double heatMapOpacity;

  const _HeatMapDayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.renewals,
    this.monthSpend = 0,
    required this.currencyCode,
    this.thresholdAmber = 30,
    this.thresholdRed = 50,
    required this.brandColorFn,
    required this.heatMapOpacity,
  });

  @override
  State<_HeatMapDayCell> createState() => _HeatMapDayCellState();
}

class _HeatMapDayCellState extends State<_HeatMapDayCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springController;
  late final Animation<double> _scaleAnimation;
  bool _wasSelected = false;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_springController);
    _wasSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(_HeatMapDayCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger spring animation when becoming selected
    if (widget.isSelected && !_wasSelected && widget.renewals.isNotEmpty) {
      _springController.forward(from: 0);
      HapticFeedback.selectionClick();
    }
    _wasSelected = widget.isSelected;
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasRenewal = widget.renewals.isNotEmpty;
    final daySpend =
        widget.renewals.fold(0.0, (sum, s) => sum + s.priceInOnDate(widget.currencyCode, widget.day));

    // ─── Heat-map intensity (spend relative to month total) ───
    double heatAlpha = 0;
    if (hasRenewal && widget.monthSpend > 0) {
      final ratio = daySpend / widget.monthSpend;
      if (ratio >= 0.75) {
        heatAlpha = 0.70;
      } else if (ratio >= 0.50) {
        heatAlpha = 0.45;
      } else if (ratio >= 0.25) {
        heatAlpha = 0.25;
      } else {
        heatAlpha = 0.10;
      }
    }

    // High-cost glow override (red/amber for expensive days)
    Color? glowColor;
    if (daySpend >= widget.thresholdRed) {
      glowColor = c.red;
    } else if (daySpend >= widget.thresholdAmber) {
      glowColor = c.amber;
    }

    // Highest-spend day gets an outer glow
    final isHighest = hasRenewal && widget.monthSpend > 0 &&
        (daySpend / widget.monthSpend) >= 0.75;

    // ─── Selected state: solid mint with spring animation ───
    if (widget.isSelected) {
      return Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.mint,
              boxShadow: [
                BoxShadow(
                  color: c.mint.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '${widget.day.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: c.bg,
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.heatMapOpacity,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasRenewal
                ? (glowColor ?? c.mint).withValues(alpha: heatAlpha)
                : null,
            border: widget.isToday
                ? Border.all(color: c.mint.withValues(alpha: 0.5), width: 1.5)
                : null,
            boxShadow: isHighest
                ? [
                    BoxShadow(
                      color: (glowColor ?? c.mint).withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${widget.day.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: hasRenewal ? FontWeight.w600 : FontWeight.w400,
              color: widget.isToday
                  ? c.mint
                  : glowColor ?? (hasRenewal ? c.text : c.textDim),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Staggered Day Detail Card
// ═══════════════════════════════════════════════════════════════════

/// A subscription renewal card with staggered fade-in animation.
///
/// Each card delays its entrance by [index] × 30ms for a cascading effect.
/// Uses a category-color accent bar on the left and elevated background.
class _StaggeredSubCard extends StatefulWidget {
  final Subscription sub;
  final DateTime date;
  final int index;
  final String currencyCode;
  final Color Function(Subscription) brandColorFn;

  const _StaggeredSubCard({
    super.key,
    required this.sub,
    required this.date,
    required this.index,
    required this.currencyCode,
    required this.brandColorFn,
  });

  @override
  State<_StaggeredSubCard> createState() => _StaggeredSubCardState();
}

class _StaggeredSubCardState extends State<_StaggeredSubCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Staggered delay: 30ms per card index
    Future.delayed(Duration(milliseconds: widget.index * 30), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sub = widget.sub;
    final brandColor = widget.brandColorFn(sub);
    final catColor = CategoryColors.forCategory(sub.category);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: () {
            HapticService.instance.light();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DetailScreen(subscription: sub),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: c.bgElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Stack(
              children: [
                // Category accent bar (left edge)
                Positioned(
                  left: 0,
                  top: 8,
                  bottom: 8,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: catColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Card content
                Padding(
                  padding: const EdgeInsets.only(
                    left: 14,
                    right: 14,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      // Service icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          sub.iconName ??
                              (sub.name.isNotEmpty ? sub.name[0] : '?'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: brandColor,
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
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: c.text,
                              ),
                            ),
                            Text(
                              sub.cycle.localLabel(context.l10n),
                              style: TextStyle(
                                fontSize: 10,
                                color: c.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price (bold) — date-aware for intro/trial subs
                      Text(
                        '${Subscription.formatPrice(sub.effectivePriceOn(widget.date), sub.currency)}/${sub.cycle.shortLabel}',
                        style: ChompdTypography.mono(
                          size: 13,
                          weight: FontWeight.w700,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: c.textDim,
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
}

// ═══════════════════════════════════════════════════════════════════
// Shared Widgets
// ═══════════════════════════════════════════════════════════════════

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: c.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_back_rounded,
          size: 16,
          color: c.textMid,
        ),
      ),
    );
  }
}
