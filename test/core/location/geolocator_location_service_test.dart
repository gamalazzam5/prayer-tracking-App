import 'package:depi1/core/error/exceptions.dart';
import 'package:depi1/core/location/coordinates.dart';
import 'package:depi1/core/location/geolocator_location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockGeolocator extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

Position _positionAt(double latitude, double longitude) => Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime(2026, 9, 1),
      accuracy: 10,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  late _MockGeolocator geolocator;
  late SharedPreferences prefs;
  late GeolocatorLocationService service;

  const cairo = Coordinates(30.0444, 31.2357);

  Future<void> buildService({Map<String, Object> seed = const {}}) async {
    SharedPreferences.setMockInitialValues(seed);
    prefs = await SharedPreferences.getInstance();
    service = GeolocatorLocationService(prefs: prefs, geolocator: geolocator);
  }

  setUpAll(() => registerFallbackValue(const LocationSettings()));

  setUp(() {
    geolocator = _MockGeolocator();
    when(() => geolocator.isLocationServiceEnabled())
        .thenAnswer((_) async => true);
    when(() => geolocator.checkPermission())
        .thenAnswer((_) async => LocationPermission.whileInUse);
    when(() => geolocator.getLastKnownPosition())
        .thenAnswer((_) async => _positionAt(cairo.latitude, cairo.longitude));
  });

  group('cachedCoordinates', () {
    test('is null before anything is stored', () async {
      await buildService();
      expect(service.cachedCoordinates, isNull);
    });

    test('reads a previously stored fix', () async {
      await buildService(
        seed: {'latitude': cairo.latitude, 'longitude': cairo.longitude},
      );
      expect(service.cachedCoordinates, cairo);
    });

    test('is null when only one coordinate was stored', () async {
      await buildService(seed: {'latitude': cairo.latitude});
      expect(service.cachedCoordinates, isNull);
    });
  });

  group('getCoordinates', () {
    test('resolves and caches a live fix on first use', () async {
      await buildService();

      final result = await service.getCoordinates();

      expect(result, cairo);
      expect(prefs.getDouble('latitude'), cairo.latitude);
      expect(prefs.getDouble('longitude'), cairo.longitude);
    });

    test('uses the cache without touching the platform', () async {
      await buildService(
        seed: {'latitude': cairo.latitude, 'longitude': cairo.longitude},
      );

      expect(await service.getCoordinates(), cairo);
      verifyNever(() => geolocator.isLocationServiceEnabled());
    });

    test('forceRefresh bypasses the cache', () async {
      await buildService(seed: {'latitude': 1.0, 'longitude': 2.0});

      final result = await service.getCoordinates(forceRefresh: true);

      expect(result, cairo);
      verify(() => geolocator.isLocationServiceEnabled()).called(1);
    });

    test('prefers the OS last-known fix over a fresh, slower one', () async {
      await buildService();

      await service.getCoordinates();

      verify(() => geolocator.getLastKnownPosition()).called(1);
      verifyNever(() => geolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings')));
    });

    test('falls back to a fresh fix when the OS has none cached', () async {
      await buildService();
      when(() => geolocator.getLastKnownPosition()).thenAnswer((_) async => null);
      when(() => geolocator.getCurrentPosition(
              locationSettings: any(named: 'locationSettings')))
          .thenAnswer((_) async => _positionAt(51.5074, -0.1278));

      final result = await service.getCoordinates();

      expect(result, const Coordinates(51.5074, -0.1278));
    });

    test('requests permission when it has not been granted yet', () async {
      await buildService();
      when(() => geolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(() => geolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);

      expect(await service.getCoordinates(), cairo);
      verify(() => geolocator.requestPermission()).called(1);
    });

    test('falls back to the cached fix when location services are off',
        () async {
      // Prayer times must keep working offline, so a stale fix beats an error.
      await buildService(
        seed: {'latitude': cairo.latitude, 'longitude': cairo.longitude},
      );
      when(() => geolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      expect(await service.getCoordinates(forceRefresh: true), cairo);
    });

    test('falls back to the cached fix when permission is revoked', () async {
      await buildService(
        seed: {'latitude': cairo.latitude, 'longitude': cairo.longitude},
      );
      when(() => geolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      expect(await service.getCoordinates(forceRefresh: true), cairo);
    });

    test('throws when services are off and nothing is cached', () async {
      await buildService();
      when(() => geolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      expect(
        service.getCoordinates,
        throwsA(isA<LocationDisabledException>()),
      );
    });

    test('throws a permanent denial when nothing is cached', () async {
      await buildService();
      when(() => geolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      await expectLater(
        service.getCoordinates(),
        throwsA(
          isA<LocationDeniedException>()
              .having((e) => e.isPermanent, 'isPermanent', isTrue),
        ),
      );
    });

    test('throws a non-permanent denial when the user declines once', () async {
      await buildService();
      when(() => geolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(() => geolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      await expectLater(
        service.getCoordinates(),
        throwsA(
          isA<LocationDeniedException>()
              .having((e) => e.isPermanent, 'isPermanent', isFalse),
        ),
      );
    });
  });
}
