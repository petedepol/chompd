import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dodged_trap.dart';
import '../services/dodged_trap_repository.dart';

class TrapStatsData {
  final double totalSaved;
  final int trapsSkipped;
  final int trialsCancelled;
  final int refundsRecovered;

  const TrapStatsData({
    required this.totalSaved,
    required this.trapsSkipped,
    required this.trialsCancelled,
    required this.refundsRecovered,
  });

  int get totalActions => trapsSkipped + trialsCancelled + refundsRecovered;
  bool get hasStats => totalActions > 0;
}

class TrapStatsNotifier extends StateNotifier<TrapStatsData> {
  TrapStatsNotifier()
      : super(const TrapStatsData(
          totalSaved: 0,
          trapsSkipped: 0,
          trialsCancelled: 0,
          refundsRecovered: 0,
        ));

  void refresh() {
    final traps = DodgedTrapRepository.instance.getAll();
    double totalSaved = 0;
    int skipped = 0, cancelled = 0, refunded = 0;

    for (final trap in traps) {
      totalSaved += trap.savedAmount;
      switch (trap.source) {
        case DodgedTrapSource.skipped:
          skipped++;
          break;
        case DodgedTrapSource.trialCancelled:
          cancelled++;
          break;
        case DodgedTrapSource.refundRecovered:
          refunded++;
          break;
      }
    }

    state = TrapStatsData(
      totalSaved: totalSaved,
      trapsSkipped: skipped,
      trialsCancelled: cancelled,
      refundsRecovered: refunded,
    );
  }
}

final trapStatsProvider =
    StateNotifierProvider<TrapStatsNotifier, TrapStatsData>((ref) {
  return TrapStatsNotifier();
});
