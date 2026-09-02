import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_entity.dart';
import '../entities/prayer_status.dart';
import '../repos/prayer_repository.dart';

class UpdatePrayerStatusUseCase {
  final PrayerRepository _repository;

  const UpdatePrayerStatusUseCase(this._repository);

  Future<Either<Failure, PrayerEntity>> call({
    required DateTime date,
    required PrayerEntity prayer,
    required PrayerStatus? status,
  }) =>
      _repository.updateStatus(date: date, prayer: prayer, status: status);
}
