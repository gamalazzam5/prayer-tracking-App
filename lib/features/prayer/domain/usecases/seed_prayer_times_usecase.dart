import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repos/prayer_repository.dart';

class SeedPrayerTimesUseCase {
  final PrayerRepository _repository;

  const SeedPrayerTimesUseCase(this._repository);

  Future<Either<Failure, Unit>> call() => _repository.seedPrayerTimes();
}
