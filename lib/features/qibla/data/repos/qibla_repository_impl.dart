import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/location/location_service.dart';
import '../../domain/entities/qibla_direction_entity.dart';
import '../../domain/repos/qibla_repository.dart';
import '../../domain/services/qibla_bearing_calculator.dart';
import '../datasources/compass_data_source.dart';

/// Combines a one-shot location fix with the live compass feed.
///
/// The previous implementation relied on `flutter_qiblah`, which combined the
/// compass with `Geolocator.getPositionStream()`. That stream only emits when
/// the device physically *moves*, so a stationary phone — or an emulator —
/// produced no readings at all and the screen sat on a spinner forever. Here
/// the position is resolved once up front and the compass drives the stream, so
/// a reading arrives as soon as the sensor reports one.
class QiblaRepositoryImpl implements QiblaRepository {
  final CompassDataSource _compass;
  final LocationService _locationService;
  final QiblaBearingCalculator _calculateBearing;

  QiblaRepositoryImpl({
    required CompassDataSource compass,
    required LocationService locationService,
    required QiblaBearingCalculator calculateBearing,
  })  : _compass = compass,
        _locationService = locationService,
        _calculateBearing = calculateBearing;

  @override
  Stream<Either<Failure, QiblaDirectionEntity>> watchQiblaDirection() async* {
    final double qiblaBearing;
    try {
      final coordinates = await _locationService.getCoordinates();
      qiblaBearing = _calculateBearing(coordinates);
    } on LocationDisabledException {
      yield const Left(LocationFailure.serviceDisabled);
      return;
    } on LocationDeniedException catch (e) {
      yield Left(e.isPermanent
          ? LocationFailure.permissionDeniedForever
          : LocationFailure.permissionDenied);
      return;
    } catch (_) {
      yield const Left(LocationFailure());
      return;
    }

    yield* _compass.headings
        .map<Either<Failure, QiblaDirectionEntity>>((heading) {
          if (heading == null) return const Left(CompassUnavailableFailure());
          return Right(QiblaDirectionEntity(
            qiblaBearing: qiblaBearing,
            deviceHeading: heading,
          ));
        })
        .transform(_errorToFailure());
  }

  /// Turns a stream error into a terminal failure value instead of letting it
  /// tear the subscription down.
  StreamTransformer<Either<Failure, QiblaDirectionEntity>,
      Either<Failure, QiblaDirectionEntity>> _errorToFailure() {
    return StreamTransformer.fromHandlers(
      handleError: (error, stackTrace, sink) =>
          sink.add(const Left(CompassUnavailableFailure())),
    );
  }
}
