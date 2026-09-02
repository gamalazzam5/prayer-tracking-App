import 'dart:math' as math;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/location/coordinates.dart';

/// Computes the compass bearing from a location to the Kaaba.
///
/// A stateless domain service rather than a use case: it is pure geometry with
/// no repository behind it, and the qibla repository needs it directly.
///
/// Uses the standard great-circle initial-bearing formula. The previous
/// implementation (inherited from `flutter_qiblah`) used a single-argument
/// `atan` plus hand-written quadrant corrections, which is fragile near the
/// poles and across the antimeridian; `atan2` resolves the quadrant directly.
///
/// Pure Dart and side-effect free, so it is verifiable against known bearings
/// without a device.
class QiblaBearingCalculator {
  const QiblaBearingCalculator();

  /// Returns degrees clockwise from true north, in `[0, 360)`.
  double call(Coordinates from) {
    final phi1 = _toRadians(from.latitude);
    final phi2 = _toRadians(AppConstants.kaabaLatitude);
    final deltaLambda =
        _toRadians(AppConstants.kaabaLongitude - from.longitude);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final bearing = _toDegrees(math.atan2(y, x));
    // atan2 returns (-180, 180]; shift into the compass range.
    final normalised = bearing % 360;
    return normalised < 0 ? normalised + 360 : normalised;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  static double _toDegrees(double radians) => radians * 180 / math.pi;
}
