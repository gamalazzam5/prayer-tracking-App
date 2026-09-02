/// Raw exceptions thrown by data sources. They never escape the data layer —
/// repositories catch them and map them to a [Failure].
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Local storage operation failed']);

  @override
  String toString() => 'CacheException: $message';
}

class LocationDisabledException implements Exception {
  const LocationDisabledException();
}

class LocationDeniedException implements Exception {
  final bool isPermanent;
  const LocationDeniedException({this.isPermanent = false});
}

class CompassUnavailableException implements Exception {
  const CompassUnavailableException();
}

class PrayerCalculationException implements Exception {
  final String message;
  const PrayerCalculationException([this.message = 'Prayer calculation failed']);

  @override
  String toString() => 'PrayerCalculationException: $message';
}
