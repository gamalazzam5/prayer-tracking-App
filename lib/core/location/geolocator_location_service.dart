import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'coordinates.dart';
import 'location_service.dart';

/// [LocationService] on top of `geolocator`, with the last known fix cached in
/// preferences.
///
/// Caching matters for two reasons: prayer times must still work when the user
/// is offline or has revoked permission, and start-up must not block on a GPS
/// fix that can take tens of seconds.
class GeolocatorLocationService implements LocationService {
  final SharedPreferences _prefs;
  final GeolocatorPlatform _geolocator;

  /// Bounded so a slow or absent GPS fix cannot hang the caller forever.
  static const Duration _fixTimeout = Duration(seconds: 10);

  GeolocatorLocationService({
    required SharedPreferences prefs,
    GeolocatorPlatform? geolocator,
  })  : _prefs = prefs,
        _geolocator = geolocator ?? GeolocatorPlatform.instance;

  @override
  Coordinates? get cachedCoordinates {
    final latitude = _prefs.getDouble(AppConstants.prefLatitude);
    final longitude = _prefs.getDouble(AppConstants.prefLongitude);
    if (latitude == null || longitude == null) return null;
    return Coordinates(latitude, longitude);
  }

  @override
  Future<Coordinates> getCoordinates({bool forceRefresh = false}) async {
    final cached = cachedCoordinates;
    if (cached != null && !forceRefresh) return cached;

    try {
      final coordinates = await _resolveLive();
      await _cache(coordinates);
      return coordinates;
    } on LocationDisabledException {
      // A stale fix beats no prayer times at all.
      if (cached != null) return cached;
      rethrow;
    } on LocationDeniedException {
      if (cached != null) return cached;
      rethrow;
    } catch (_) {
      if (cached != null) return cached;
      throw const LocationDisabledException();
    }
  }

  Future<Coordinates> _resolveLive() async {
    if (!await _geolocator.isLocationServiceEnabled()) {
      throw const LocationDisabledException();
    }

    var permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationDeniedException(isPermanent: true);
    }
    if (permission == LocationPermission.denied) {
      throw const LocationDeniedException();
    }

    // A last-known fix is instant when available; only fall back to a fresh
    // (slow, power-hungry) fix when the OS has nothing cached.
    final lastKnown = await _geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      return Coordinates(lastKnown.latitude, lastKnown.longitude);
    }

    // `timeLimit` is the only deadline: wrapping this in a second `.timeout()`
    // of the same length just produced two competing TimeoutExceptions.
    final position = await _geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: _fixTimeout,
      ),
    );
    return Coordinates(position.latitude, position.longitude);
  }

  Future<void> _cache(Coordinates coordinates) async {
    await _prefs.setDouble(AppConstants.prefLatitude, coordinates.latitude);
    await _prefs.setDouble(AppConstants.prefLongitude, coordinates.longitude);
  }
}
