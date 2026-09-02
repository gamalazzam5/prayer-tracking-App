import 'package:equatable/equatable.dart';

import '../../../prayer/domain/entities/prayer_name.dart';
import '../../../prayer/domain/entities/prayer_status.dart';

/// How often one status was recorded, overall and per prayer.
class StatusBreakdownEntity extends Equatable {
  final PrayerStatus status;

  /// Times this status was recorded across all tracked days.
  final int count;

  /// [count] as a fraction of every recorded prayer, in `[0, 1]`.
  final double shareOfAll;

  /// For each prayer, its fraction of this status's [count], in `[0, 1]`.
  /// Zero for every prayer when [count] is zero.
  final Map<PrayerName, double> perPrayerShare;

  const StatusBreakdownEntity({
    required this.status,
    required this.count,
    required this.shareOfAll,
    required this.perPrayerShare,
  });

  @override
  List<Object?> get props => [status, count, shareOfAll, perPrayerShare];
}
