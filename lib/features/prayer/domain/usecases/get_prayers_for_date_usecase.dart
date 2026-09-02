import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_entity.dart';
import '../repos/prayer_repository.dart';

class GetPrayersForDateUseCase {
  final PrayerRepository _repository;

  const GetPrayersForDateUseCase(this._repository);

  Future<Either<Failure, List<PrayerEntity>>> call(DateTime date) =>
      _repository.getPrayersForDate(date);
}
