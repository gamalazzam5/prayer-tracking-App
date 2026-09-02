import 'package:equatable/equatable.dart';

import 'status_breakdown_entity.dart';
import 'weekly_achievement_entity.dart';

/// Everything the statistics screen renders.
class PrayerStatisticsEntity extends Equatable {
  final WeeklyAchievementEntity weekly;

  /// One entry per status, in [PrayerStatus] declaration order.
  final List<StatusBreakdownEntity> breakdowns;

  /// Total prayers the user has recorded a status for.
  final int totalRecorded;

  const PrayerStatisticsEntity({
    required this.weekly,
    required this.breakdowns,
    required this.totalRecorded,
  });

  @override
  List<Object?> get props => [weekly, breakdowns, totalRecorded];
}
