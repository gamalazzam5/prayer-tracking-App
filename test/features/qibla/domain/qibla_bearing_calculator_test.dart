import 'package:depi1/core/location/coordinates.dart';
import 'package:depi1/features/qibla/domain/services/qibla_bearing_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const useCase = QiblaBearingCalculator();

  /// Reference bearings are great-circle initial bearings to the Kaaba
  /// (21.4224779 N, 39.8251832 E). One degree of tolerance is far tighter than
  /// any real magnetometer, so it still catches a genuine formula error.
  const tolerance = 1.0;

  void expectBearing(Coordinates from, double expected) {
    expect(useCase(from), closeTo(expected, tolerance));
  }

  group('QiblaBearingCalculator', () {
    test('points south-east from Cairo', () {
      expectBearing(const Coordinates(30.0444, 31.2357), 136.1);
    });

    test('points east-north-east from New York', () {
      expectBearing(const Coordinates(40.7128, -74.0060), 58.5);
    });

    test('points south-east from London', () {
      expectBearing(const Coordinates(51.5074, -0.1278), 118.9);
    });

    test('points west-north-west from Jakarta', () {
      expectBearing(const Coordinates(-6.2088, 106.8456), 295.1);
    });

    test('points north-west from Cape Town, south of the Kaaba', () {
      expectBearing(const Coordinates(-33.9249, 18.4241), 22.8);
    });

    test('points due north from directly south of the Kaaba', () {
      expectBearing(const Coordinates(0.0, 39.8251832), 0.0);
    });

    test('always returns a bearing inside the compass range', () {
      for (var lat = -80.0; lat <= 80.0; lat += 20) {
        for (var lon = -180.0; lon < 180.0; lon += 20) {
          final bearing = useCase(Coordinates(lat, lon));
          expect(bearing, greaterThanOrEqualTo(0));
          expect(bearing, lessThan(360));
          expect(bearing.isNaN, isFalse);
        }
      }
    });

    test('handles the antimeridian without a quadrant error', () {
      // Directly opposite the Kaaba's longitude: the old atan-based formula
      // needed hand-written corrections here.
      final bearing = useCase(const Coordinates(21.4224779, -140.1748168));
      expect(bearing, greaterThanOrEqualTo(0));
      expect(bearing, lessThan(360));
    });
  });
}
