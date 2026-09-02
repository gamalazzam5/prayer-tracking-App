import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qibla_direction_entity.dart';

abstract class QiblaRepository {
  /// Emits a reading each time the device's compass moves.
  ///
  /// Failures are emitted as values rather than thrown, so the UI can react to
  /// a permission being revoked mid-session without the stream dying.
  Stream<Either<Failure, QiblaDirectionEntity>> watchQiblaDirection();
}
