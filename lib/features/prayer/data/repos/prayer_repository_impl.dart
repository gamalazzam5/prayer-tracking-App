import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/storage/prayer_local_storage.dart';
import '../../../../core/storage/prayer_record.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/prayer_entity.dart';
import '../../domain/entities/prayer_status.dart';
import '../../domain/repos/prayer_repository.dart';
import '../datasources/prayer_time_calculator.dart';
import '../models/prayer_model.dart';

/// Catches every data-layer exception at this boundary and maps it to a typed
/// [Failure]; nothing above this class ever sees a raw exception.
class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerLocalStorage _storage;
  final PrayerTimeCalculator _calculator;
  final LocationService _locationService;

  PrayerRepositoryImpl({
    required PrayerLocalStorage storage,
    required PrayerTimeCalculator calculator,
    required LocationService locationService,
  })  : _storage = storage,
        _calculator = calculator,
        _locationService = locationService;

  @override
  Future<Either<Failure, Unit>> seedPrayerTimes() async {
    try {
      final coordinates = await _locationService.getCoordinates();
      final today = DateTime.now();

      final pending = <PrayerRecord>[];
      for (var offset = -AppConstants.seedDaysBefore;
          offset <= AppConstants.seedDaysAfter;
          offset++) {
        final date = DateFormatter.startOfDay(today).add(Duration(days: offset));
        // Skip days already present: recomputing them is wasted work, and the
        // composite storage key means a re-save would be a no-op anyway.
        if (_storage.getByDate(DateFormatter.toKey(date)).isNotEmpty) continue;

        final prayers = _calculator.calculate(
          date: date,
          coordinates: coordinates,
        );
        pending.addAll([for (final prayer in prayers) prayer.toRecord(date)]);
      }

      // One batched write, instead of the ~300 individual inserts the previous
      // implementation issued on every cold start.
      await _storage.saveAll(pending);
      return const Right(unit);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<PrayerEntity>>> getPrayersForDate(
    DateTime date,
  ) async {
    try {
      final dateKey = DateFormatter.toKey(date);
      var records = _storage.getByDate(dateKey);

      if (records.isEmpty) {
        final coordinates = await _locationService.getCoordinates();
        final computed = _calculator.calculate(
          date: date,
          coordinates: coordinates,
        );
        await _storage.saveAll([for (final p in computed) p.toRecord(date)]);
        records = _storage.getByDate(dateKey);
      }

      final prayers = <PrayerEntity>[];
      for (final record in records) {
        final model = PrayerModel.fromRecord(record);
        if (model != null) prayers.add(model);
      }
      prayers.sort((a, b) => a.time.compareTo(b.time));

      if (prayers.isEmpty) {
        return const Left(PrayerCalculationFailure());
      }
      return Right(prayers);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, PrayerEntity>> updateStatus({
    required DateTime date,
    required PrayerEntity prayer,
    required PrayerStatus? status,
  }) async {
    try {
      final updated = await _storage.updateStatus(
        dateKey: DateFormatter.toKey(date),
        prayerId: prayer.name.id,
        statusId: status?.id,
      );

      if (updated == null) {
        return const Left(CacheFailure('لم يتم العثور على هذه الصلاة'));
      }

      final model = PrayerModel.fromRecord(updated);
      if (model == null) return const Left(CacheFailure());
      return Right(model);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  Failure _mapException(Object error) => switch (error) {
        LocationDisabledException() => LocationFailure.serviceDisabled,
        LocationDeniedException(:final isPermanent) => isPermanent
            ? LocationFailure.permissionDeniedForever
            : LocationFailure.permissionDenied,
        CacheException(:final message) => CacheFailure(message),
        PrayerCalculationException() => const PrayerCalculationFailure(),
        _ => const UnexpectedFailure(),
      };
}
