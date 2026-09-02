import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qibla_direction_entity.dart';
import '../repos/qibla_repository.dart';

class WatchQiblaDirectionUseCase {
  final QiblaRepository _repository;

  const WatchQiblaDirectionUseCase(this._repository);

  Stream<Either<Failure, QiblaDirectionEntity>> call() =>
      _repository.watchQiblaDirection();
}
