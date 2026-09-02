import 'coordinates.dart';

/// Resolves the device's position. Shared by the prayer-times and qibla
/// features, hence `core/`.
abstract class LocationService {
  /// Returns the device position, falling back to the last value cached in
  /// preferences when a live fix is not available.
  ///
  /// Throws [LocationDisabledException] or
  /// [LocationDeniedException] when no coordinates can be produced
  /// at all.
  Future<Coordinates> getCoordinates({bool forceRefresh = false});

  /// The last coordinates persisted on this device, or null if none.
  Coordinates? get cachedCoordinates;
}
