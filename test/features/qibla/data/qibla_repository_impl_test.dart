import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:depi1/core/error/exceptions.dart';
import 'package:depi1/core/error/failures.dart';
import 'package:depi1/core/location/coordinates.dart';
import 'package:depi1/core/location/location_service.dart';
import 'package:depi1/features/qibla/data/datasources/compass_data_source.dart';
import 'package:depi1/features/qibla/data/repos/qibla_repository_impl.dart';
import 'package:depi1/features/qibla/domain/entities/qibla_direction_entity.dart';
import 'package:depi1/features/qibla/domain/services/qibla_bearing_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocationService extends Mock implements LocationService {}

/// Compass stub driven by the test, standing in for the magnetometer.
class _FakeCompass implements CompassDataSource {
  final StreamController<double?> controller =
      StreamController<double?>.broadcast();

  @override
  Stream<double?> get headings => controller.stream;
}

void main() {
  late _MockLocationService locationService;
  late _FakeCompass compass;
  late QiblaRepositoryImpl repository;

  const cairo = Coordinates(30.0444, 31.2357);

  setUp(() {
    locationService = _MockLocationService();
    compass = _FakeCompass();
    repository = QiblaRepositoryImpl(
      compass: compass,
      locationService: locationService,
      calculateBearing: const QiblaBearingCalculator(),
    );

    when(() => locationService.getCoordinates(
        forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async => cairo);
  });

  tearDown(() => compass.controller.close());

  group('watchQiblaDirection', () {
    test('emits a reading from a compass event alone, with no device movement',
        () async {
      // Regression: the previous implementation combined the compass with
      // `Geolocator.getPositionStream()`, which only fires when the device
      // physically moves. A stationary phone or an emulator therefore produced
      // no readings and the screen sat on a spinner indefinitely. Here a single
      // compass event is enough.
      final emissions = <Either<Failure, QiblaDirectionEntity>>[];
      final subscription =
          repository.watchQiblaDirection().listen(emissions.add);

      // Let the one-shot location fix resolve before the compass reports.
      await Future<void>.delayed(Duration.zero);
      compass.controller.add(90.0);
      await Future<void>.delayed(Duration.zero);

      expect(emissions, hasLength(1));
      final reading = emissions.single.getOrElse(() => throw 'left');
      expect(reading.deviceHeading, 90.0);
      expect(reading.qiblaBearing, closeTo(136.1, 1.0));

      await subscription.cancel();
    });

    test('keeps emitting as the heading changes', () async {
      final headings = <double>[];
      final subscription = repository.watchQiblaDirection().listen((result) {
        result.fold((_) {}, (d) => headings.add(d.deviceHeading));
      });

      await Future<void>.delayed(Duration.zero);
      for (final heading in [0.0, 45.0, 180.0, 359.0]) {
        compass.controller.add(heading);
        await Future<void>.delayed(Duration.zero);
      }

      expect(headings, [0.0, 45.0, 180.0, 359.0]);
      await subscription.cancel();
    });

    test('reports a compass failure when the heading is unresolvable',
        () async {
      final results = <Either<Failure, QiblaDirectionEntity>>[];
      final subscription = repository.watchQiblaDirection().listen(results.add);

      await Future<void>.delayed(Duration.zero);
      compass.controller.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(results.single.isLeft(), isTrue);
      results.single.fold(
        (f) => expect(f, isA<CompassUnavailableFailure>()),
        (_) => fail('expected a failure'),
      );

      await subscription.cancel();
    });

    test('recovers once a valid heading follows an unresolvable one', () async {
      final results = <Either<Failure, QiblaDirectionEntity>>[];
      final subscription = repository.watchQiblaDirection().listen(results.add);

      await Future<void>.delayed(Duration.zero);
      compass.controller.add(null);
      await Future<void>.delayed(Duration.zero);
      compass.controller.add(120.0);
      await Future<void>.delayed(Duration.zero);

      expect(results, hasLength(2));
      expect(results.first.isLeft(), isTrue);
      expect(results.last.isRight(), isTrue);

      await subscription.cancel();
    });

    test('emits a location failure and closes when the service is disabled',
        () async {
      when(() => locationService.getCoordinates(
              forceRefresh: any(named: 'forceRefresh')))
          .thenThrow(const LocationDisabledException());

      final results = await repository.watchQiblaDirection().toList();

      expect(results, hasLength(1));
      expect(results.single, const Left<Failure, QiblaDirectionEntity>(
        LocationFailure.serviceDisabled,
      ));
    });

    test('distinguishes a permanent permission denial', () async {
      when(() => locationService.getCoordinates(
              forceRefresh: any(named: 'forceRefresh')))
          .thenThrow(const LocationDeniedException(isPermanent: true));

      final results = await repository.watchQiblaDirection().toList();

      expect(results.single, const Left<Failure, QiblaDirectionEntity>(
        LocationFailure.permissionDeniedForever,
      ));
    });

    test('never queries the location more than once per subscription',
        () async {
      final subscription = repository.watchQiblaDirection().listen((_) {});

      await Future<void>.delayed(Duration.zero);
      for (var i = 0; i < 5; i++) {
        compass.controller.add(i.toDouble());
        await Future<void>.delayed(Duration.zero);
      }

      verify(() => locationService.getCoordinates(
          forceRefresh: any(named: 'forceRefresh'))).called(1);
      await subscription.cancel();
    });

    test('turns a compass stream error into a failure value', () async {
      final results = <Either<Failure, QiblaDirectionEntity>>[];
      final subscription = repository.watchQiblaDirection().listen(results.add);

      await Future<void>.delayed(Duration.zero);
      compass.controller.addError(Exception('sensor died'));
      await Future<void>.delayed(Duration.zero);

      expect(results.single.isLeft(), isTrue);
      await subscription.cancel();
    });
  });
}
