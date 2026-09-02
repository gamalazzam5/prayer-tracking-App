import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_statistics_entity.dart';

abstract class StatisticsRepository {
  /// Aggregates every recorded prayer into the screen's statistics.
  Future<Either<Failure, PrayerStatisticsEntity>> getStatistics();

  /// Emits whenever a prayer status is recorded, so the screen can refresh.
  Stream<void> watchChanges();
}
