import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_entity.dart';
import '../entities/prayer_status.dart';

abstract class PrayerRepository {
  /// Warms the local store with prayer times around today so the app works
  /// offline. Safe to call repeatedly — already-seeded days are skipped.
  Future<Either<Failure, Unit>> seedPrayerTimes();

  /// The five prayers for [date], computing and persisting them on demand when
  /// the day has not been seeded yet.
  Future<Either<Failure, List<PrayerEntity>>> getPrayersForDate(DateTime date);

  /// Records how the user performed one prayer. Passing null clears it.
  Future<Either<Failure, PrayerEntity>> updateStatus({
    required DateTime date,
    required PrayerEntity prayer,
    required PrayerStatus? status,
  });
}
