import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/prayer_local_storage.dart';
import '../../../../core/storage/prayer_record.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../prayer/domain/entities/prayer_name.dart';
import '../../../prayer/domain/entities/prayer_status.dart';
import '../../domain/entities/prayer_statistics_entity.dart';
import '../../domain/entities/status_breakdown_entity.dart';
import '../../domain/entities/weekly_achievement_entity.dart';
import '../../domain/repos/statistics_repository.dart';

/// Aggregates the stored prayer records into statistics.
///
/// The previous version issued ~25 separate `COUNT(*)` queries per refresh and
/// recomputed on every database read, including the ~300 writes performed at
/// start-up. Here the whole store is read once and tallied in a single pass,
/// and only user-recorded status changes trigger a refresh.
class StatisticsRepositoryImpl implements StatisticsRepository {
  final PrayerLocalStorage _storage;
  final DateTime Function() _now;

  /// Days in the achievement window.
  static const int weeklyWindowDays = 7;

  StatisticsRepositoryImpl({
    required PrayerLocalStorage storage,
    DateTime Function()? now,
  })  : _storage = storage,
        _now = now ?? DateTime.now;

  @override
  Stream<void> watchChanges() => _storage.onStatusChanged;

  @override
  Future<Either<Failure, PrayerStatisticsEntity>> getStatistics() async {
    try {
      final tally = _tally(_storage.getAll());
      return Right(PrayerStatisticsEntity(
        weekly: _weeklyAchievement(),
        breakdowns: _breakdowns(tally),
        // Taken from the same tally the breakdowns use, so the total and the
        // per-status shares can never disagree.
        totalRecorded: tally.totalRecorded,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  WeeklyAchievementEntity _weeklyAchievement() {
    final today = DateFormatter.startOfDay(_now());
    final start = today.subtract(const Duration(days: weeklyWindowDays - 1));

    final records = _storage.getInRange(
      DateFormatter.toKey(start),
      DateFormatter.toKey(today),
    );

    var performed = 0;
    for (final record in records) {
      final status = PrayerStatus.fromId(record.statusId);
      if (status != null && status.isPerformed) performed++;
    }

    return WeeklyAchievementEntity(
      performed: performed,
      target: weeklyWindowDays * PrayerName.values.length,
    );
  }

  /// Single pass over every record, bucketing recorded prayers by
  /// (status, prayer) and ignoring rows whose ids we cannot resolve.
  _Tally _tally(List<PrayerRecord> all) {
    final counts = <PrayerStatus, Map<PrayerName, int>>{
      for (final status in PrayerStatus.values)
        status: {for (final name in PrayerName.values) name: 0},
    };
    var totalRecorded = 0;

    for (final record in all) {
      final status = PrayerStatus.fromId(record.statusId);
      final name = PrayerName.fromId(record.prayerId);
      if (status == null || name == null) continue;
      counts[status]![name] = counts[status]![name]! + 1;
      totalRecorded++;
    }

    return _Tally(counts: counts, totalRecorded: totalRecorded);
  }

  List<StatusBreakdownEntity> _breakdowns(_Tally tally) {
    return [
      for (final status in PrayerStatus.values)
        _breakdownFor(status, tally.counts[status]!, tally.totalRecorded),
    ];
  }

  StatusBreakdownEntity _breakdownFor(
    PrayerStatus status,
    Map<PrayerName, int> perPrayer,
    int totalRecorded,
  ) {
    final count = perPrayer.values.fold<int>(0, (sum, value) => sum + value);

    return StatusBreakdownEntity(
      status: status,
      count: count,
      shareOfAll: totalRecorded == 0 ? 0 : count / totalRecorded,
      perPrayerShare: {
        for (final entry in perPrayer.entries)
          entry.key: count == 0 ? 0.0 : entry.value / count,
      },
    );
  }
}

/// Result of one pass over the stored records.
class _Tally {
  final Map<PrayerStatus, Map<PrayerName, int>> counts;

  /// Rows carrying a status we could resolve — the denominator for every share.
  final int totalRecorded;

  const _Tally({required this.counts, required this.totalRecorded});
}
