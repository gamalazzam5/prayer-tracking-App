import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_statistics_entity.dart';
import '../repos/statistics_repository.dart';

class GetStatisticsUseCase {
  final StatisticsRepository _repository;

  const GetStatisticsUseCase(this._repository);

  Future<Either<Failure, PrayerStatisticsEntity>> call() =>
      _repository.getStatistics();
}
